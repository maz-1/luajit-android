#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

source $_basedir/../../env.sh
source $_basedir/../env.sh

#mkdir -p $_basedir/bin

for ARCH in arm arm64 mips mips64 x86 x86_64
do
    rm -rf $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/pl $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/pl.lua
    mkdir -p $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    cp -r $_basedir/src/lua/pl $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    mv $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/pl/init.lua $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/pl.lua
done

