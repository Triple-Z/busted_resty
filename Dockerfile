FROM openresty/openresty:centos

RUN yum install gcc -y; \
    luarocks install busted; \
    luarocks install busted-htest; \
    luarocks install luacov;

ENTRYPOINT [ "/bin/bash" ]