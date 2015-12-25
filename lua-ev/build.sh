#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

source $_basedir/../../env.sh
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
        [[ -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/ev.so ]] && continue
    fi
    
    touch $_basedir/lock
    rm -rf $_basedir/build
    #cp -r $_basedir/external/oniguruma $_basedir/build
    mkdir -p $_basedir/build
    cd $_basedir/build
    
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    
    export _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    export CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    export HOSTMACH=$(echo ${TOOLCHAIN} | grep -oP '\S+(?=-\d\.\d$)')
    export BUILDMACH=$(uname -m)-unknown-linux-gnu
    export PATH="${_PATH}:$PATH"
    export CC="${CROSS_COMPILE}-gcc" 
    export CXX="${CROSS_COMPILE}-g++"
    export LD=${CROSS_COMPILE}-ld
    export AS=${CROSS_COMPILE}-as
    export CFLAGS=" --sysroot=${PLATFORM}/arch-${ARCH} -g -O2 -fPIC -I$_basedir/../${INCLUDE_PATH} -I$_basedir/../luajit/src/src -L$_basedir/../${LIBRARY_PATH}/${ARCH}"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-g -O2 -fPIC -lm"
    
    rm -rf $_basedir/libs
    cmake $_basedir/src \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=$_basedir/libs \
            -DLIB_INSTALL_DIR=lib \
            -DCMAKE_C_COMPILER="${CC}" \
            -DCMAKE_C_FLAGS="${CFLAGS}" \
            -DCMAKE_EXE_LINKER_FLAGS="${CFLAGS}"
            
        
    make VERBOSE=1 -j4 || break
    
    

    rm -f $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/ev.so 
    mkdir -p $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/
    cp ./ev.so $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/ev.so
    ${CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/lua/${LUA_VERSION}/ev.so
    
    rm $_basedir/lock
    
done


rm -rf $_basedir/libs
rm -rf $_basedir/build
