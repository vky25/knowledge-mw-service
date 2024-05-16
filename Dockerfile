FROM circleci/node:8.11.2-stretch AS build
MAINTAINER "Manojvv" "manojv@ilimi.in"
USER root
COPY src /opt/content/
WORKDIR /opt/content/
RUN npm install --unsafe-perm

FROM node:8.11-slim
MAINTAINER "Manojvv" "manojv@ilimi.in"
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list \
    && sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends openssl imagemagick \
    && apt-get clean \
    && useradd -m sunbird
USER sunbird
ADD ImageMagick-i386-pc-solaris2.11.tar.gz /home/sunbird
ENV GRAPH_HOME "/home/sunbird/ImageMagick-6.9.3"
ENV PATH "$GRAPH_HOME/bin:$PATH"
ENV MAGICK_HOME "/home/sunbird/ImageMagick-6.9.3"
ENV PATH "$MAGICK_HOME/bin:$PATH"
COPY --from=build --chown=sunbird /opt/content /home/sunbird/mw/content
WORKDIR /home/sunbird/mw/content/
CMD ["node", "app.js"]

