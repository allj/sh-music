#!/bin/sh

if [ -z "$MUSIC" ]
then
  echo 'error MUSIC environment variable not set' >&2
  exit 1
fi

if [ $# -gt 0 ]
then
  cmd="$1"
  shift
fi

case "$cmd" in
  config|c)
    if [ $# -lt 1 ]
    then
      for var in $MUSIC/config/*
      do
        echo $(basename "$var") = $(cat "$var" 2>/dev/null)
      done | column -t -s =

      exit $?
    fi

    var="$1"
    shift

    if [ $# -lt 1 ]
    then
      cat "$MUSIC/config/$var" 2>/dev/null
      exit $?
    else
      echo "$1" > "$MUSIC/config/$var"
      exit $?
    fi

    exit 0
    ;;
esac

LIBRARY="$MUSIC/library/$(cat "$MUSIC/config/library" 2>/dev/null).sh"

if [ ! -f "$LIBRARY" ]
then
  echo 'invalid library' >&2
  exit 1
fi

PLAYER="$MUSIC/player/$(cat "$MUSIC/config/player" 2>/dev/null).sh"

if [ ! -f "$PLAYER" ]
then
  echo 'invalid player' >&2
  exit 1
fi

. "$LIBRARY"
. "$PLAYER"

if [ -z "$(playerPid)" ]
then
  case $cmd in
    start)
      playerRun &
      exit 0
      ;;
    play|play-select|p|ps)
      playerRun &
      sleep 0.1
      ;;
    *)
      echo "Player not running..." 1>&2
      exit 1
      ;;
  esac
fi

case $cmd in
  play|p)
    libraryList "$@" | playerPlay
    ;;
  queue|q)
    libraryList "$@" | playerQueue
    ;;
  select|s)
    libraryListFormatted "$@" | librarySelect
    ;;
  play-select|ps)
    libraryListFormatted "$@" | librarySelect | playerPlay
    ;;
  queue-select|qs)
    libraryListFormatted "$@" | librarySelect | playerQueue
    ;;
  list|ls)
    libraryListFormatted "$@"
    ;;
  list-queue|lq)
    playerListQueue "$@"
    ;;
  update|up)
    libraryUpdate "$@"
    ;;
  edit|ed)
    libraryEdit "$@"
    ;;
  remove|rm)
    libraryRemove "$@"
    ;;
  rename|move|mv)
    libraryRename "$@"
    ;;
  now-playing|np)
    playerNowPlaying "$@"
    ;;
  pause)
    playerTogglePause "$@"
    ;;
  next-song|next)
    playerNext "$@"
    ;;
  previous-song|previous|prev)
    playerPrevious "$@"
    ;;
  seek|sk)
    playerSeek "$@"
    ;;
  volume|vol)
    playerVolume "$@"
    ;;
  stop|st)
    playerStop
    ;;
  exit|quit|x)
    playerQuit
    ;;
  term)
    kill -TERM $(playerPid)
    ;;
  kill)
    kill -KILL $(playerPid)
    ;;
  pid|$)
    playerPid
    ;;
  player)
    playerPath
    ;;
  start)
    echo "Player already running with PID $(playerPid)" 1>&2
    exit 1
    ;;
  *)
    echo "Usage: $(basename $0) command [ args ... ]" >&2
    exit 1
    ;;
esac

exit 0
