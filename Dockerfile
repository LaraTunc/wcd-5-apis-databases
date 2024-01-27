FROM node:16-alpine
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install app dependencies
COPY package.json ./
COPY yarn.lock ./
RUN yarn 

# add app
COPY . .

# start app
CMD ["yarn", "start"]

EXPOSE 3000