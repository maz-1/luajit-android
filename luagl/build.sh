#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

source $_basedir/../../env.sh
source $_basedir/../env.sh

#mkdir -p $_basedir/bin

for _ARCH in arm aarch64 mipsel x86 x86_64 #mips64el
do
    case $_ARCH in 
    arm)
        ARCH=arm
    ;;
    aarch64)
        ARCH=arm64
    ;;
    mipsel)
        ARCH=mips
    ;;
    mips64el)
        ARCH=mips64
    ;;
    x86)
        ARCH=x86
    ;;
    *)
        ARCH=x86_64
    ;;
    esac
    
    if [[ -f $_basedir/lock ]] ; then
        [[ -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/gl.so ]] && continue
    fi
    
    touch $_basedir/lock
    mkdir -p $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/
    
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    export PATH="${_PATH}:$PATH"
    CC="${CROSS_COMPILE}-gcc"
    FLAGS="--sysroot=${PLATFORM}/arch-${ARCH} -g -O2 -fPIC -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast -I$_basedir/../${LUA_SRC}/src/src"
    
    CMD="$CC $FLAGS src/luagl.c -c -o src/luagl.o"
    echo $CMD
    $CMD || break
    CMD="$CC $FLAGS src/luagl_const.c -c -o src/luagl_const.o"
    echo $CMD
    $CMD || break
    CMD="$CC $FLAGS src/luagl_util.c -c -o src/luagl_util.o"
    echo $CMD
    $CMD || break
    #CMD="$CC $FLAGS src/luaglu.c -c -o src/luaglu.o"
    #echo $CMD
    #$CMD || break
    CMD="$CC $FLAGS src/compat-5.3.c -c -o src/compat-5.3.o"
    echo $CMD
    $CMD || break
    CMD="$CC $FLAGS src/luagl.o src/luagl_const.o src/luagl_util.o src/compat-5.3.o -shared -lGLESv1_CM -ldl -llog -o $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/gl.so"
    echo $CMD
    $CMD || break
    rm -f src/*.o
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/gl.so
    
    #mkdir -p $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    #cat lua/import.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/import.lua
    
    #mkdir -p $_basedir/../_BINARY/${ARCH}/framework
    #rm -f $_basedir/../_BINARY/${ARCH}/framework/luajava.jar
    #cp java/luajava.jar $_basedir/../_BINARY/${ARCH}/framework/
    
    rm $_basedir/lock
    
done

