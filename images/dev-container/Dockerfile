FROM alpine:latest

# Update package lists
RUN apk update

RUN apk add --no-cache curl

# Install Epinio CLI
RUN curl -o /usr/local/bin/epinio -L https://github.com/epinio/epinio/releases/download/v1.11.0/epinio-linux-x86_64
RUN chmod +x /usr/local/bin/epinio
RUN export PATH=$PATH:/usr/local/bin