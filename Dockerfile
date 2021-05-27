FROM debian:jessie

# Disable prompts on apt-get install
ENV DEBIAN_FRONTEND noninteractive
ENV PATH="/usr/local/go/bin:${PATH}"

RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && apt update \
    && apt install -y libreoffice wget poppler-utils vim Imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb /var/cache/apt/*cache.bin \
    && wget --no-check-certificate https://codimd.oss-cn-shanghai.aliyuncs.com/attachment/go1.16.4.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz \
    && wget http://gosspublic.alicdn.com/ossutil/1.7.3/ossutil64 \
    && chmod 755 ossutil64 \
    && echo "[Credentials]\nlanguage=CH\nendpoint=oss-cn-shanghai-internal.aliyuncs.com\naccessKeyID=naccessKeyID\naccessKeySecret=naccessKeySecret\n" > /root/.ossutilconfig

# OSS
WORKDIR /root
# 添加 字体 Go代码
ADD /fonts /root/.config/libreoffice/4/user/fonts
ADD /server /root/server

# 编译go代码
WORKDIR /root/server
RUN GOPROXY=https://goproxy.cn,direct go build main.go



