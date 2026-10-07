for REPO_DIR in $(ls); do
  echo
  echo "**** working on __ $REPO_DIR __"
  # git config --global user.name "Ajay Kumar Dwivedi"
  # git config --global user.email "ajay.dwivedi2007@gmail.com"
  git -C "$REPO_DIR" pull
  git -C "$REPO_DIR" branch
  git -C "$REPO_DIR" status
  echo
done

