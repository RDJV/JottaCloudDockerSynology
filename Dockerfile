FROM ubuntu:latest

# Update packages and install software
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install gnupg2 \
    && apt-get -y install wget apt-transport-https ca-certificates \
    && wget -O - https://repo.jotta.us/public.gpg | apt-key add - \
    && echo "deb https://repo.jotta.us/debian debian main" | tee /etc/apt/sources.list.d/jotta-cli.list \
    && apt-get update \
    && apt-get -y install jotta-cli \
    && apt-get -y install expect \
    && apt-get -y install git

# Add volumes for backup folder and configuration directories
VOLUME ["/config"]
VOLUME ["/backup"]
VOLUME ["/sync"]

# Open port
EXPOSE 14443

#set environment
ENV JOTTA_TOKEN=**None** \
    JOTTA_DEVICE=**None** \
    JOTTA_DEVICE_FOUND=yes \
    JOTTA_SCANINTERVAL=1h \
    JOTTA_INTERVAL_FOLDER=/sync \
    LOCALTIME=Europe/Amsterdam \
    JOTTA_MAXUPLOADS=6 \
    JOTTA_MAXDOWNLOADS=6 \
    JOTTA_DOWNLOADRATE=0 \
    JOTTA_UPLOADRATE=0 \
    PUID=101 \
    PGID=101 \
    JOTTAD_USER=jottad \
    JOTTAD_GROUP=jottad 

RUN git clone https://github.com/RDJV/JottaCloudDockerSynology.git jotta-cli-docker-synology
RUN mkdir -p /usr/local/jottad/
RUN cp entrypoint.sh /usr/local/jottad/entrypoint.sh
RUN chmod +x /usr/local/jottad/entrypoint.sh

# setup container and start service
ENTRYPOINT ["/usr/local/jottad/entrypoint.sh"]