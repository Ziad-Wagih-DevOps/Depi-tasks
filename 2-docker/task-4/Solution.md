# Docker Task 4  
**By:** ENG/Ziad Wagih Emam  
**Under supervision:** ENG/Ali Saleh  
**In:** DevOps Egypt Digital Pioneers Initiative  

---

## 📌 Task Description
The goal of this task is to **run the Spring PetClinic application** using **Docker Compose** in the best way depend on MySQL Data base.  
We will implement the solution with:  
Usage of **networks** and **volumes** for proper container communication and persistent storage.

1-without replica and scaling

2-with replica and scaling

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
Note:📌 Do I need to install Maven to run ./mvnw package -DskipTests?
👉 Answer: No.
Spring PetClinic (and most modern Spring Boot projects) already include the Maven Wrapper (mvnw for Linux/Mac and mvnw.cmd for Windows).

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
📄 ***Dockerfile Explanation**
**1-Base Image**
```bash
FROM openjdk:17-jdk-slim
```
-Uses a lightweight OpenJDK 17 image.
-Provides the Java environment needed to run the Spring Boot application.

**2-Set Working Directory**
```bash
WORKDIR /app
```
-Creates (or switches to) the /app directory inside the container.
-All following commands will run inside this folder.

**3-Copy Application JAR**
```bash
COPY target/spring-petclinic-*.jar app.jar
```
-Copies the built JAR file from your machine (target/) into the container.
-Renames it to app.jar inside /app.

**4-Expose Application Port**
```bash
EXPOSE 8080
```
-Tells Docker that the application runs on port 8080.
-This is the default Spring Boot port.

**5-Run the Application**
```bash
ENTRYPOINT ["java", "-jar", "app.jar"]
```
-Defines the command to start the application when the container runs.
-Executes: java -jar app.jar.

**✅ In short:**
This Dockerfile builds a container that runs a Spring Boot application using Java 17. It sets a working directory, copies the app JAR inside, exposes port 8080, and runs the application automatically.

### 5️⃣ Inside spring-petclinic/ create docker-compose.yml file:
```bash
version: "3.8"

services:
  mysql:
    image: mysql:8
    container_name: petclinic-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: petclinic
      MYSQL_USER: petuser
      MYSQL_PASSWORD: petpass
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - petclinic-net
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-p$$MYSQL_ROOT_PASSWORD"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  petclinic:
    build: .
    container_name: spring-petclinic
    ports:
      - "7070:8080"
    networks:
      - petclinic-net
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/petclinic
      SPRING_DATASOURCE_USERNAME: petuser
      SPRING_DATASOURCE_PASSWORD: petpass
      SPRING_JPA_HIBERNATE_DDL_AUTO: update
    volumes:
      - petclinic-data:/app/data

networks:
  petclinic-net:

volumes:
  mysql-data:
  petclinic-data:
```
**📄 Docker Compose Explanation**

This file defines a multi-container setup for the PetClinic app and its MySQL database.

**🔹 MySQL Service:**

Image: MySQL 8 official image.

Container name: petclinic-mysql.

Restart policy: Always restart if stopped.

Environment variables:

MYSQL_ROOT_PASSWORD: root password.

MYSQL_DATABASE: creates DB petclinic.

MYSQL_USER + MYSQL_PASSWORD: non-root user for the app.

Volumes: Stores database files in mysql-data.

Network: Connected to petclinic-net.

Healthcheck: Ensures MySQL is running before app starts.

**🔹 PetClinic Service:**

Build: From local Dockerfile.

Container name: spring-petclinic.

Ports: Maps 7070 (host) → 8080 (container).

Network: Connected to petclinic-net.

depends_on: Waits for MySQL to be healthy.

Environment variables: Configures DB connection.

Volumes: Persists app data in petclinic-data.

**🔹 Networks:**

petclinic-net: Custom network for inter-service communication.

**🔹 Volumes:**

mysql-data: Persists MySQL DB files.

petclinic-data: Persists PetClinic app data.

**✅ In short:**

MySQL container runs the DB with persistence and health checks.

PetClinic container runs the app and connects to MySQL.

Both share a custom network and persistent volumes.

### 6️⃣ run docker-compose.yml file :
```bash
docker compose up -d
```
Open application in your browser to ensure it's running: http://localhost:7070

![Access app](https://github.com/Ziad-Wagih-DevOps/Depi-tasks/blob/main/2-docker/task-4/screenshots/4-%20access%20application.png?raw=true)

Open your My-SQL database to ensure it's running : 
```bash
docker exec -it petclinic-mysql bash
mysql -u petuser -p
USE petclinic;
SHOW TABLES;
SELECT * FROM owners;
```
**explanation**

**1. docker exec -it petclinic-mysql bash**

This opens an interactive shell (bash) inside the running MySQL container named petclinic-mysql.

It’s like “entering” the container so you can run commands inside it.

**2. mysql -u petuser -p**

Starts the MySQL client inside the container.

-u petuser → login with username petuser.

-p → it will ask you for a password (you’ll type petpass).

**3. USE petclinic;**

Tells MySQL to switch to the database named petclinic.

From now on, all SQL commands will run inside this database.

**4. SHOW TABLES;**

Lists all the tables inside the current database (petclinic).

For example: owners, pets, visits, etc.

**5. SELECT * FROM owners;**

Runs a SQL query to get all the rows and columns from the table owners.

* means “all columns”.

The result shows all the data saved in that table.

![data base](https://github.com/Ziad-Wagih-DevOps/Depi-tasks/blob/main/2-docker/task-4/screenshots/5-%20database.png?raw=true)

### 7️⃣ Inside spring-petclinic/ create docker-compose.deploy.yml file file :

```bash
version: "3.8"

services:
  mysql:
    image: mysql:8
    container_name: petclinic-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: petclinic
      MYSQL_USER: petuser
      MYSQL_PASSWORD: petpass
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - petclinic-net
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-p$$MYSQL_ROOT_PASSWORD"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  petclinic:
    build: .
    ports:
      - "0:8080"
    networks:
      - petclinic-net
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/petclinic
      SPRING_DATASOURCE_USERNAME: petuser
      SPRING_DATASOURCE_PASSWORD: petpass
      SPRING_JPA_HIBERNATE_DDL_AUTO: update
    volumes:
      - petclinic-data:/app/data
    deploy:
      replicas: 3        # 👈 Run 3 replicas of Petclinic
      restart_policy:
        condition: on-failure

networks:
  petclinic-net:

volumes:
  mysql-data:
  petclinic-data:

```
**explanation:**

**This file sets up a Spring Petclinic app with MySQL using Docker Compose:**

**MySQL Service:**

Runs a MySQL 8 container.

Creates a database named petclinic with user petuser and password petpass.

Stores data in a persistent Docker volume.

Has a health check to ensure MySQL is ready before other services start.

**Petclinic Service:**

Builds the Spring Petclinic app from the local Dockerfile.

Exposes the app on port 8080.

Connects to the MySQL database using environment variables.

Stores app data in a volume.

Runs 3 replicas for scaling and auto-restarts if it fails with random ports.

**Networks & Volumes:**

Both services communicate through a custom network petclinic-net.

Uses persistent volumes mysql-data and petclinic-data to save data.

### 8️⃣ run docker-compose.deploy.yml file :
```bash
docker-compose -f docker-compose.deploy.yml up --scale petclinic=3 -d 
```
**Breakdown:**

docker-compose → Runs Docker Compose to manage multi-container applications.

-f docker-compose.deploy.yml → Tells Docker Compose to use the file docker-compose.deploy.yml instead of the default docker-compose.yml.
(This is useful if you keep multiple Compose files for different environments like development, testing, or production).

up → Starts the services defined in the file. If containers don’t exist yet, it creates them.

--scale petclinic=3 → Runs 3 replicas (copies) of the petclinic service at the same time, useful for load balancing or handling more traffic.

-d → Runs everything in detached mode, meaning it works in the background without blocking your terminal.

**access app 1 : http://localhost:32768**

![java Screenshot](https://github.com/Ziad-Wagih-DevOps/Depi-tasks/blob/main/2-docker/task-4/screenshots/1-java%20install.png?raw=true)






