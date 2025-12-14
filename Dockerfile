# Dockerfile

# Stage 1: Build the Next.js application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and lock files
COPY package.json .
COPY package-lock.json .

# Install dependencies with npm
RUN npm install --legacy-peer-deps

# Copy the rest of the application source code
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Create the production image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies for production
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
RUN npm install --production --legacy-peer-deps

# Copy the built Next.js application from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.mjs .

# Expose the port the app runs on
EXPOSE 3000

# Set the command to start the app
CMD ["npm", "start"]
