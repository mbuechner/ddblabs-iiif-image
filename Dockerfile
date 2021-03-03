FROM debian:buster
MAINTAINER Michael Büchner <m.buechner@dnb.de>

ENV CANTALOUPE_VERSION=4.1.7

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick maven \
    libopenjp2-tools ffmpeg unzip default-jre-headless && \
    apt-get -qqy autoremove && apt-get -qqy autoclean

# Run non privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
WORKDIR /tmp
RUN curl --silent --fail -OL https://github.com/cantaloupe-project/cantaloupe/archive/v$CANTALOUPE_VERSION.zip
RUN unzip v$CANTALOUPE_VERSION.zip

WORKDIR /tmp/cantaloupe-$CANTALOUPE_VERSION/
RUN sed -i 's|context.setContextPath("/");|context.setContextPath(System.getenv("PATH_PREFIX") != null ? System.getenv("PATH_PREFIX") : "/");|g' src/main/java/edu/illinois/library/cantaloupe/ApplicationServer.java
RUN mvn package -Dmaven.test.skip=true
ENV MAVEN_OPTS=-Xms512M -Xmx1G
RUN mv target/cantaloupe-$CANTALOUPE_VERSION.zip /

WORKDIR /
RUN unzip cantaloupe-$CANTALOUPE_VERSION.zip 
RUN ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe 
RUN rm cantaloupe-$CANTALOUPE_VERSION.zip 
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe 
RUN chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe 
RUN cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/

RUN rm -rf /tmp/*
COPY cantaloupe.properties cantaloupe/
RUN chmod 644 /cantaloupe/cantaloupe.properties

USER cantaloupe

EXPOSE 8182
CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties -jar /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]

