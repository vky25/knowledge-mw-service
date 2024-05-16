# Stage 1: Base image
FROM node:8.11-slim AS base

# Set maintainer label
LABEL maintainer="Manojvv <manojv@ilimi.in>"

# Stage 2: Build environment
FROM circleci/node:8.11.2-stretch AS build

# Update package sources and install required packages
RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
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
FROM base AS final

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
