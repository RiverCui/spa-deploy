FROM node:18-alpine as builder

# ARG 传入变量
ARG ACCESS_KEY_ID
ARG ACCESS_KEY_SECRET
ARG ENDPOINT
ENV PUBLIC_URL=https://cly-deploy.oss-cn-shenzhen.aliyuncs.com/

WORKDIR /code

# 为了更好的缓存，把它放在前面
# wget 下载 ossutil, -O 指定文件保存位置并重命名，chmod 修改权限
RUN wget http://gosspublic.alicdn.com/ossutil/1.7.7/ossutil64 -O /usr/local/bin/ossutil \
    && chmod 755 /usr/local/bin/ossutil \
    && ossutil config -i $ACCESS_KEY_ID -k $ACCESS_KEY_SECRET -e $ENDPOINT

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json yarn.lock /code/
# 此时，yarn 可以利用缓存，如果 yarn.lock 没有变化，则不会重新安装依赖
RUN yarn

ADD . /code
RUN yarn build && yarn oss:cli

FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder code/build /usr/share/nginx/html