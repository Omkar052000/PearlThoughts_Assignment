# Use the official Node.js image
FROM node:14

# Create and change to the app directory
WORKDIR /app

# Copy application files
COPY package*.json ./
COPY app.js ./

# Install dependencies
RUN npm install

# Start the app
CMD ["node", "app.js"]
