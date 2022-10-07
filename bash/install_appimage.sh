#!/bin/bash -e

HERE=$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")
RUNSCRIPT=run_appimage.sh
APPIMAGE_LIB=$HOME/.local/appimage

usage() {
    if [[ -n "$*" ]]; then
        echo "$*"
        echo
    fi
    echo "Usage: $(basename "${BASH_SOURCE[0]}") -n NAME name.AppImage"
    echo
    echo "Options:"
    echo "  -n NAME  Name of the AppImage"
    echo
    exit 1
}

init_appdir() {
    APP_DIR=$APPIMAGE_LIB/$APP_NAME
    if [[ ! -d "$APP_DIR" ]]; then
        mkdir -p "$APP_DIR"
    fi
}

install_app() {
    # shellcheck disable=2153
    filename=$APP_DIR/$(basename "$APP_IMAGE")
    if [[ -f "$filename" ]]; then
        echo "AppImage already installed: $filename"
        return 0
    fi
    cp "$APP_IMAGE" "$filename"
    chmod +x "$filename"
    ln -sf "$(basename "$filename")" "$APP_DIR/$APP_NAME-latest"
    if [[ ! -e "$HERE/$APP_NAME" ]]; then
        ln -s "$RUNSCRIPT" "$HERE/$APP_NAME"
    fi
}

while getopts ':n:h' opt; do
    case "$opt" in
    n)
        APP_NAME=$OPTARG
        ;;
    h)
        usage
        exit 1
        ;;
    :)
        usage "Error: -$OPTARG requires an argument."
        ;;
    *)
        usage "Unknown option: -$OPTARG"
        ;;
    esac
done
shift $((OPTIND - 1))
APP_IMAGE="$*"

if [[ -z "$APP_NAME" ]]; then
    usage "Error: -n NAME is required."
elif [[ -z "$APP_IMAGE" ]]; then
    usage "Error: name.AppImage is required."
elif [[ ! -f "$APP_IMAGE" ]]; then
    usage "Error: $APP_IMAGE does not exist."
fi

init_appdir "$APP_NAME"
install_app
