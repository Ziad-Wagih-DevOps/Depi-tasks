# Jenkins Task 1 

**By:** ENG/Ziad Wagih Emam  
**Under supervision:** ENG/Ali Saleh  
**In:** DevOps Egypt Digital Pioneers Initiative  

---

## 🚀 Run Spring PetClinic with Jenkins Pipeline

in this task i run the [Spring PetClinic](https://github.com/spring-projects/spring-petclinic.git) application using **Jenkins Pipeline**.

---

## ✅ Prerequisites

- Ubuntu/Debian machine (or WSL)
- Jenkins installed and running (`http://localhost:7070`)
- Java 17+ installed
- Git installed
- Maven installed

---

## 1. Clone PetClinic Repository

in path you want

```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
```
change port to 7071 in src/main/resources/application.properties file 
make : server.port=7071 
because 8080 port for me isn't free

fork spring-petclinic repo to your account 

in managed jenkins add github credintials
to prevent http 403 error for your repo

---

## 2. Create Jenkins Pipeline Job

1. Open **Jenkins Dashboard** → **New Item**
2. Select **Pipeline** → Enter a name → Click **OK**
3. Under **Pipeline** section, choose:
   - **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/Ziad-Wagih-DevOps/spring-petclinic.git`
   - Branch: `*\main`

---

## 3. Jenkinsfile Example

Create a file named `Jenkinsfile` note J must be capital inside the project root (`spring-petclinic/`) in your wsl:

and fork spring pet clinic in your account to can push Jenkinsfile

and push Jenkinsfile to your forked spring pet clinic

```groovy
pipeline {
    agent any

    tools {
        maven 'Maven3'   // Configure Maven in Jenkins global tools
        jdk 'Java17'     // Configure Java in Jenkins global tools
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/spring-projects/spring-petclinic.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Run') {
            steps {
                sh 'mvn spring-boot:run'
            }
        }
    }
}
```
(configure in `Manage Jenkins → Global Tool Configuration`):

Even if Java & Maven are installed on Linux, Jenkins doesn’t automatically know where they are.

Jenkins runs as its own user (jenkins), not your normal user.

So, you tell Jenkins exactly where Java (JAVA_HOME) and Maven (MAVEN_HOME) are in Global Tool Configuration.

Jenkins needs the JDK because it compiles code with Maven.

In Jenkins → Manage Jenkins → Global Tool Configuration:

JDK → Name: Java21, Path: /usr/lib/jvm/java-21-openjdk-amd64

Maven → Name: Maven3, Path: /usr/share/maven

---

## 4. Run the Pipeline

- Go to your Jenkins job → **Build Now**
- Jenkins will:
  1. Clone the repo
  2. Build with Maven
  3. Run tests
  4. Start the Spring Boot app

---

## 5. Access the Application

Once the pipeline finishes, the app should be available at:

```
http://localhost:7071
```

---
