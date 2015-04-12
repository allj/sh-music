# Don't create file if no lines are read
tee() {
  read line

  if [ $? -eq 1 ]
  then
    return
  elif [ "$1" = '-a' ]
  then
    shift
    echo $line >> $1
  else
    echo $line > $1
  fi

  echo $line

  while read line
  do
    echo $line >> $1
    echo $line
  done
}


# Fork this
playerRun() {
  FIFO="$MUSIC_TMP_DIR/player/fifo"

  # Cleanup after exit
  trap 'rm -fr "$MUSIC_TMP_DIR"' EXIT

  # Kill process group after interrupt or system shutdown and exit normally
  trap "trap 'exit 0' TERM; kill 0" TERM INT

  # Make tmp data
  mkdir -p "$MUSIC_TMP_DIR/now-playing"
  mkdir -p "$MUSIC_TMP_DIR/player"
  sh -c 'echo $PPID' > "$MUSIC_TMP_DIR/player/pid"
  echo "$(which mpv)" > "$MUSIC_TMP_DIR/player/path"
  mkfifo "$FIFO"

  mpv \
    --idle \
    --quiet \
    --no-video \
    --playing-msg='INFO track ${metadata/track}\nINFO title ${metadata/title}\nINFO artist ${metadata/artist}\nINFO album ${metadata/album}\nINFO date ${metadata/date}\nINFO qindex ${playlist-pos}\nINFO path ${path}\nINFO samplerate ${samplerate}\nINFO bitrate ${audio-bitrate}\nNOTIFY' \
    --input-file="$FIFO" 2> "$MUSIC_TMP_DIR/player/error_log" | \
  while read line
  do
    case "$line" in
      INFO*)
        eval "$(echo $line | sed -r -e 's/^INFO +//' -e 's/\(error\)//g' -e 's#^(\S+) +(.*)#echo "\2" > "$MUSIC_TMP_DIR/now-playing/\1"#')"
        ;;
      NOTIFY*)
        notify-send -i "$MUSIC_NOTIFY_ICON" "`cat "$MUSIC_TMP_DIR/now-playing/title"`" "`cat "$MUSIC_TMP_DIR/now-playing/album" "$MUSIC_TMP_DIR/now-playing/artist"`" > /dev/null 2> /dev/null
        ;;
      *)
        echo "$line" >> "$MUSIC_TMP_DIR/player/log"
        ;;
    esac
  done & # Fork so we can trap interrupt signals while `read line` blocks

  wait
  exit 0
}

playerPlay() {
  tee "$MUSIC_TMP_DIR/queue" | awk '{n++; printf("loadfile \"%s\" %d\n", $0, n==1? 0 : 1)}' > "$MUSIC_TMP_DIR/player/fifo"
}

playerQueue() {
  tee -a "$MUSIC_TMP_DIR/queue" | awk '{ printf("loadfile \"%s\" 1\n", $0) }' > "$MUSIC_TMP_DIR/player/fifo"
}

playerTogglePause() {
  case "$1" in
    yes)
      echo "set pause yes" > "$MUSIC_TMP_DIR/player/fifo"
      ;;
    no)
      echo "set pause no" > "$MUSIC_TMP_DIR/player/fifo"
      ;;
    *)
      echo "cycle pause" > "$MUSIC_TMP_DIR/player/fifo"
      ;;
  esac
}

playerNext() {
  echo "playlist_next" > "$MUSIC_TMP_DIR/player/fifo"
}

playerPrevious() {
  echo "playlist_prev" > "$MUSIC_TMP_DIR/player/fifo"
}

playerStop() {
  echo "stop" > "$MUSIC_TMP_DIR/player/fifo"
}

playerSeek() {
  echo "seek $1" > "$MUSIC_TMP_DIR/player/fifo"
}

playerNowPlaying() {
  if [ -d "$MUSIC_TMP_DIR/now-playing" ]
  then
    if [ $# -lt 1 ]
    then
      for info in "$MUSIC_TMP_DIR/now-playing"/*
      do
        echo "`basename "$info"`: `cat "$info"`"
      done | column -n -t -s :
    else
      for info in $*
      do
        cat "$MUSIC_TMP_DIR/now-playing/$info"
      done
    fi
  fi
}

playerListQueue() {
  [ -f "$MUSIC_TMP_DIR/queue" ] && cat "$MUSIC_TMP_DIR/queue"
}

playerVolume() {
  case "$1" in
    up)
      echo "cycle volume up" > "$MUSIC_TMP_DIR/player/fifo"
      ;;
    down)
      echo "cycle volume down" > "$MUSIC_TMP_DIR/player/fifo"
      ;;
    *)
      echo "set volume $1" > "$MUSIC_TMP_DIR/player/fifo"
      ;;
  esac
}

playerQuit() {
  echo 'quit' > "$MUSIC_TMP_DIR/player/fifo"
}

playerPid() {
  cat "$MUSIC_TMP_DIR/player/pid" 2>/dev/null
}

playerPath() {
  cat "$MUSIC_TMP_DIR/player/path" 2>/dev/null
}
