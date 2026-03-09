# Building Dawn from Source

This guide explains how to build the Dawn GPU API library from a specific branch.

## Prerequisites

- CMake 3.25 or later
- A C++ compiler supporting C++17 (clang, gcc, or MSVC)
- Python 3.10 or later
- Git
- Ninja (recommended) or Make
- Platform-specific dependencies:
  - **macOS**: Xcode Command Line Tools, Metal framework
  - **Linux**: Vulkan SDK, X11 development libraries
  - **Windows**: Visual Studio 2019 or later

## Description

This build was created to facilitate integrating Dawn into the `Kleoris` C++ runtime. The build is optimized for
`Release` and does not build any of the performance/validation tools. 

By default the Dawn `CMake` support lets you build the `Dawn GLFW` bridge (convenience code) via the `DAWN_USE_GLFW`
flag, but it does not install it...

This project contains a patch that will add the ability to install it if `DAWN_ENABLE_INSTALL` has been set to  `ON`.

## Setup

### 1. Clone the Repository

```bash
git clone --branch chromium/7725 --depth 1 https://dawn.googlesource.com/dawn third_party/dawn
```

Replace `chromium/7725` with your desired branch.

### 2. Build Configuration

This project includes two build configurations:

- **Shared Library** (`.dll`, `.so`, `.dylib`)
- **Static Library** (`.a`, `.lib`)

## Building with build.sh

The `build.sh` script automates the build process.

### Usage

```bash
./build.sh {build|install} {-shared|-static}
```

### Examples

#### Build a shared library

```bash
./build.sh build -shared
```

Output directory: `third_party/dawn/out/build_shared`

#### Build a static library

```bash
./build.sh build -static
```

Output directory: `third_party/dawn/out/build_static`

#### Install shared library

Set `DAWN_ROOT` before running install:

```bash
export DAWN_ROOT=$HOME/Developer/dawnlib
./build.sh install -shared
```

The library will be installed to `$DAWN_ROOT/shared/`

#### Install static library

```bash
export DAWN_ROOT=$HOME/Developer/dawnlib
./build.sh install -static
```

The library will be installed to `$DAWN_ROOT/static/`

## Manual Build

If you prefer to build manually without the script:

### Configure

```bash
# For shared library
cmake -S third_party/dawn -B build_shared \
  -DDAWN_ENABLE_INSTALL=ON \
  -DDAWN_FETCH_DEPENDENCIES=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  -DDAWN_USE_GLFW=ON \
  -DDAWN_BUILD_TESTS=OFF \
  -DDAWN_BUILD_BENCHMARKS=OFF \
  -DDAWN_BUILD_SAMPLES=OFF \
  -DDAWN_BUILD_NODE_BINDINGS=OFF \
  -DTINT_BUILD_TESTS=OFF

# For static library, add:
# -DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC
```

### Build

```bash
cmake --build build_shared -j 14
```

## Install

```bash
cmake --install build_shared --prefix /path/to/install/dir
```


## Configuration Options

Common CMake options for Dawn:

| Option | Default | Description |
|--------|---------|-------------|
| `DAWN_BUILD_MONOLITHIC_LIBRARY` | `SHARED` | Build as SHARED or STATIC library |
| `DAWN_ENABLE_INSTALL` | `ON` | Enable installation targets |
| `DAWN_FETCH_DEPENDENCIES` | `ON` | Automatically fetch dependencies |
| `DAWN_USE_GLFW` | `ON` | Include GLFW windowing support |
| `DAWN_BUILD_TESTS` | `OFF` | Build test suite |
| `DAWN_BUILD_SAMPLES` | `OFF` | Build sample applications |
| `CMAKE_BUILD_TYPE` | `Release` | Debug or Release build |

## Troubleshooting

### Missing Dependencies

If the build fails due to missing dependencies, ensure `DAWN_FETCH_DEPENDENCIES=ON` is set during configuration. This will automatically download and build required dependencies.

### Switching Branches

To build from a different branch:

```bash
cd third_party/dawn
git fetch origin
git checkout <branch-name>
cd ../..
```

Then run `./build.sh build -shared` (or `-static`) again.

### Rebuild from Clean State

```bash
rm -rf third_party/dawn/out/*
./build.sh build -shared
```

## Integration with Kleoris

This build is designed to be used with the Kleoris native UI runtime. Set the appropriate `DAWN_ROOT` environment variable when using the library in dependent projects.

## References

- [Dawn Project](https://dawn.googlesource.com/dawn)
- [Dawn Documentation](https://dawn.googlesource.com/dawn/+/refs/heads/main/README.md)
