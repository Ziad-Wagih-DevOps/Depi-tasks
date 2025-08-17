# Docker Task 4  
**By:** ENG/Ziad Wagih Emam  
**Under supervision:** ENG/Ali Saleh  
**In:** DevOps Egypt Digital Pioneers Initiative  

---

## 📌 Task Description
The goal of this task is to **run the Spring PetClinic application** using **Docker Compose** in the best way.  
We will implement the solution with:  
Usage of **networks** and **volumes** for proper container communication and persistent storage.  

📂 Spring PetClinic source: [spring-projects/spring-petclinic](https://github.com/spring-projects/spring-petclinic.git)

---

## 🛠️ Steps to Solve the Task

### 1️⃣ Clone the Project
```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic

```

### 2️⃣ Ensure java install and The path is recognized correctly
```bash
echo $JAVA_HOME
java -version
javac -version
```
![java Screenshot](https://github.com/Ziad-Wagih-DevOps/Depi-tasks/blob/main/2-docker/task-4/screenshots/1-java%20install.png?raw=true)

### 3️⃣ Build Application Jar:
```bash
./mvnw package -DskipTests
```
Output file: target/spring-petclinic-*.jar

### 4️⃣ Inside spring-petclinic/ create a Dockerfile:
```bash
# Use OpenJDK as base image
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Copy the jar file
COPY target/spring-petclinic-*.jar app.jar

# Expose default Spring Boot port
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
```
### 5️⃣ Inside spring-petclinic/ create docker-compose.yml file:
```bash
version: "3.8"

services:
  petclinic:
    build: .
    container_name: petclinic
    ports:
      - "7070:8080"
    networks:
      - petclinic-net
    volumes:
      - petclinic-data:/app/data

networks:
  petclinic-net:

volumes:
  petclinic-data:

```
### 6️⃣ run compose file :
```bash
docker compose up -d
```
Open application : http://localhost:7070





