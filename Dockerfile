# setup working directory
FROM node:22-slim
WORKDIR /app

# install dependencies
COPY package*.json yarn.lock ./
RUN corepack enable && yarn install --frozen-lockfile

# build from source code
COPY . .
RUN yarn build
RUN npx prisma generate --schema=prisma/schema.prisma

# set the env
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "dist/main.js"]
