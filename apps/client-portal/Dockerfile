FROM node:22-alpine

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy everything
COPY . .

# Install deps
RUN pnpm install

# Expose Vite dev server port
EXPOSE 5173

# Default command
CMD ["pnpm", "dev"]