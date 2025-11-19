FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
COPY yarn.lock ./

RUN yarn install --frozen-lockfile

COPY prisma ./prisma/
RUN yarn prisma generate

COPY . . 

RUN yarn build

EXPOSE 3333
ENV PORT=3333

CMD ["node", "dist/src/main"]