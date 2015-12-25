#!/bin/sh
_basedir=$(cd `dirname $0`;pwd)
cd $_basedir

source ../env.sh

#mkdir -p $_basedir/bin

for _ARCH in arm aarch64 mipsel x86 x86_64 # mips64el 
do
    case $_ARCH in 
    arm)
        ARCH=arm
        _EXTRAFLAGS="-fPIC -march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
        _HOST_CC="gcc -m32"
    ;;
    aarch64)
        ARCH=arm64
        _EXTRAFLAGS="-fPIC"
        _HOST_CC="gcc"
    ;;
    mipsel)
        ARCH=mips
        _EXTRAFLAGS="-fPIC"
        _HOST_CC="gcc -m32"
    ;;
    mips64el)
        ARCH=mips64
        _EXTRAFLAGS="-fPIC"
        _HOST_CC="gcc"
    ;;
    x86)
        ARCH=x86
        _EXTRAFLAGS="-fPIC"
        _HOST_CC="gcc -m32"
    ;;
    *)
        ARCH=x86_64
        _EXTRAFLAGS="-fPIC"
        _HOST_CC="gcc"
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
        [[ -f $_basedir/../_BINARY/${ARCH}/xbin/luajit ]] && continue
    fi
    
    touch $_basedir/lock
    rm -rf $_basedir/build
    cp -r $_basedir/src $_basedir/build
    cd $_basedir/build
    TOOLCHAIN=$(ls ${NDK_TOOLCHAINS} | grep -P "^${_ARCH}(-\\S+-|-)\\d\\.\\d" | tail -1)
    
    _PATH="${NDK_TOOLCHAINS}/${TOOLCHAIN}/prebuilt/linux-$(uname -m)/bin"
    _CROSS_COMPILE=$(ls ${_PATH} | grep -oP '\S+(?=-gcc)' | head -1)
    _CROSS="${_CROSS_COMPILE}-"
    _FLAGS="--sysroot=${PLATFORM}/arch-${ARCH}"
    _EXTRAFLAGS="${_EXTRAFLAGS} -Wl,--dynamic-linker=${LINKER} -Wl,--gc-sections -Wl,-z,nocopyreloc -no-canonical-prefixes -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now"
    export PATH="${_PATH}:$PATH"
    
    echo "============${ARCH}===============" # -L$_basedir/../${LIBRARY_PATH}/${ARCH}
    make HOST_CC="${_HOST_CC}" CROSS=${_CROSS} TARGET_FLAGS="${_FLAGS} ${_EXTRAFLAGS}" PREFIX=/system \
        BUILDMODE=mixed \
        && rm -f $_basedir/lock || break
    rm -f $_basedir/../_BINARY/${ARCH}/xbin/luajit $_basedir/../_BINARY/${ARCH}/lib/libluajit.so
    mkdir -p $_basedir/../_BINARY/${ARCH}/xbin $_basedir/../_BINARY/${ARCH}/lib
    cp ./src/luajit.pie $_basedir/../_BINARY/${ARCH}/xbin/luajit.pie
    cp ./src/luajit $_basedir/../_BINARY/${ARCH}/xbin/luajit
    cp ./src/libluajit.so $_basedir/../_BINARY/${ARCH}/lib/libluajit.so
    cp ./src/libluajit.a $_basedir/../_EXTERNAL/_SHARED/lib/${ARCH}/libluajit.a
    ${_CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/xbin/luajit
    ${_CROSS_COMPILE}-strip $_basedir/../_BINARY/${ARCH}/lib/libluajit.so
done

rm -rf $_basedir/build
