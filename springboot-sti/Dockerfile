# springboot-sti
FROM registry.access.redhat.com/rhel7
MAINTAINER Vemund Gaukstad

#Set the locale to nb_NO.UTF-8
RUN localedef -c -f UTF-8 -i nb_NO nb_NO.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL nb_NO.utf8
#Set timezone
ENV TZ=Europe/Oslo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 2.13
# Add Unlimited strength crypto strength lib to Oracle JDK
# Adding jsawk for easy parsing of json from Bamboo Rest-API in assemble script
ENV GRADLE_VERSION 2.13
ENV MAVEN_VERSION 3.3.9
ENV JAVA_VERSION 1.8.0_101
RUN yum install -y tar unzip bc which lsof js iputils net-tools bzip2 && \
    yum clean all -y && \
	  (curl -v -j -k -L http://web1.nspdc.no/oracle/jdk-8u101-linux-x64.tar.gz | tar -zx -C /usr/local) && \
	  mv /usr/local/jdk$JAVA_VERSION /usr/local/java && \
	  ln -sf /usr/local/java/bin/java /usr/local/bin/java && \
	  curl -v -j -k -L http://web1.nspdc.no/oracle/jce_policy-8.zip -o /tmp/jce_policy-8.zip && \
	  unzip /tmp/jce_policy-8.zip -d /usr/local/crypto/ && \
	  rm /tmp/jce_policy-8.zip && \
	  mv -f /usr/local/crypto/UnlimitedJCEPolicyJDK8/*.jar /usr/local/java/jre/lib/security/ && \
    (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    (curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/) && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src && \
    mkdir -p /opt/openshift/bin

ENV PATH=/opt/maven/bin/:/opt/gradle/bin/:/opt/java/bin/:/opt/openshift/bin:$PATH
ENV JAVA_HOME=/usr/local/java
ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building Spring Boot applications with maven or gradle" \
      io.k8s.display-name="Spring Boot builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,gradle-2.6,springboot,bamboo"

LABEL io.openshift.s2i.scripts-url=image:///usr/local/sti
COPY ./java/jre/lib/ /usr/local/java/jre/lib
COPY ./.sti/bin/ /usr/local/sti
COPY ./usr/bin/ /opt/openshift/bin

RUN chown -R 1001:1001 /opt/openshift && chmod -R a+rwx /opt/openshift/bin

USER 1001

COPY ./.m2/ /opt/app-root/src/.m2

# Set the default port for applications built using this image
EXPOSE 8080
EXPOSE 8181

# Set the default CMD for the image
# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
