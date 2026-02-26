#!/bin/bash

BASE_DIR="k8s-resources"

# Optional first argument: folder name
TARGET_FOLDER="$1"

if [ -n "$TARGET_FOLDER" ]; then
    SEARCH_DIR="$BASE_DIR/$TARGET_FOLDER"
    if [ ! -d "$SEARCH_DIR" ]; then
        echo "Folder $SEARCH_DIR does not exist."
        exit 1
    fi
else
    read -p "No folder specified. This will run on all folders under $BASE_DIR. Continue? (y/N) " CONFIRM
    case "$CONFIRM" in
        [yY][eE][sS]|[yY]) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
    SEARCH_DIR="$BASE_DIR"
fi

# Loop through all 'secrets' directories under the search directory
find "$SEARCH_DIR" -type d -name "secrets" | while read -r SECRETS_DIR; do
    PARENT_DIR="$(dirname "$SECRETS_DIR")"  # parent folder of 'secrets'

    # Find files ending with -secret.yaml in this directory
    for SECRET_FILE in "$SECRETS_DIR"/*-secret.yaml; do
        # Skip if no files match
        [ -e "$SECRET_FILE" ] || continue

        # Create output file name in the parent folder
        FILE_BASENAME="$(basename "${SECRET_FILE%-secret.yaml}")"
        OUTPUT_FILE="$PARENT_DIR/${FILE_BASENAME}-secret-sealed.yaml"

        # Call kubeseal
        kubeseal -f "$SECRET_FILE" -w "$OUTPUT_FILE"

        echo "Sealed $SECRET_FILE -> $OUTPUT_FILE"
    done
done