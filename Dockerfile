FROM node:lts-buster

WORKDIR /app
COPY package.json .
COPY setup /
RUN /setup
COPY yarn.lock .
RUN yarn
COPY . .
ENV PORT=8080
EXPOSE 8080
CMD ["./start"]
