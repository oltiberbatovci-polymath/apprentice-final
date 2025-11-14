FROM node:20-alpine

WORKDIR /app

# Install OpenSSL and required dependencies for Prisma
RUN apk add --no-cache openssl openssl-dev libc6-compat

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm install

# Generate Prisma Client
RUN npx prisma generate

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 5000

# Start server
CMD ["npm", "start"]

