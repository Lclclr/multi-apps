FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
ENV PORT=8083
EXPOSE 8083
CMD ["node", "index.js"]
