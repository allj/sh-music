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
