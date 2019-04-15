FROM openjdk:8-jdk-alpine

LABEL de.mindrunner.android-docker.flavour="alpine-standalone"

ARG GLIBC_VERSION="2.28-r0"

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux
ENV ANDROID_NDK_HOME /opt/android-ndk

# Install Required Tools
RUN apk -U update && apk -U add \
  bash \
  ca-certificates \
  curl \
  expect \
  git \
  make \
  libstdc++ \
  libgcc \
  su-exec \
  ncurses \
  unzip \
  wget \
  zlib \
  && wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk \
	&& apk add /tmp/glibc.apk /tmp/glibc-bin.apk \
  && rm -rf /tmp/* \
	&& rm -rf /var/cache/apk/*

# Create android User
RUN mkdir -p /opt/android-sdk-linux \
  && addgroup android \
  && adduser android -D -G android -h /opt/android-sdk-linux -u 1000
  
RUN mkdir /opt/android-ndk-tmp
RUN cd /opt/android-ndk-tmp && wget -q http://dl.google.com/android/repository/android-ndk-r16b-linux-x86_64.zip
# uncompress
RUN cd /opt/android-ndk-tmp && unzip -q ./android-ndk-r16b-linux-x86_64.zip -d /opt/android-ndk
# move to it's final location
RUN cd /opt/android-ndk && mv ./android-ndk-r16b /opt/android-ndk
# remove temp dir
RUN rm -rf /opt/android-ndk-tmp
# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}  
  
COPY tools /opt/tools
COPY licenses /opt/licenses

# Working Directory
WORKDIR /opt/android-sdk-linux
