#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir



source $_basedir/../env.sh


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
        [[ -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/mime/core.so ]] && continue
    fi
    
    touch $_basedir/lock
    
    
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    
    export _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    export CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    export HOSTMACH=$(echo ${TOOLCHAIN} | grep -oP '\S+(?=-\d\.\d$)')
    export BUILDMACH=$(uname -m)-unknown-linux-gnu
    export PATH="${_PATH}:$PATH"
    _CC="ccache ${CROSS_COMPILE}-gcc --sysroot=${PLATFORM}/arch-${ARCH}" 
    _CXX="ccache ${CROSS_COMPILE}-g++ --sysroot=${PLATFORM}/arch-${ARCH}"
    _LD=${CROSS_COMPILE}-ld
    export AS=${CROSS_COMPILE}-as
    export _CFLAGS="-g -O2 -fPIC -I$_basedir/../luajit/src/src -Wall -Wshadow -Wextra -Wimplicit -ggdb3 -fvisibility=hidden "
    #'-DLUASOCKET_API="__attribute__((visibility(\"default\")))" -DNODEBUG -DUNIX_API="__attribute__((visibility(\"default\")))" -DMIME_API="__attribute__((visibility(\"default\")))" '
    export _CXXFLAGS="$_CFLAGS"
    #export LDFLAGS="-g -O2 -fPIC"
    export CC="ccache ${CROSS_COMPILE}-gcc --sysroot=${PLATFORM}/arch-${ARCH} "
    
    rm -rf $_basedir/build
    cp -r $_basedir/src $_basedir/build
    cd $_basedir/build
    make PREFIX=/system CC_linux="${_CC}" CFLAGS_linux="${_CFLAGS}" LD_linux="${_CC} -g -O2 -fPIC" || break

    
    mkdir -p $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket
    cat ./src/mime.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/mime.lua
    cat ./src/socket.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket.lua
    cat ./src/ltn12.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/ltn12.lua
    
    cat ./src/ftp.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket/ftp.lua
    cat ./src/headers.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket/headers.lua
    cat ./src/http.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket/http.lua
    cat ./src/smtp.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket/smtp.lua
    cat ./src/tp.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket/tp.lua
    cat ./src/url.lua > $_basedir/../_BINARY/${ARCH}/share/lua/${LUA_VERSION}/socket/url.lua
    
    rm -rf $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/{mime,socket}
    mkdir -p $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/{mime,socket}
    
    cp ./src/mime.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/mime/core.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/mime/core.so
    cp ./src/socket.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/socket/core.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/socket/core.so
    cp ./src/serial.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/socket/serial.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/socket/serial.so
    cp ./src/unix.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/socket/unix.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/socket/unix.so
    
    rm $_basedir/lock
    
done


rm -rf $_basedir/libs
rm -rf $_basedir/build
