FROM jenkins/jenkins:lts
USER root
RUN apt-get update -y \
	&& apt-get install -y apt-utils \
    && apt-get install -y uidmap \
    && curl -sSL https://get.docker.com/ | sh \
    && apt-get install -y docker-ce-cli \
    && apt-get clean
USER jenkins