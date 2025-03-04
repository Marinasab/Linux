# Use Ubuntu as the base image for a stable Linux environment
FROM ubuntu:20.04

# Set working directory in the container
WORKDIR /app

# Update and install necessary packages (bash, core utilities, awk, sed, etc.)
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    gawk \
    sed \
    && rm -rf /var/lib/apt/lists/*

# Copy the script into the container
COPY q5_menu.sh /app/script.sh

# Make the script executable
RUN chmod +x /app/script.sh

# Set the default command to run the script interactively
CMD ["bash", "/app/script.sh"]
