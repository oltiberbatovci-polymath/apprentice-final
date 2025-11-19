FROM public.ecr.aws/docker/library/node:20-alpine

WORKDIR /app

# Build argument for API URL
ARG VITE_API_URL=http://localhost:5000/api
ENV VITE_API_URL=$VITE_API_URL

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Expose port
EXPOSE 3000

# Start server on port 3000
CMD ["npm", "run", "preview", "--", "--port", "3000", "--host", "0.0.0.0"]

