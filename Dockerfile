FROM ubuntu:16.04

MAINTAINER Julian Raj Manandhar "julianrajman@gmail.com"

# Install java7
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  (echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
  apt-get update && \
  apt-get install -y oracle-java7-installer && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV JAVA7_HOME /usr/lib/jvm/java-7-oracle

# Install java8
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV JAVA8_HOME /usr/lib/jvm/java-8-oracle

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl libqt5widgets5 && apt-get clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install unzip to extract zip file
RUN apt-get update && \
  apt-get install unzip

# Install Android SDK
RUN cd /opt && mkdir android-sdk-linux
RUN cd /opt/android-sdk-linux &&  wget --output-document=tools.zip https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
  unzip tools.zip && \
  rm -f tools.zip && \
  cd /opt && chown -R root.root android-sdk-linux

# Copy install tools
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN ["chmod", "+x", "/opt/tools/android-accept-licenses.sh"]
RUN ["chmod", "+x", "/opt/tools/android-wait-for-emulator.sh"]

# Update SDK tools
RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose build-tools;25.0.2"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose platform-tools"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose platforms;android-25"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose tools"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose patcher;v4"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose extras;android;m2repository"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose extras;google;m2repository"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose system-images;android-25;google_apis;x86_64"

RUN /opt/tools/android-accept-licenses.sh "/opt/android-sdk-linux/tools/bin/sdkmanager --verbose update"

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN which adb
RUN which android


# Create emulator
RUN /opt/android-sdk-linux/tools/bin/avdmanager create avd -f -n "Test" -d "Nexus 5" -k "system-images;android-25;google_apis;x86_64" -g "google_apis" -c 512M

# Cleaning
RUN apt-get clean

# GO to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace