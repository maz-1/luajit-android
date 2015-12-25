#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir


source $_basedir/../env.sh

#mkdir -p $_basedir/bin

for _ARCH in arm aarch64 mipsel mips64el x86 x86_64
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
    
    case $_ARCH in
    aarch64|mips64el|x86_64)
        LINKER=/system/bin/linker64
    ;;
    *)
        LINKER=/system/bin/linker
    ;;
    esac
    
    if [[ -f $_basedir/lock ]] ; then
        [[ -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/alien_c.so ]] && continue
    fi
    
    touch $_basedir/lock
    
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    
    export _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    export CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    #export HOSTMACH=$(echo ${TOOLCHAIN} | grep -oP '\S+(?=-\d\.\d$)')
    export HOSTMACH="${_ARCH}-linux-android"
    
    if [[ ${ARCH} == x86 ]] ; then
        HOSTMACH="i686-linux-android"
    fi
    
    export BUILDMACH=$(uname -m)-unknown-linux-gnu
    export PATH="${_PATH}:$PATH"
    FLAGS="--sysroot=${PLATFORM}/arch-${ARCH} -g -O2 -I$_basedir/../${INCLUDE_ARCH_RELAVANT}/${ARCH} -I$_basedir/../${LUA_SRC}/src/src -L$_basedir/../${LIBRARY_PATH}/${ARCH}"
    export CC="ccache ${CROSS_COMPILE}-gcc ${FLAGS} -fPIC -I$_basedir/../${INCLUDE_ARCH_RELAVANT}/${ARCH} -L$_basedir../${LIBRARY_PATH}/${ARCH}"
    export CXX="ccache ${CROSS_COMPILE}-g++ ${FLAGS} -fPIC"
    export LD=${CROSS_COMPILE}-ld
    export AS=${CROSS_COMPILE}-as
    
    
    rm -rf $_basedir/build
    cp -r $_basedir/src $_basedir/build
    cd $_basedir/build
    
    ./bootstrap
    ./configure --host=${HOSTMACH} --build=$BUILDMACH 
    make || break
    
    #exit 0
    
    rm -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/alien_c.so
    mkdir -p $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/ $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    cp ./src/.libs/alien_c.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/alien_c.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/alien_c.so
    cat src/alien.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/alien.lua
    
    
    rm $_basedir/lock
    
done

rm -rf $_basedir/build
