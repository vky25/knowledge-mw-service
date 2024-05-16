# Stage 1: Base image
FROM docker.io/library/node:8.11-slim@sha256:682383b9e173828b786e3d3513739e9280492d3ea249655b03753dfc3bd0111d as base

# Set maintainer label
LABEL maintainer="Manojvv <manojv@ilimi.in>"

# Stage 2: Build environment
FROM docker.io/circleci/node:8.11.2-stretch@sha256:147dd7f8267b50bb827a9682bcd774c0923e03c82c2a8bbfa303bd36b7304c74 as build

# Update package sources and install required packages
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list && \
    sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends openssl imagemagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m sunbird

# Switch to non-root user
USER sunbird

# Set working directory
WORKDIR /home/sunbird/app

# Copy application code (adjust the source path as necessary)
COPY . .

# Install application dependencies (adjust as necessary for your application)
RUN npm install

# Expose application port (adjust as necessary for your application)
EXPOSE 3000

# Command to run the application (adjust as necessary for your application)
CMD ["npm", "start"]

# Stage 3: Final image
FROM base as final

# Copy files from build stage to final stage
COPY --from=build /home/sunbird/app /home/sunbird/app

# Set working directory in final image
WORKDIR /home/sunbird/app

# Reinstall dependencies to ensure they are production dependencies only
RUN npm install --production

# Expose application port
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
