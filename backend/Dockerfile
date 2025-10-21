FROM node:18

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

# Provide build-time defaults so Prisma "get-config" doesn't fail during `prisma generate`.
# These will be overridden by platform env vars at runtime.
ARG PRISMA_DB_URL="postgresql://user:password@localhost:5432/mydatabase?schema=public"
ARG PRISMA_DB_DIRECT_URL="postgresql://user:password@localhost:5432/mydatabase?schema=public"
ENV DATABASE_URL=${PRISMA_DB_URL}
ENV DATABASE_DIRECT_URL=${PRISMA_DB_DIRECT_URL}

RUN npx prisma generate

# Prevent stray local .env from overriding platform-provided environment variables
RUN rm -f .env || true

RUN npm run build

# Copy and make migration script executable
COPY deploy-migrations.sh /usr/src/app/
RUN chmod +x /usr/src/app/deploy-migrations.sh

EXPOSE 3000

# Use the migration script
CMD ["/usr/src/app/deploy-migrations.sh"]
