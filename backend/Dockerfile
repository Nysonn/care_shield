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

EXPOSE 3000

# Ensure database schema is up-to-date before starting the server
# If DATABASE_DIRECT_URL is not provided by the platform, fall back to DATABASE_URL so Prisma config validation passes
CMD sh -c "export DATABASE_DIRECT_URL=\${DATABASE_DIRECT_URL:-\$DATABASE_URL} && npx prisma migrate deploy && npm start"
