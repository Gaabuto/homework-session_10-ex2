# Use the lightweight Node.js 18 image based on Alpine Linux
FROM node:18-alpine
# Set the working directory inside the container
WORKDIR /app
# Set the port the app listens on
ENV PORT=3000
# Copy package.json (and package-lock.json if present) first to cache the dependency layer
COPY package*.json ./
# Install production dependencies only
RUN npm install --omit=dev
# Copy the application source code
COPY server.js ./
# Document that the container listens on port 3000
EXPOSE 3000
# Start the server when the container runs
CMD ["node", "server.js"]
