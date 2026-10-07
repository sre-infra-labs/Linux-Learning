exception_list="git-exception-list.txt"

for REPO_DIR in */; do

    REPO_DIR="${REPO_DIR%/}"

    # Skip if repository is in exception list
    if grep -Fxq "$REPO_DIR" "$exception_list"; then
        echo "Skipping: $REPO_DIR"
        continue
    fi

    echo
    echo "**** working on __ $REPO_DIR __"

    git -C "$REPO_DIR" pull
    git -C "$REPO_DIR" branch
    git -C "$REPO_DIR" status

    echo

done