# Wine xdummy Docker

This repository contains a Docker image for running Windows applications via Wine in a virtual or forwarded X11 display, using `xdummy` for lightweight virtual display support.

## Features

- **Wine Installation**: Installs Wine with configurable version (stable, devel).
- **xdummy Support**: Uses `xdummy` for virtual display in a resource-efficient way.
- **Optional X11 Forwarding**: Supports displaying GUI on host if available.

## Getting Started

### Build the Image

```bash
docker build --build-arg BASE_IMAGE_TAG=20.04 --build-arg WINE_BRANCH=stable -t wine-xdummy:stable-20.04 .
```

### Run the Image

To run the image with host display forwarding:

1. Enable local access to X11:

    ```bash
    xhost +local:root
    ```

2. Run the container, specifying the path to the application:

    ```bash
    docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix wine-xdummy:stable-20.04 winecfg
    ```

3. Revoke the access after use:

    ```bash
    xhost -local:root
    ```

To run without display forwarding, the image will use a virtual display:

```bash
docker run --rm wine-xdummy:stable-20.04 /path/to/windows-app.exe
```

### Additional Configurations

- **BASE_IMAGE_TAG**: Specifies the base Ubuntu version.
- **WINE_BRANCH**: Specifies the Wine branch (`stable`, `devel`, or `staging`).
- **DISPLAY**: Set automatically for X11 forwarding.

## License

This project is licensed under the MIT License.
