# Spring PetClinic Task Solution

## 1. Download Spring PetClinic Application

Clone the GitHub repository:

```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
2. Run Locally
Spring PetClinic uses Maven to build and run the application.

Step 1: Build the project
bash
Copy
Edit
./mvnw package
Note: On Windows use mvnw.cmd package.

Step 2: Run the application
bash
Copy
Edit
./mvnw spring-boot:run
The application will start on http://localhost:8080.

Step 3: Access the application
Open your browser and go to:

arduino
Copy
Edit
http://localhost:8080
3. Run with Docker (without Dockerfile)
We can run Spring PetClinic using the official Maven + JDK image.

Step 1: Build a JAR
bash
Copy
Edit
./mvnw package -DskipTests
After building, the JAR file is located in:

bash
Copy
Edit
target/spring-petclinic-*.jar
Step 2: Run the JAR in Docker
bash
Copy
Edit
docker run -it --rm \
  -v $(pwd)/target:/app \
  -w /app \
  -p 8080:8080 \
  openjdk:17-jdk \
  java -jar spring-petclinic-*.jar
Explanation:

-v $(pwd)/target:/app: Mounts the JAR folder into the container.

-w /app: Sets working directory in the container.

-p 8080:8080: Maps container port 8080 to host port 8080.

openjdk:17-jdk: Docker image with JDK 17.

java -jar spring-petclinic-*.jar: Runs the application.

Step 3: Access the application
Open your browser at:

arduino
Copy
Edit
http://localhost:8080
✅ Application is now running locally and inside Docker without writing a Dockerfile.
