# Spring PetClinic Task Solution

## 1. Download Spring PetClinic Application

Clone the GitHub repository:

***git clone https://github.com/spring-projects/spring-petclinic.git***

***cd spring-petclinic***

2-Run Locally
--
Spring PetClinic uses Maven to build and run the application.

**Step 1**: Build the project

***./mvnw package -DskipTests***

Note: On Windows use mvnw.cmd package.

**Step 2**: Run the application

**java -jar target/spring-petclinic-*.jar**

The application will start on http://localhost:8080.

**Step 3**: Access the application

Open your browser and go to:

http://localhost:8080

3- Run with Docker
-
We can run Spring PetClinic using the official Maven + JDK image.

**Step 1**: Build a JAR

**./mvnw package -DskipTests**

After building, the JAR file is located in:

target/spring-petclinic-*.jar

**Step 2**: Run the JAR in Docker

***docker run -d \
  -v $(pwd)/target:/app \
  -w /app \
  -p 9091:9091 \
  openjdk:17-jdk \
  spring-petclinic-3.5.0-SNAPSHOT.jar --server.port=9091**
  
Explanation:

-v $(pwd)/target:/app: Mounts the JAR folder into the container.

-w /app: Sets working directory in the container.

-p 9091:9091: Maps container port 9091 to host port 9091.

openjdk:17-jdk: Docker image with JDK 17.

spring-petclinic-3.5.0-SNAPSHOT.jar --server.port=9091: Runs the application.

Step 3: Access the application

Open your browser at:

http://localhost:9091

✅ Application is now running locally and inside Docker.
