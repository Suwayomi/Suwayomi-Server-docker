FROM eclipse-temurin:21.0.7_6-jre-noble

ARG BUILD_DATE
ARG TACHIDESK_RELEASE_TAG
ARG TACHIDESK_FILENAME
ARG TACHIDESK_RELEASE_DOWNLOAD_URL
ARG TACHIDESK_DOCKER_GIT_COMMIT
ARG TACHIDESK_KCEF=y # y or n

LABEL maintainer="suwayomi" \
      org.opencontainers.image.title="Suwayomi Docker" \
      org.opencontainers.image.authors="https://github.com/suwayomi" \
      org.opencontainers.image.url="https://github.com/suwayomi/docker-tachidesk/pkgs/container/tachidesk" \
      org.opencontainers.image.source="https://github.com/suwayomi/docker-tachidesk" \
      org.opencontainers.image.description="This image is used to start suwayomi server in a container" \
      org.opencontainers.image.vendor="suwayomi" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$TACHIDESK_RELEASE_TAG \
      tachidesk.docker_commit=$TACHIDESK_DOCKER_GIT_COMMIT \
      tachidesk.release_tag=$TACHIDESK_RELEASE_TAG \
      tachidesk.filename=$TACHIDESK_FILENAME \
      download_url=$TACHIDESK_RELEASE_DOWNLOAD_URL \
      org.opencontainers.image.licenses="MPL-2.0"

# Install envsubst from GNU's gettext project
RUN apt-get update && \
    apt-get -y install gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install unzip to unzip the server-reference.conf from the jar
RUN apt-get update && \
    apt-get -y install -y unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install CEF dependencies
# Ubuntu exposes libgluegen_rt.so as libgluegen2_rt.so for some reason, so rename it
# JCEF (or Java?) also does not search /usr/lib/jni, so copy them over into one it will search
RUN if [ "$TACHIDESK_KCEF" = "y" ]; then \
      apt-get update && \
      apt-get -y install --no-install-recommends -y libxss1 libxext6 libxrender1 libxcomposite1 libxdamage1 libxkbcommon0 libxtst6 \
          libjogl2-jni libgluegen2-jni libglib2.0-0t64 libnss3 libdbus-1-3 libpango-1.0-0 libcairo2 libasound2t64 \
          libatk-bridge2.0-0t64 libcups2t64 libdrm2 libgbm1 xvfb && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* || exit 1; \
    fi

# Create a user to run as
RUN userdel -r ubuntu
RUN groupadd --gid 1000 suwayomi && \
    useradd  --uid 1000 --gid suwayomi --no-log-init -G audio,video suwayomi && \
    mkdir -p /home/suwayomi/.local/share/Tachidesk

WORKDIR /home/suwayomi

# Copy the app into the container
RUN curl -s --create-dirs -L $TACHIDESK_RELEASE_DOWNLOAD_URL -o /home/suwayomi/startup/tachidesk_latest.jar
COPY scripts/create_server_conf.sh /home/suwayomi/create_server_conf.sh
COPY scripts/startup_script.sh /home/suwayomi/startup_script.sh

# update permissions of files.
# we grant o+rwx because we need to allow non default UIDs (eg via docker run ... --user)
# to write to the directory to generate the server.conf
RUN chown -R suwayomi:suwayomi /home/suwayomi && \
    chmod 777 -R /home/suwayomi

# .X11-unix must be created by root
# Ubuntu exposes libgluegen_rt.so as libgluegen2_rt.so for some reason, so rename it
# JCEF (or Java?) also does not search /usr/lib/jni, so copy them over into one it will search
RUN if [ "$TACHIDESK_KCEF" = "y" ]; then \
      mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && \
      cp /usr/lib/jni/libgluegen2_rt.so libgluegen_rt.so && \
      cp /usr/lib/jni/*.so ./; \
    fi

USER suwayomi
EXPOSE 4567
ENV TACHIDESK_KCEF=$TACHIDESK_KCEF


CMD ["/home/suwayomi/startup_script.sh"]

# vim: set ft=dockerfile:
