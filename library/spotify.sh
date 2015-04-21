spotifySearch() {
  Q=$(echo "$@" | tr ' ' +)
  curl -s -X GET --data-urlencode "q=$Q" -H "Accept: application/json" "https://api.spotify.com/v1/search?q=$Q&type=track"
}

libraryList() {
  type_=$(echo $1 | grep -P -o '(aritst|album|track)')

  if [ $? -eq 0 ]
  then
    shift
  else
    type_=track
  fi

  spotifySearch "$@" | grep -P -o "spotify:(artist|album|track):[a-zA-Z0-9]+" | grep -m 1 $type_
}

libraryListFormatted() {
  libraryList "$@"
}

libraryUpdate() {
  echo 'error: not implemented for spotify' >&2
}

libraryEdit() {
  echo 'error: not implemented for spotify' >&2
}

libraryRemove() {
  echo 'error: not implemented for spotify' >&2
}

libraryRename() {
  echo 'error: not implemented for spotify' >&2
}
