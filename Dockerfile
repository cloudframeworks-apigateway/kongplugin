FROM alpine
MAINTAINER lucienchu<lucienchu@hotmail.com>

ENV openresty_version=1.11.2.1 \
    luarocks_version=2.4.2 \
    dnsmqsq_version=2.76 \
    serf_version=0.8.0

RUN apk update && apk upgrade && \
        apk add git openssl perl make gcc linux-headers libc-dev libpq \
            postgresql-dev pcre-dev zlib-dev zeromq-dev unzip curl postgresql-client && \
        wget -c https://openresty.org/download/openresty-${openresty_version}.tar.gz && \
        wget -c http://luarocks.github.io/luarocks/releases/luarocks-${luarocks_version}.tar.gz && \
        wget -c http://www.thekelleys.org.uk/dnsmasq/dnsmasq-${dnsmqsq_version}.tar.gz && \
        wget -c https://releases.hashicorp.com/serf/${serf_version}/serf_${serf_version}_linux_amd64.zip

WORKDIR /app

# openresty
RUN cd /app && mv /openresty-${openresty_version}.tar.gz . \
    && tar zxvf openresty-${openresty_version}.tar.gz \
    && cd openresty-${openresty_version} \
    && ./configure --prefix=/usr/local/openresty \
       --with-luajit \
       --with-http_ssl_module \
       --with-pcre-jit \
       --with-ipv6 \
       --with-http_gzip_static_module \
       --with-stream \
       --with-http_realip_module \
       --with-stream_ssl_module \
       --with-http_stub_status_module \
       --with-http_postgres_module \
       --with-http_iconv_module \
    && make && make install

# luarocks
RUN cd /app && mv /luarocks-${luarocks_version}.tar.gz . \
    && tar zxvf luarocks-${luarocks_version}.tar.gz \
    && cd luarocks-${luarocks_version} \
    && ./configure \
        --lua-suffix=jit \
        --with-lua=/usr/local/openresty/luajit \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build && make install

# dnsmasq
RUN cd /app && mv /dnsmasq-${dnsmqsq_version}.tar.gz . \
    && tar zxvf dnsmasq-${dnsmqsq_version}.tar.gz \
    && cd dnsmasq-${dnsmqsq_version} \
    && make install

# serf
RUN cd /app && mv /serf_${serf_version}_linux_amd64.zip . \
    && unzip serf_${serf_version}_linux_amd64.zip \
    && mv serf /usr/local/openresty/bin/

RUN luarocks install luasocket 2.0.2 \
    && luarocks install lua-llthreads2 \
    && luarocks install lzmq


COPY . /app/source

RUN cd /app/source && luarocks make
RUN cp /app/source/bin/* /usr/local/bin/ \
    && mv /app/source/config/dnsmasq/dnsmasq.conf /etc/dnsmasq.conf \
    && mv /app/source/config/postgres/* /tmp/ \
    && mv /app/source/docker-entrypoint.sh /tmp/ \
    && rm -rf /app/*


#EXPOSE 7946, 8000, 8001, 8443
CMD ["/bin/sh", "/tmp/docker-entrypoint.sh"]

