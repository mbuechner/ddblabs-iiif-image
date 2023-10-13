FROM debian:buster
MAINTAINER Michael Büchner <m.buechner@dnb.de>

ARG DEBIAN_FRONTEND=noninteractive
ENV CANTALOUPE_VERSION=5.0.5

# Update packages and install tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless \
        ffmpeg \
        maven \
        curl \
        wget \
        libopenjp2-tools \
        liblcms2-dev \
        libpng-dev \
        libzstd-dev \
        libtiff-dev \
        libjpeg-dev \
        libjpeg62-turbo \
        zlib1g-dev \
        unzip \
        libwebp-dev \
        libimage-exiftool-perl && \
    apt-get -qqy autoremove && apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/*

# Install TurboJpegProcessor dependencies
RUN mkdir -p /opt/libjpeg-turbo/lib
COPY libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib

# Run non privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
WORKDIR /tmp
RUN curl --silent --fail -OL https://github.com/cantaloupe-project/cantaloupe/archive/v$CANTALOUPE_VERSION.zip
RUN unzip v$CANTALOUPE_VERSION.zip

WORKDIR /tmp/cantaloupe-$CANTALOUPE_VERSION/
RUN sed -i 's|context.setContextPath("/");|context.setContextPath(System.getenv("PATH_PREFIX") != null ? System.getenv("PATH_PREFIX") : "/");|g' src/main/java/edu/illinois/library/cantaloupe/ApplicationServer.java
RUN sed -i 's|= "/iiif/1";|= "/1";|g' src/main/java/edu/illinois/library/cantaloupe/resource/Route.java
RUN sed -i 's|= "/iiif/2";|= "/2";|g' src/main/java/edu/illinois/library/cantaloupe/resource/Route.java
RUN sed -i 's|= "/iiif/3";|= "/3";|g' src/main/java/edu/illinois/library/cantaloupe/resource/Route.java
ENV MAVEN_OPTS=-Xmx1G
RUN mvn package -Dmaven.test.skip=true
RUN mv target/cantaloupe-$CANTALOUPE_VERSION.zip /

WORKDIR /
RUN unzip cantaloupe-$CANTALOUPE_VERSION.zip 
RUN rm cantaloupe-$CANTALOUPE_VERSION.zip 
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe 
RUN chown -R cantaloupe /cantaloupe-$CANTALOUPE_VERSION /var/log/cantaloupe /var/cache/cantaloupe 
RUN cp -rs /cantaloupe-$CANTALOUPE_VERSION/deps/Linux-x86-64/* /usr/

RUN rm -rf /tmp/*
COPY cantaloupe.properties cantaloupe-$CANTALOUPE_VERSION/
RUN chmod 644 /cantaloupe-$CANTALOUPE_VERSION/cantaloupe.properties

USER cantaloupe

EXPOSE 8182
CMD ["sh", "-c", "java -Xms512M -Xmx2G -Dcantaloupe.config=/cantaloupe-$CANTALOUPE_VERSION/cantaloupe.properties -jar /cantaloupe-$CANTALOUPE_VERSION/cantaloupe-$CANTALOUPE_VERSION.jar"]
