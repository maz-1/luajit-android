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
        [[ -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/llthreads.so ]] && continue
    fi
    
    touch $_basedir/lock
    
    
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    
    export _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    export CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    export HOSTMACH=$(echo ${TOOLCHAIN} | grep -oP '\S+(?=-\d\.\d$)')
    export BUILDMACH=$(uname -m)-unknown-linux-gnu
    export PATH="${_PATH}:$PATH"
    #export CC="ccache ${CROSS_COMPILE}-gcc --sysroot=${PLATFORM}/arch-${ARCH}" 
    export CXX="ccache ${CROSS_COMPILE}-g++ --sysroot=${PLATFORM}/arch-${ARCH}"
    export LD=${CROSS_COMPILE}-ld
    export AS=${CROSS_COMPILE}-as
    export CFLAGS="-g -O2 -fPIC"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-g -O2 -fPIC"
    export CC="ccache ${CROSS_COMPILE}-gcc --sysroot=${PLATFORM}/arch-${ARCH} -g -O2 -fPIC -I$_basedir/../luajit/src/src"
    
    rm -rf $_basedir/build
    cp -r $_basedir/src $_basedir/build
    cd $_basedir/build
    make PREFIX=/system || break
    
    

    rm -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/llthreads.so
    mkdir -p $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}
    cp ./llthreads.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/llthreads.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/llthreads.so
    
    mkdir -p $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/llthreads2
    cp $_basedir/src/lua/llthreads2/ex.lua $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/llthreads2
    
    rm $_basedir/lock
    
done



rm -rf $_basedir/libs
rm -rf $_basedir/build
