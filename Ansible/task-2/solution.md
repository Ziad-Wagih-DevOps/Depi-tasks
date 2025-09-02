
# Ansible Task 2: AWS Instances with Dockerized Spring PetClinic by ansible

## 🎯 Objective

The goal of this task is to:

1. Launch 3 AWS EC2 instances ubuntu servers.
2. Manage them from a local Ansible controller using SSH.
3. Verify Ansible & Python installation in local host and VMs.
4. Configure secure SSH connection between local and remote hosts.
5. Install prerequisites (Java, Docker, Git, etc.) in VMs.
6. Configure Docker Hub authentication using Ansible Vault.
7. Build and push the Spring PetClinic app image to Docker Hub.
8. Pull and run the image on other instances.
9. Use a multi-stage Dockerfile for optimized image size.
10. Ensure persistent SSH connections for faster playbook execution.
11. Use conditions to pull/push images only when necessary increase performance and excution speed.
12. Use handlers to restart Docker and containers only when needed increase efficiency.
13. Structure tasks into roles, making the playbook modular and reusable.

---

## 📂 Project Structure (Role-Based)

```

ansible-task2/
├── ansible.cfg
├── hosts.ini
├── playbook.yml
├── group_vars/
│   └── all.yml          # Shared variables for all hosts
├── roles/
│   ├── common/          # Install prerequisites (Java, Docker, Git)
│   │   ├── tasks/main.yml
│   │   └── handlers/main.yml
│   ├── docker-login/    # Docker Hub authentication
│   │   └── tasks/main.yml
│   ├── build-push/      # Build & push Docker image
│   │   ├── tasks/main.yml
│   │   └── templates/Dockerfile.j2
│   ├── pull/            # Pull image from Docker Hub
│   │   ├── tasks/main.yml
│   │   └── handlers/main.yml
│   └── run/             # Run container on all servers
│       └── tasks/main.yml
└── vault.yml            # Encrypted DockerHub credentials

````

---

## ⚙ Step 1: Verify Local Setup

```bash
ansible --version
python3 --version
````

> Python is required on both controller and managed nodes.

---

## ⚙ Step 2: Launch AWS EC2 Instances ubuntu servers

* 1 instance → for Build & Push
* 2 instances → for Pull

---

## ⚙ Step 3: Configure SSH Connection

in localhost
```bash
ssh-keygen -t rsa
chmod 400 path/to/private-key
cat ~/.ssh/id_rsa.pub
```

On each VM after connect with it by private aws instance key:

```bash
chmod 700 ~/.ssh
echo "ssh-rsa AAAA...your_public_key..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

✅ Ensures passwordless SSH.

---

## in master: ⚙ Step 4: Ansible Inventory (hosts.ini)

```ini
[build_push]
3.144.130.43 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[pull]
3.18.111.117 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
3.17.142.165 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[allservers:children]
build-push
pull
```

---

## ⚙ Step 5: Ansible Config (ansible.cfg)

```ini
[ssh_connections]
ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ControlPath=/tmp/ansible-ssh-%h-%p-%r
pipelining = true
```

> Improves connection persistence and speed.

---

## ⚙ Step 6: Vault File (vault.yml)

```yaml
dockerhub_user: "ziadwagih7"
dockerhub_pass: "your-token-pass"
```
> This file allows Ansible to log in to Docker Hub securely when building, pushing, or pulling Docker images, without exposing your credentials in the playbook.
> i used password as a token and give it read&write access for best security
---

## ⚙ Step 7: Shared Variables (group_vars/all.yml)

```yaml
docker_repo: "ziadwagih7/petclinic-app"
app_dir: "/home/ubuntu/spring-petclinic"
```

---

## ⚙ Step 8: Main Playbook (playbook.yml)

```yaml
- name: Setup prerequisites & Dockerhub login
  hosts: allservers
  become: yes
  vars_files:
    - vault.yml
  roles:
    - common
    - docker-login

- name: Build & Push PetClinic image
  hosts: build_push
  become: yes
  roles:
    - build_push

- name: Pull PetClinic image
  hosts: pull
  become: yes
  roles:
    - pull

- name: Run PetClinic container
  hosts: allservers
  become: yes
  roles:
    - run
```

---

## ⚙ Step 9: common Role (Prerequisites)

**Tasks (roles/common/tasks/main.yml)**

```yaml
- name: Update apt repo
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Gather installed packages facts
  package_facts:
    manager: apt

- name: Install required packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - apt-transport-https
    - ca-certificates
    - curl
    - software-properties-common
    - git
    - openjdk-17-jdk
  when: item not in ansible_facts.packages

- name: Add Docker GPG key
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: Add Docker repository
  apt_repository:
    repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable
    state: present

- name: Install Docker
  apt:
    name: docker-ce
    state: present
    update_cache: yes
  notify: Restart Docker

- name: Ensure Docker is running
  service:
    name: docker
    state: started
    enabled: true
```

**Handler (roles/common/handlers/main.yml)**

```yaml
- name: Restart Docker
  service:
    name: docker
    state: restarted
    enabled: true
```

---

## ⚙ Step 10: docker-login Role

**Tasks (roles/docker-login/tasks/main.yml)**

```yaml
- name: Docker Hub login
  docker_login:
    username: "{{ dockerhub_user }}"
    password: "{{ dockerhub_pass }}"
```
---

## ⚙ Step 11: build_push Role

**Tasks (roles/build_push/tasks/main.yml)**

```yaml
- name: Clone Spring PetClinic repo
  git:
    repo: "https://github.com/spring-projects/spring-petclinic.git"
    dest: "{{ app_dir }}"
    version: main

- name: Create Dockerfile
  template:
    src: Dockerfile.j2
    dest: "{{ app_dir }}/Dockerfile"

- name: Build Docker Image
  docker_image:
    name: "{{ docker_repo }}"
    build:
      path: "{{ app_dir }}"
    source: build
    tag: latest

- name: Get local image info
  community.docker.docker_image_info:
    name: "{{ docker_repo }}:latest"
  register: local_image

- name: Get remote image info
  community.docker.docker_image_info:
    name: "{{ docker_repo }}:latest"
  register: remote_image
  ignore_errors: yes

- name: Push image if local != remote
  docker_image:
    name: "{{ docker_repo }}"
    tag: latest
    push: yes
    source: local
  when:
    - local_image.images | length > 0
    - remote_image.images is not defined or local_image.images[0].Id != remote_image.images[0].Id
```

**Dockerfile Template (roles/build-push/templates/Dockerfile.j2)**

```dockerfile
# stage 1 build
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
COPY .mvn .mvn
COPY mvnw .
RUN ./mvnw package -DskipTests

# stage 2 run
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
```

---

## ⚙ Step 12: pull Role

**Tasks (roles/pull/tasks/main.yml)**

```yaml
- name: Get local image info
  community.docker.docker_image_info:
    name: "{{ docker_repo }}:latest"
  register: local_image
  ignore_errors: yes

- name: Get remote image info
  community.docker.docker_image_info:
    name: "{{ docker_repo }}:latest"
  register: remote_image
  ignore_errors: yes

- name: Pull image if digest differs
  docker_image:
    name: "{{ docker_repo }}"
    tag: latest
    source: pull
  when:
    - remote_image.images is defined
    - local_image.images | length == 0 or local_image.images[0].Id != remote_image.images[0].Id
  notify: Restart PetClinic container
```

**Handler (roles/pull/handlers/main.yml)**

```yaml
- name: Restart PetClinic container
  docker_container:
    name: petclinic
    image: "{{ docker_repo }}"
    state: started
    restart_policy: always
    recreate: true
    published_ports:
      - "8080:8080"
```

---

## ⚙ Step 13: run Role

**Tasks (roles/run/tasks/main.yml)**

```yaml
- name: Run PetClinic container
  docker_container:
    name: petclinic
    image: "{{ docker_repo }}"
    state: started
    restart_policy: always
    published_ports:
      - "8080:8080"
```

---

## ✅ Key Points

* **Modular roles**: common, docker-login, build-push, pull, run.
* **Secure secrets**: Docker Hub credentials in `vault.yml`.
* **Shared variables**: `docker_repo` and `app_dir` in `group_vars/all.yml`.
* **Handlers**: Restart Docker or container only when necessary.
* **Conditions**: Pull/push images only if needed to save bandwidth and time.
* **Multi-stage Dockerfile**: Optimized image size (\~120MB).
* **Persistent SSH**: Faster Ansible playbook execution via ControlPersist.

---

## 📌 Verification

1. Check app running in VM :

```bash
curl http://<EC2-PUBLIC-IP>:8080
```
. Check app running in browser in localhost :

```bash
http://<EC2-PUBLIC-IP>:8080
```

2. Verify Docker image size:

```bash
docker images | grep petclinic-app
```

3. Verify compressed image in Docker Hub.

---

## 🚀 Outcome

* 3 AWS VMs provisioned and managed with Ansible.
* Secure SSH orchestration.
* Automated install → build → push → pull → run pipeline.
* Spring PetClinic accessible on all servers at port 8080.

```
```

