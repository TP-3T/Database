FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN yarn install --frozen-lockfile
COPY prisma ./prisma/
RUN yarn prisma generate
COPY . . 
RUN yarn build
EXPOSE 3000
CMD ["node", "dist/main"]