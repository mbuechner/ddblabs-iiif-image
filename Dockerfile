FROM ubuntu:16.04
ARG ctl_ver=4.1.3
MAINTAINER Michael Büchner <m.buechner@dnb.de>

#
# Ubuntu with Oracle JDK 8
#
RUN apt-get clean && apt-get update -y && apt-get install -y locales wget unzip apt-utils imagemagick
RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get -y install software-properties-common
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN add-apt-repository -y ppa:webupd8team/java
RUN add-apt-repository -y ppa:git-core/ppa

RUN  apt-get -y update && apt-get -y upgrade

RUN apt-get -y install curl wget unzip nano git
RUN apt-get -y install oracle-java8-installer && \
  apt-get -y install oracle-java8-unlimited-jce-policy && \
  apt-get -y install oracle-java8-set-default

# VOLUME /imageroot

# Get and unpack Cantaloupe release archive
RUN wget https://github.com/medusa-project/cantaloupe/releases/download/v${ctl_ver}/Cantaloupe-${ctl_ver}.zip && \
        unzip Cantaloupe-${ctl_ver}.zip && \
        rm Cantaloupe-${ctl_ver}.zip

ENV JAI_PKG jai-1_1_3-lib-linux-amd64 RUN curl -OL http://download.java.net/media/jai/builds/release/1_1_3/$JAI_PKG.tar.gz \
  && tar xvfz /tmp/$JAI_PKG.tar.gz \
  && cp jai-1_1_3/lib/*.jar $JAVA_HOME/jre/lib/ext/ \
  && cp jai-1_1_3/lib/*.so $JAVA_HOME/jre/lib/amd64/ \
  && rm $JAI_PKG.tar.gz \
  && rm -rf jai-1_1_3

COPY cantaloupe.properties cantaloupe-${ctl_ver}

WORKDIR cantaloupe-${ctl_ver}

ENV CTL_VER ${ctl_ver}
EXPOSE 80
CMD ["sh", "-c", "java -Dcantaloupe.config=cantaloupe.properties -Xmx2g -jar cantaloupe-${CTL_VER}.war"]
