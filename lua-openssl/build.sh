#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

printf "\e[31m\e[42m The module will not be built, see README\e[0m\n"
exit 0

source $_basedir/../../env.sh
source $_basedir/../env.sh

#mkdir -p $_basedir/bin

for _ARCH in  arm aarch64 mipsel x86 x86_64 mips64el 
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
        [[ -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/openssl.so ]] && continue
    fi
    
    touch $_basedir/lock
    
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    
    export _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    _CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    #export CROSS_COMPILE="${_CROSS_COMPILE}"
    export HOSTMACH=$(echo ${TOOLCHAIN} | grep -oP '\S+(?=-\d\.\d$)')
    export BUILDMACH=$(uname -m)-unknown-linux-gnu
    export PATH="${_PATH}:$PATH"
    export CFLAGS="-g -O2 -fPIC --sysroot=${PLATFORM}/arch-${ARCH}"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-g -O2 -fPIC --sysroot=${PLATFORM}/arch-${ARCH}"
    export LD=${_CROSS_COMPILE}-ld
    export AS=${_CROSS_COMPILE}-as
    export AR=${_CROSS_COMPILE}-ar
    export CC="ccache ${_CROSS_COMPILE}-gcc --sysroot=${PLATFORM}/arch-${ARCH} -g -O2 -fPIC -I$_basedir/../luajit/src/src -I$_basedir/../${INCLUDE_PATH} -L$_basedir/../${LIBRARY_PATH}/${ARCH} -I$_basedir/src/deps"
    
    rm -rf $_basedir/build
    cp -r $_basedir/src $_basedir/build
    cd $_basedir/build
    make PREFIX=/system  \
        LUAV=5.1 \
        LUA_LIBS="-L$_basedir/../_BINARY/${ARCH}/lib" \
        OPENSSL_LIBS="-lssl -lcrypto" \
        OPENSSL_CFLAGS="" \
        SYS="${HOSTMACH}" \
        || break
        

    rm -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/openssl.so
    mkdir -p $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/ # $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    cp ./openssl.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/openssl.so
    ${_CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/openssl.so
    #cp -r ./lua/nixio $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/
    
    
    rm $_basedir/lock
    
done


rm -rf $_basedir/libs
rm -rf $_basedir/build
