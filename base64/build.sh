#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

source $_basedir/../../env.sh
source $_basedir/../env.sh

#mkdir -p $_basedir/bin

for ARCH in arm arm64 mips mips64 x86 x86_64
do
    mkdir -p $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    cat $_basedir/base64.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/base64.lua
    
done

