# 🐾 Spring PetClinic with Docker Compose

This project runs the [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) application using **Docker Compose**.  
It supports two environments (**Dev with MySQL** and **Prod with PostgreSQL**) and integrates with:
- **Nexus** → for managing Docker images.  
---

## 📌 Steps to Solve This Task

### 1. Clone the Repository
```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
```

### 2. Build & Push Image to Nexus

-Ensure java install and The path is recognized correctly
```bash
echo $JAVA_HOME
java -version
javac -version
```
![java Screenshot](https://github.com/Ziad-Wagih-DevOps/Depi-tasks/blob/main/2-docker/task-4/screenshots/1-java%20install.png?raw=true)

- Run Nexus:
```bash
docker run -d \
  -p 8081:8081 \
  -p 8083:8083 \
  --name nexus \
  --restart unless-stopped \
  sonatype/nexus3
```
**Breakdown**:

**docker run** → starts a new container from an image.

**-d** → runs the container in detached mode (in the background).

**-p 8081:8081** → maps port 8081 inside the container to 8081 on your host (for Nexus Web UI).

**-p 8083:8083** → maps port 8083 inside the container to 8083 on your host (for Docker registry).

**--name nexus** → gives the container a friendly name nexus.

**--restart unless-stopped** → automatic run after restart docker or host unless you stoped it. 

**sonatype/nexus3** → the Docker image to use (official Nexus 3 image).

**✅ In short**: This command runs Nexus 3 in the background, opens ports for UI and Docker registry, and names the container nexus.

- Inside spring-petclinic/create Dockerfile :
```bash
# 1️⃣  (Build Stage) using maven
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn package -DskipTests

# 2️⃣  (Run Stage) using JDK
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

```

**Dockerfile Explanation**

**1️⃣ Build Stage (using Maven)**

```bash
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn package -DskipTests
```

Uses a Maven + JDK image to compile and package the Spring Petclinic app.

COPY . . → copies all source code into the container.

RUN mvn package -DskipTests → builds the JAR file without running tests.

**12️⃣ Run Stage (using JDK)**

```bash
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

```

Uses a lightweight JDK image to run the app.

COPY --from=build → copies the JAR built in the first stage.

EXPOSE 8080 → exposes port 8080 for the application.

ENTRYPOINT ["java","-jar","app.jar"] → starts the app when the container runs

**✅ Summary**

This is a multi-stage Dockerfile:

Stage 1 → build the app

Stage 2 → run the app in a smaller, cleaner image for production


- create and login Docker Registry in nexus to i can push images to it :

**1-Access nexus UI :** http://localhost:8081

**2-log in :**

**user:** admin

**password:** 

password in nexus container we can get it by :

```bash
docker exec -it <nexus_container_id> cat /nexus-data/admin.password
```
**Note:** password is text inside admin.password without root.

**Note:** you change it to a new password after login.

**3- Create Docker Hosted Repository :**

**Go to Nexus UI **→ Administration → Repositories → Create repository.

Choose docker (hosted) and configure port 8083 as http.

![Create Docker Hosted Repository](./screenshots/create_docker_repo.png)

**4- Configure Docker Insecure Registry**

**->Edit /etc/docker/daemon.json:**

```bash
{
"insecure-registries": ["localhost:8083"]
}
```
**Explanation:**

"insecure-registries": ["localhost:8083"] → tells Docker that the registry at localhost:8083 is trusted even without HTTPS.

Without this, docker login or docker push to the local registry will fail with TLS/connection errors.

**Note** : if you don't find docker directory and daemon.json file create it

**->Restart Docker:**

```bash
systemctl restart docker
```
**Note:**Use --restart unless-stopped to keep Nexus running after Docker restart.

**Note:**if restart command don't run you should ubdate packages and docker by this commands :

```bash
apt update
apt install docker.io -y
```

**5- Login to Nexus Docker Registry**
```bash
docker login localhost:8083
```
**6- Build and push image to nexus:**
```bash
docker build -t localhost:8083/spring-petclinic:latest .
docker push localhost:8083/spring-petclinic:latest
```

### 3. Base `docker-compose.yml`
Defines the PetClinic app, Prometheus, and Grafana.
```yaml
version: '3.8'
services:
  app:
    image: localhost:8083/spring-petclinic:latest
    ports:
      - "8084:8080"
    depends_on:
       db :
         condition: service_healthy
    networks:
      - petnet
    environment:
      SPRING_DATASOURCE_URL: ${SPRING_DATASOURCE_URL}
      SPRING_DATASOURCE_USERNAME: ${SPRING_DATASOURCE_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${SPRING_DATASOURCE_PASSWORD}
      SPRING_JPA_HIBERNATE_DDL_AUTO: ${SPRING_JPA_HIBERNATE_DDL_AUTO}
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    networks:
      - petnet

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    networks:
      - petnet

networks:
  petnet:
```
**Explanation:**

This docker-compose.yml launches:

PetClinic app (8084 as local host)

Prometheus (9090) for metrics

Grafana (3000) for visualization

→ All linked together through the same network petnet.

### 4. Dev Environment (MySQL + volume)

**File: `env.dev.`**

```bash
SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/petclinic?useSSL=false&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=petuser
SPRING_DATASOURCE_PASSWORD=petpass
SPRING_JPA_HIBERNATE_DDL_AUTO=update
```
**🔹 explanation**:
```bash
SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/petclinic?useSSL=false&serverTimezone=UTC
```
This tells the Spring Boot app where the database is.

jdbc:mysql://db:3306/petclinic → connects to the MySQL database named petclinic running on the db container at port 3306.

useSSL=false → disables SSL (no secure connection, fine for dev).

serverTimezone=UTC → sets the database timezone to UTC to avoid time issues.

```bash
SPRING_DATASOURCE_USERNAME=petuser
SPRING_DATASOURCE_PASSWORD=petpass
```

These are the credentials to log into the database.

petuser is the username, petpass is the password.

```bash
SPRING_JPA_HIBERNATE_DDL_AUTO=update
```

This tells Hibernate (the JPA tool Spring uses) how to manage the database schema.

update → it will automatically create missing tables or columns without deleting existing data.

**File: `docker-compose.dev.yml**`
```yaml
version: '3.8'
services:
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: petclinic
      MYSQL_USER: petuser
      MYSQL_PASSWORD: petpass
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - petnet
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "127.0.0.1", "-uroot", "-prootpass"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 40s 

volumes:
  mysql_data:
```
**simple explanation : **

**Services**
```bash
db:
  image: mysql:8
```
Runs a MySQL version 8 container.
```bash
environment:
  MYSQL_ROOT_PASSWORD: rootpass
  MYSQL_DATABASE: petclinic
  MYSQL_USER: petuser
  MYSQL_PASSWORD: petpass
```

Sets MySQL credentials and creates a database:

Root password = rootpass

Creates a database named petclinic

Creates a user petuser with password petpass
```bash
volumes:
  - mysql_data:/var/lib/mysql
```

Stores database files in a Docker volume so data persists even if the container is removed.
```bash
networks:
  - petnet
```

Connects the database to a custom network called petnet so other services (like your app) can talk to it.
```bash
healthcheck:
  test: ["CMD", "mysqladmin" ,"ping", "-h", "127.0.0.1", "-uroot", "-prootpass"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 40s
```

Checks if MySQL is ready before other services connect.

Runs mysqladmin ping every 10s, waits up to 5s for a response, retries 5 times, and allows 40s for MySQL to start initially.

```bash
Volumes
volumes:
  mysql_data:
```

Defines a persistent volume named mysql_data to store MySQL data.


Run dev:
```bash
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml up -d
```

**access app on** : http://localhost:8084

**Open your My-SQL database to ensure it's running** : 

```bash
docker exec -it petclinic-mysql bash
mysql -u petuser -p
USE petclinic;
SHOW TABLES;
```

### 5. Prod Environment (PostgreSQL + volume)

**->`File: env.prod.`**
```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/petclinic
SPRING_DATASOURCE_USERNAME=petuser
SPRING_DATASOURCE_PASSWORD=petpass
SPRING_JPA_HIBERNATE_DDL_AUTO=update
```
**->File: `docker-compose.prod.yml`**
```yaml
version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: petclinic
      POSTGRES_USER: petuser
      POSTGRES_PASSWORD: petpass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - petnet
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U petuser -d petclinic"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 40s

volumes:
  postgres_data:
```

**->Run prod:**

**Note:** before run prod we remove running application containers in dev 

```bash
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml down -v
docker-compose --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d
```
**->access app on** : http://localhost:8084

**->Open your PostgreSQL database to ensure it's running** : 

```bash
docker exec -it <container-db-ID> bash
psql -U petuser -d petclinic
\dt; 
```
**explanation:**

```bash
docker exec -it <container-db-ID> bash
```

Opens a bash shell inside the running MySQL or PostgreSQL container.

**<container-db-ID>** is the ID or name of your database container.

**-it** allows you to interact with the shell.

**psql -U petuser -d petclinic**

Connects to a PostgreSQL database (petclinic) using the user petuser.

Lets you run SQL commands interactively.

**\dt;**

A PostgreSQL meta-command to list all tables in the current database.

Helps you see the structure of the database and confirm tables exist.

![Create Docker Hosted Repository](./screenshots/create_docker_repo.png)

