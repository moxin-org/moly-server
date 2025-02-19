# Moly Server

A local HTTP server that powers the Moly app by providing capabilities for searching, downloading, and running local Large Language Models (LLMs). This server integrates with WasmEdge for model execution and provides an OpenAI-compatible API interface.

## Features

- Search and discover LLM models
- Download and manage model files
- Automatic mirror selection based on region
- Run local LLMs using WasmEdge runtime
- OpenAI-compatible API interface

## Building and Running

1. [Install Rust](https://www.rust-lang.org/tools/install).

2. Obtain the source code for this repository:

```sh
git clone https://github.com/moxin-org/moly-server.git
```

3. Follow the platform-specific instructions below.

### macOS

Install the required WasmEdge WASM runtime:

```sh
curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s -- --version=0.14.1

source $HOME/.wasmedge/env
```

Then use `cargo` to build and run the server:

```sh
cd moly-server
cargo run -p moly-server
```

### Linux

Install the required WasmEdge WASM runtime:

```sh
curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s -- --version=0.14.1

source $HOME/.wasmedge/env
```

> [!IMPORTANT]
> If your CPU does not support AVX512, then you should append the `--noavx` option onto the above command.

To build Moly on Linux, you must install the following dependencies: `openssl`,
`clang`/`libclang`, `binfmt`. On a Debian-like Linux distro (e.g., Ubuntu), run
the following:

```sh
sudo apt-get update
sudo apt-get install libssl-dev pkg-config llvm clang libclang-dev binfmt-support
```

Then use `cargo` to build and run the Moly server:

```sh
cd moly-server
cargo run -p moly-server
```

## Windows (Windows 10, Windows 11 or higher)

1. Install the required WasmEdge WASM runtime from the WasmEdge releases page:
   [`WasmEdge-0.14.1-windows.msi`](https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-windows.msi)

2. Download and extract the appropriate WASI-NN/GGML plugin for your system:

    - For CUDA 11/12:
      [`WasmEdge-plugin-wasi_nn-ggml-cuda-0.14.1-windows-x86_64.zip`](https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-plugin-wasi_nn-ggml-cuda-0.14.1-windows_x86_64.zip)
    - For CPUs with AVX512 support:
      [`WasmEdge-plugin-wasi_nn-ggml-0.14.1-windows-x86_64.zip`](ttps://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-plugin-wasi_nn-ggml-0.14.1-windows_x86_64.zip)
    - Otherwise:
      [`WasmEdge-plugin-wasi_nn-ggml-noavx-0.14.1-windows-x86_64.zip`](ttps://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-plugin-wasi_nn-ggml-noavx-0.14.1-windows_x86_64.zip)

3. Copy the plugin DLL from that archive `.\lib\wasmedge\wasmedgePluginWasiNN.dll` to `Program Files\WasmEdge\lib\`

4. Then use `cargo` to build and run the Moly server:

    ```sh
    cd moly-server
    cargo run -p moly-server
    ```

## Development

To run the server locally:

```bash
cargo run -p moly-server
```

The server will start on the configured port (default: 8765) and log its address.

## Configuration

The server can be configured using the following environment variables:

- `MOLY_SERVER_PORT`: Port number for the HTTP server (default: 8765)
- `MODEL_CARDS_REPO`: Custom repository URL for model cards
- `MOLY_API_SERVER_ADDR`: Custom address for the API server (default: localhost:0)

## API Endpoints

### File Management

- `GET /files` - List all downloaded files
- `DELETE /files/{id}` - Delete a specific file

### Download Management

- `GET /downloads` - List all current downloads
- `POST /downloads` - Start a new download
- `GET /downloads/{id}/progress` - Get download progress
- `POST /downloads/{id}` - Pause a download
- `DELETE /downloads/{id}` - Cancel a download

### Model Management

- `POST /models/load` - Load a model
- `POST /models/eject` - Eject the currently loaded model
- `GET /models/featured` - Get featured models
- `GET /models/search` - Search for models
- `POST /models/v1/chat/completions` - Chat completions endpoint (OpenAI-compatible)
