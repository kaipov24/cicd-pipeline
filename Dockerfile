FROM node:18-alpine
WORKDIR /opt
COPY . /opt
RUN npm install
CMD ["npm", "run", "start"]