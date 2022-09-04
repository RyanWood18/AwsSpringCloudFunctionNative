FROM amazonlinux:2 AS spring-native-aws-lambda-builder

ENV GRAALVM_VERSION=22.2.0
ENV FILE_NAME=graalvm-ce-java11-linux-amd64-${GRAALVM_VERSION}.tar.gz
ENV JAVA_HOME=./graalvm-ce-java11-${GRAALVM_VERSION}

ENV PATH="${PATH}:graalvm-ce-java11-${GRAALVM_VERSION}/bin"
ENV GRAALVM_HOME=/graalvm-ce-java11-${GRAALVM_VERSION}

RUN echo "pluginManagement { \
              repositories { \
                  maven { url 'https://repo.spring.io/release' } \
                  mavenCentral() \
                  gradlePluginPortal() \
              } \
          } \
" >> settings.gradle

RUN yum -y update
RUN yum install -y wget tar gzip bzip2-devel ed gcc gcc-c++ gcc-gfortran \
    less libcurl-devel openssl openssl-devel readline-devel xz-devel \
    zlib-devel glibc-static libcxx libcxx-devel llvm-toolset-7 zlib-static unzip

RUN rm -rf /var/cache/yum

RUN curl -L 'https://services.gradle.org/distributions/gradle-7.5.1-bin.zip' --OUTPUT gradle-7.5.1-bin.zip


RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-7.5.1-bin.zip

ENV PATH="${PATH}:/opt/gradle/gradle-7.5.1/bin"

COPY settings.gradle .
COPY ./gradlew .
COPY ./gradle gradle
COPY build.gradle .
COPY src src

RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAALVM_VERSION}/${FILE_NAME}
RUN tar zxvf ${FILE_NAME}
RUN rm -f ${FILE_NAME}

RUN gradle nativeCompile --stacktrace
