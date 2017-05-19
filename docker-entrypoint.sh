#!/usr/bin/env bash

mkdir -p /usr/local/openresty/nginx/run

echo "now waiting for network..."
sleep 10

export KONG_SERF_PATH=/usr/local/openresty/bin/serf
export SERF_PATH=/usr/local/openresty/bin/serf
export PATH=$PATH:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

# reset
export RESET=${RESET:-0}
db_init=0
# 传递参数有重新设置，db重置参数复位
if [[ ${RESET} -eq 1 ]]; then
    db_init=1
fi
# db中心设置，删除默认的配置
if [[ ${db_init} -eq 1 ]]; then
    rm -rf /usr/local/kong
fi
# 配置不存在，重新生成配置
if [[ -d /usr/local/kong ]]; then
    echo "config has exist"
else
    echo "need init postgresql"
fi

# 修改配置 /usr/local/kong/kong.conf
export POSTGRESQL_HOST=${POSTGRESQL_HOST:-${POSTGRES_PORT_5432_TCP_ADDR}}
if [[ ! -z "${POSTGRESQL_HOST}" ]]; then
    export POSTGRESQL_USER=${POSTGRESQL_USER:-${POSTGRES_ENV_POSTGRES_USER}}
    export POSTGRESQL_USER=${POSTGRESQL_USER:-postgres}
    export POSTGRESQL_PASS=${POSTGRESQL_PASS:-${POSTGRES_ENV_POSTGRES_PASSWORD}}
    export PGPASSWORD=${POSTGRESQL_PASS}
    export POSTGRESQL_PORT=${POSTGRESQL_PORT:-${POSTGRES_PORT_5432_TCP_PORT}}
    export POSTGRESQL_DB=${POSTGRESQL_DB:-kong}

    # 检查是否连通postgresql
    echo "now try to connect postgresql ..."
    MAXWAIT=${MAXWAIT:-30}
    wait=0
    while [ ${wait} -lt ${MAXWAIT} ]
    do
        echo stat | nc ${POSTGRESQL_HOST} ${POSTGRESQL_PORT}
        if [ $? -eq 0 ];then
            break
        fi
        wait=`expr ${wait} + 1`;
        echo "Waiting postgresql service ${wait} seconds"
        sleep 1
    done
    if [ "${wait}" =  ${MAXWAIT} ]; then
        echo >&2 'kong start failed,please ensure postgresql service has started.'
        exit 1
    fi
    echo "postgresql is ok"

    # 配置app.ini
    sed -i \
        -e "s|{POSTGRESQL_USER}|${POSTGRESQL_USER}|" \
        -e "s|{POSTGRESQL_DB}|${POSTGRESQL_DB}|" \
        /tmp/init.sql
    sed -i -e "s|{POSTGRESQL_DB}|${POSTGRESQL_DB}|" /tmp/checkdb.sql

    pcursor=$(psql -h ${POSTGRESQL_HOST} -U ${POSTGRESQL_USER} -p ${POSTGRESQL_PORT} -f /tmp/checkdb.sql -Ax)
    echo "psql -h ${POSTGRESQL_HOST} -U ${POSTGRESQL_USER} -p ${POSTGRESQL_PORT} -f /tmp/checkdb.sql -Ax"
    db_num=$(echo $pcursor | awk -F '|' '{print $2}')
    if [[ ${db_num} -eq 0 ]]; then
        psql -h ${POSTGRESQL_HOST} -U ${POSTGRESQL_USER} -p ${POSTGRESQL_PORT} -f /tmp/init.sql
        echo "psql -h ${POSTGRESQL_HOST} -U ${POSTGRESQL_USER} -p ${POSTGRESQL_PORT} -f /tmp/init.sql"
    fi

else
    echo "no postgres config.now exit"
    exit 1
fi

# pg config

export PG_SSL=${PG_SSL:-false}
export PG_SSL_VERIFY=${PG_SSL_VERIFY:-false}
sed -i \
    -e "s|pg_ssl = false|pg_ssl = ${PG_SSL}|" \
    -e "s|pg_ssl_verify = false|pg_ssl_verify = ${PG_SSL_VERIFY}|" \
    -e "s|pg_database = kong|pg_database = ${POSTGRESQL_DB}|" \
    -e "s|pg_host = 127.0.0.1|pg_host = ${POSTGRESQL_HOST}|" \
    -e "s|pg_port = 5432|pg_port = ${POSTGRESQL_PORT}|" \
    -e "s|pg_user = kong|pg_user = ${POSTGRESQL_USER}|" \
    -e "s|pg_password = NONE|pg_password = ${POSTGRESQL_PASS}|" \
    /usr/local/share/lua/5.1/kong/templates/kong_defaults.lua

kong start --vv

if [[ "$1" == "sh" ]]; then
    sh
else
    tail -f /usr/local/kong/logs/access.log
fi
