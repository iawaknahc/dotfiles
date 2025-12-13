#!/bin/sh

SOURCE="sandisk:/ssd/louischan"
DEST_REMOTE=googledrive

rclone sync --progress --exclude ".**" "$SOURCE" "$DEST_REMOTE":/data
