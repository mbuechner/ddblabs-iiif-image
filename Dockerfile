FROM openjdk:8
ARG ctl_ver=4.1.4
MAINTAINER Michael Büchner <m.buechner@dnb.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean
RUN apt-get update -y 
RUN apt-get -y upgrade
RUN apt-get -y install dialog apt-utils software-properties-common \
	locales imagemagick wget unzip curl wget unzip nano
	
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US.UTF-8
# ENV LC_ALL en_US.UTF-8

# VOLUME /imageroot

# Get and unpack Cantaloupe release archive
RUN wget https://github.com/medusa-project/cantaloupe/releases/download/v${ctl_ver}/Cantaloupe-${ctl_ver}.zip \
  && unzip Cantaloupe-${ctl_ver}.zip \
  && rm Cantaloupe-${ctl_ver}.zip

ENV JAI_PKG jai-1_1_3-lib-linux-amd64
RUN wget -q -O - "http://download.java.net/media/jai/builds/release/1_1_3/$JAI_PKG.tar.gz" | \
  tar xz -C /tmp \
  && cp /tmp/jai-1_1_3/lib/*.jar $JAVA_HOME/jre/lib/ext/ \
  && cp /tmp/jai-1_1_3/lib/*.so $JAVA_HOME/jre/lib/amd64/

RUN rm -rf /tmp/*

COPY cantaloupe.properties cantaloupe-${ctl_ver}

WORKDIR cantaloupe-${ctl_ver}

ENV CTL_VER ${ctl_ver}
EXPOSE 80
CMD ["sh", "-c", "java -Dcantaloupe.config=cantaloupe.properties -Xmx2g -jar cantaloupe-${CTL_VER}.war"]
