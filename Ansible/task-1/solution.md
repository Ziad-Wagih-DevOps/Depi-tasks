# Ansible Task 1 

**By:** ENG/Ziad Wagih Emam  
**Under supervision:** ENG/Ali Saleh  
**In:** DevOps Egypt Digital Pioneers Initiative  

---

## 📌 Task Description

This task is about using **Ansible** in a local machine (controller node) to control two AWS EC2 Ubuntu servers (managed nodes).

**Ansible** is an open-source automation tool used for configuration management, application deployment, and IT orchestration.  
It allows you to automate tasks across multiple servers using simple YAML playbooks, without needing complex coding.

---

## 📌 Steps to Solve This Task

### 1. Setup Controller Node (Local Machine)
Ensure **Python3** is installed (Ubuntu comes with it by default).

```bash
python3 --version
```
✅ Expected result: `Python 3.12.3`

Install **Ansible**:

```bash
sudo apt install ansible -y
```

Verify installation:

```bash
ansible --version
```

---

### 2. Generate SSH Keys

```bash
ssh-keygen -t rsa
```

- **Key type**: RSA  
- Default location: `~/.ssh/id_rsa` (private key), `~/.ssh/id_rsa.pub` (public key).  
- Optionally set a passphrase for extra security.

View public key:

```bash
cat ~/.ssh/id_rsa.pub
```

---

### 3. Launch AWS Managed Nodes

Launch **two Ubuntu EC2 instances**:  

- Name: `managed-node1`, `managed-node2`  
- AMI: `Ubuntu Server 22.04 LTS`  
- Type: `t2.micro`  
- Key Pair: Create and download `.pem` file  
- Security Group: Allow SSH (22) from your internet
  tip:to best security make it from your public ip
-screen for configuration of managed-node1:

---

### 4. Connect to AWS Instances

Move to the `.pem` location and fix permissions:

```bash
chmod 400 /path/to/key.pem
```

SSH into each instance:

```bash
ssh -i /path/to/key.pem ubuntu@<PUBLIC_IP_NODE_1>
ssh -i /path/to/key.pem ubuntu@<PUBLIC_IP_NODE_2>
```

---

### 5. Add Controller SSH Key to Managed Nodes

On each VM:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Copy your controller’s public key (`cat ~/.ssh/id_rsa.pub`) and add it:

```bash
echo "ssh-rsa AAAA...your_public_key... comment" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

### 6. Test Passwordless SSH

From controller node:

```bash
ssh ubuntu@<PUBLIC_IP_NODE_1>
ssh ubuntu@<PUBLIC_IP_NODE_2>
```

✅ If successful → no `.pem` required.

---

### 7. Create Ansible Inventory File

`hosts.ini`:

```ini
[aws_nodes]
node1 ansible_host=<PUBLIC_IP_NODE_1> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
node2 ansible_host=<PUBLIC_IP_NODE_2> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

### 8. Run Ansible Ping Command

```bash
ansible -i hosts.ini aws_nodes -m ping
```

✅ Expected output:

```json
node1 | SUCCESS => {"changed": false, "ping": "pong"}
node2 | SUCCESS => {"changed": false, "ping": "pong"}
```
screen here !
---
