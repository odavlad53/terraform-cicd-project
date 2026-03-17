# Stage 2: Production image — only the runtime essentials
FROM node:20-alpine

# Remove unnecessary packages that ship with the base image
RUN apk --no-cache add curl \
    && rm -rf /var/cache/apk/*

# Create a non-root user (security best practice)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only the application file
COPY server.js ./
COPY package.json ./
# Switch to non-root user
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
