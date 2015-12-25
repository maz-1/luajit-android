#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

source $_basedir/../../env.sh
source $_basedir/../env.sh

#mkdir -p $_basedir/bin

for ARCH in arm arm64 mips mips64 x86 x86_64
do
    mkdir -p $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/{lunit,lunitx}
    cat $_basedir/src/lua/lunit.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/lunit.lua
    cat $_basedir/src/lua/lunit/console.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/lunit/console.lua
    cat $_basedir/src/lua/lunitx.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/lunitx.lua
    cat $_basedir/src/lua/lunitx/atexit.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/lunitx/atexit.lua
    
done

