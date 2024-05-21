FROM node:16-alpine as builder

WORKDIR /code

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json yarn.lock /code/
# 此时，yarn 可以利用缓存，如果 yarn.lock 没有变化，则不会重新安装依赖
RUN yarn

ADD public /code/public
ADD src /code/src
RUN yarn build

FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder code/build /usr/share/nginx/html