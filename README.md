# curd-vaadin-pg

https://cfkubo.github.io/curd-vaadin-pg/

#### Sample demo project that implements CURD funcationality with Spring Boot, Vaadin and PostgreSQL.
## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Getting Started](#getting-started)
4. [Configuration](#configuration)
5. [Setup Postgres on local](#Run-postgres-in-docker)
6. [Build and Run](#Build-and-Run)

## Introduction

This project is a simple CRUD application that demonstrates how to implement basic Create, Read, Update and Delete functionality using Spring Boot, Vaadin and PostgreSQL.

## Features
- **CRUD Operations**: The application provides full CRUD (Create, Read, Update, Delete) operations for managing data.
- **Spring Boot**: Utilizes Spring Boot for the backend framework.
- **Vaadin**: Uses Vaadin for building a responsive web UI.
- **PostgreSQL**: Employs PostgreSQL as the database.

![Alt text](static/vaadin.png)


## Getting Started

To get started with this project, you need to have the following prerequisites installed on your system:

- Java Development Kit (JDK) 11 or higher
- Maven
- PostgreSQL Database Server

## Configuration

Before running the application, ensure that your `application.properties` file is correctly configured. The default configuration assumes a local PostgreSQL database with the following settings:


### Run-postgres-in-docker
```
docker run --name my-postgres -p 5432:5432 -e POSTGRES_PASSWORD=password -d postgres
```
```
docker run --name my-postgres -p 5432:5432 -e POSTGRES_PASSWORD=password -d postgres debezium/postgres
```

### Create an admin user to be able login remotely or create restricted user with login
```
CREATE ROLE admin WITH LOGIN PASSWORD 'password';
ALTER ROLE admin WITH SUPERUSER;
```

> Conect to postgres using psql or docker exec

```
psql -d postgres -h localhost -p 5432
```

```
docker exec -it c66013bcd55b  psql -U postgres
```

```
postgres=#

postgres=# CREATE ROLE admin WITH LOGIN PASSWORD 'password';

-- Grant superuser privileges (full admin access)
ALTER ROLE admin WITH SUPERUSER;
CREATE ROLE
ALTER ROLE
postgres=# exit
```

### Build-and-Run
```
mvn clean install
mvn clean build
mvn clean package
mvn spring-boot:run
```

### Exposed endpoints 

- showcases CURD with postgres + vaadinUI

[http://localhost:8080/](http://localhost:8080)


- showcases search functionaly with VaadinUI

[http://localhost:8080/search](http://localhost:8080/search)

- Showcases psql-terminal to be able to interact with database usefull for validations or loading data. You can also leverage client tools to achieve the same. 

[http://localhost:8080/psql-terminal](http://localhost:8080/psql-terminal)


### Setup JAVA_HOME
```
brew --prefix openjdk@17
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
```

### Managing docker with colima
```
colima start --cpu 8 --memory 12
```

### Image creation (WIP - TESTING NEEDED)

- check for dependency conflicts
```
mvn dependency:tree
```

- Building a production build with vaadin options

```
mvn clean package -Pproduction -Dvaadin.force.production.build=true -DskipTests
```

- Verfify if vaadin builds are prod ready

```
jar tvf target/crud-with-vaadin-initial-0.0.1-SNAPSHOT.jar | grep META-INF/VAADIN/
```


- To create the image, run the following goal: (-X for debug ouput)

```
./mvnw spring-boot:build-image -Pnative -DskipTests -X
```

- Clean image build (-X for debug ouput)

```
./mvnw clean package spring-boot:build-image -Pnative -DskipTests -X
```

- Build image with multple threads (if the above fails)

```
mvn clean package -Pnative spring-boot:build-image -T 8C -DskipTests
```


- Then, you can run the app like any other container:

```
docker run --rm -p 8080:8080 docker.io/library/crud-with-vaadin-initial:0.0.1-SNAPSHOT
```
### Executable with Native Build Tools

- Use this option if you want to explore more options such as running your tests in a native image. The GraalVM native-image compiler should be installed and configured on your machine.

- NOTE: GraalVM 22.3+ is required.

- To create the executable, run the following goal:

```
./mvnw native:compile -Pnative
```
- Then, you can run the app as follows:

```
target/spdemo
```
- You can also run your existing tests suite in a native image. This is an efficient way to validate the compatibility of your application.

- To run your existing tests in a native image, run the following goal:

```
./mvnw test -PnativeTest
```


#### Usefull Commands

```
git reset --soft HEAD~1
```

```
rsync -avz --exclude='.git/' --exclude='.cache/'  /Users/avannala/Documents/workspace/curd-vaadin-pg  ubuntu@XX.XX.XX.XX:~
```