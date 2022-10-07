#!/bin/bash -e
set -p pipefail

CALLED_NAME=$(basename "${BASH_SOURCE[0]}")
RESOLVED_NAME=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

LOG_DIR=$HOME/.local/logs
LOG_FILE="${LOG_DIR}/${CALLED_NAME}.log"
mkdir -p "$LOG_DIR"

APPIMAGE_LIB=$HOME/.local/appimage
IMAGE=$APPIMAGE_LIB/$CALLED_NAME/$CALLED_NAME-latest

check_link() {
    local link_target link_name link_path="$1"
    link_target=$(readlink -f "$link_path")
    link_name=$(basename "$link_path")
    if [[ -L "$link_path" ]]; then
        if [[ ! -e "$link_target" ]]; then
            # if broken link (appimage updated itself in place), change link to point to new version
            link_dir=$(dirname "$link_target")
            latest_app=$(grep -vw "$link_name" "$link_dir/"* | xargs -l basename | sort -rV | head -1)
            if [[ -z $latest_app ]]; then
                echo "Error: no appimage found in $link_dir"
                exit 1
            fi
            ln -sf "$link_name" "$link_dir/$latest_app"
        fi
    else
        echo "Error: $link_path is not a link"
        return 1
    fi
}

# run_app.sh some.AppImage
if [[ "$CALLED_NAME" == "$RESOLVED_NAME" ]]; then
    echo "Error: must run as a symlink or with the path to the appimage as an argument"
    exit 1
else
    check_link "$IMAGE"
fi

exec "$IMAGE" "$@" &>>"$LOG_FILE"
