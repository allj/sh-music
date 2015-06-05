findFiles() {
  if [ -z "$*" ]
  then
    while read line
    do
      path="`readlink -e "$line"`"
      [ $? -eq 0 ] && echo $path
    done
    return
  fi

  args="$(find "$@" -type f -exec readlink -e '{}' ';' 2>/dev/null)"

  if [ $? -eq 0 ]
  then
    echo "$args" | sort
    return 0
  else
    return 1
  fi
}


libraryList() {
  findFiles "$@" || beet ls -p "$@"
}

libraryListFormatted() {
  S="<%>"
  findFiles "$@" || beet ls -f "\$albumartist$S\$year$S\$album$S\$track$S\$title${S}file://\$path" "$@" | awk "BEGIN { print \"ARTIST${S}YEAR${S}ALBUM${S}TRACK${S}TITLE${S}PATH\" } { print \$0 }" | column -n -t -s "$S"
}

librarySelect() {
  sed -r 's#(PATH|file://)#\x00\1#' | fzf --reverse -e --no-sort --multi --nth=1 --with-nth=1,2,3 --delimiter="\0" | sed -e 's#^.*file://##' -e '/PATH/d'
}

libraryUpdate() {
  beet update "$@"
}

libraryEdit() {
  beet modify "$@"
}

libraryRemove() {
  beet remove "$@"
}

libraryRename() {
  beet move "$@"
}
