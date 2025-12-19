ARG NODE_VERSION=20
FROM n8nio/base:${NODE_VERSION}

# Railway doesn't always pass ARG during build unless specified. 
# Defaulting to 'latest' if N8N_VERSION is not provided.
ARG N8N_VERSION=latest

USER root

# Install n8n and necessary build tools for sqlite3
RUN set -eux; \
    apk add --update --no-cache python3 make g++ && \
    npm install -g --omit=dev n8n@${N8N_VERSION} && \
    # Clean up to keep image size small
    rm -rf /root/.npm

# Create the data directory and set permissions
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Environment variables for Railway
ENV NODE_ENV=production
ENV N8N_PORT=${PORT:-5678}
ENV N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

USER node
WORKDIR /home/node

# Railway provides the PORT env var; we tell n8n to use it
EXPOSE ${PORT}

# Use a direct command instead of a separate .sh file to avoid "file not found" errors
ENTRYPOINT ["tini", "--"]
CMD ["n8n", "start"]