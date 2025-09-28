FROM node:18

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN npx prisma generate

RUN npm run build

EXPOSE 3000

# Ensure database schema is up-to-date before starting the server
CMD ["sh", "-c", "npx prisma migrate deploy && npm start"]
