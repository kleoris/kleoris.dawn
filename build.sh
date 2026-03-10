#!/bin/sh

# git clone --branch  chromium/7725 --depth 1 https://dawn.googlesource.com/dawn 
# 
# patch -p1 < install_glfw.patch

export DAWN_SRC=third_party/dawn

build_shared() {
	# -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED \
	export OUT=$DAWN_SRC/out/build_shared
	echo "Building Dawn (shared library)..."
	echo "  Output dir: $OUT"
	echo " "
	mkdir -p $OUT
	cmake -S $DAWN_SRC -B $OUT \
		-DDAWN_ENABLE_INSTALL=ON \
		-DDAWN_FETCH_DEPENDENCIES=ON \
		-DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_TESTING=OFF \
		-DDAWN_USE_GLFW=ON \
		-DDAWN_BUILD_TESTS=OFF \
		-DDAWN_BUILD_BENCHMARKS=OFF \
		-DDAWN_BUILD_SAMPLES=OFF \
		-DDAWN_BUILD_NODE_BINDINGS=OFF \
		-DTINT_BUILD_TESTS=OFF

	cmake --build $OUT -j 14
	echo "Shared build complete!"
}

build_static() {
	# -DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
	export OUT=$DAWN_SRC/out/build_static
	echo "Building Dawn (static library)..."
	echo "  Output dir: $OUT"
	echo " "
	mkdir -p $OUT
	cmake -S $DAWN_SRC -B $OUT \
		-DDAWN_ENABLE_INSTALL=ON \
		-DDAWN_FETCH_DEPENDENCIES=ON \
		-DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_TESTING=OFF \
		-DDAWN_USE_GLFW=ON \
		-DDAWN_BUILD_TESTS=OFF \
		-DDAWN_BUILD_BENCHMARKS=OFF \
		-DDAWN_BUILD_SAMPLES=OFF \
		-DDAWN_BUILD_NODE_BINDINGS=OFF \
		-DTINT_BUILD_TESTS=OFF
		
	cmake --build $OUT -j 14
	echo "Static build complete!"
}

install_library() {
	LIB_KIND="$1"

	if [ -z "${DAWN_ROOT:-}" ]; then
		echo "Error: DAWN_ROOT must be set before running install."
		echo "Example: DAWN_ROOT=$HOME/Developer/dawnlib $0 install -shared"
		exit 1
	fi

	case "$LIB_KIND" in
	shared)
		export OUT=$DAWN_SRC/out/build_shared
		;;
	static)
		export OUT=$DAWN_SRC/out/build_static
		;;
	*)
		echo "Invalid library type for install: $LIB_KIND"
		exit 1
		;;
	esac

	DAWN_ROOT=$DAWN_ROOT/$LIB_KIND
	export OUT=$DAWN_SRC/out/build_static
	echo "Installing Dawn ($LIB_KIND library) to: $DAWN_ROOT"
	mkdir -p $DAWN_ROOT
	cmake --install $OUT --prefix $DAWN_ROOT
	echo "$LIB_KIND library installed to: $DAWN_ROOT"
}

# Parse command line arguments
OPERATION="${1:-}"
LIB_TYPE="${2:-}"

if [ "$OPERATION" = "build" ]; then
	case "$LIB_TYPE" in
	-shared)
		build_shared
		;;
	-static)
		build_static
		;;
	*)
		echo "Usage: $0 build {-shared|-static}"
		exit 1
		;;
	esac
elif [ "$OPERATION" = "install" ]; then
	case "$LIB_TYPE" in
	-shared)
		install_library shared
		;;
	-static)
		install_library static
		;;
	*)
		echo "Usage: $0 install {-shared|-static}"
		exit 1
		;;
	esac
else
	echo "Usage: $0 {build|install} {-shared|-static}"
	echo ""
	echo "Examples:"
	echo "  $0 build -shared    Build Dawn as a shared library"
	echo "  $0 build -static    Build Dawn as a static library"
	echo "  $0 install -shared  Install Dawn shared library"
	echo "  $0 install -static  Install Dawn static library"
	exit 1
fi
