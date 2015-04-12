#!/bin/sh

echo $$
# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

help() {
  echo "Usage: $(basename $0) command [ args ... ]" >&2
}

. $MUSIC_CONFIG_DIR/config.sh
. $MUSIC_CONFIG_DIR/library/${MUSIC_LIBRARY}.sh
. $MUSIC_CONFIG_DIR/player/${MUSIC_PLAYER}.sh

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

if [ $# -lt 1 ]
then
  help
  exit 1
fi

cmd="$1"
shift


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
  dir)
    echo $MUSIC
    ;;
  help|h)
    help
    ;;
  start)
    echo "Player already running with PID $(playerPid)" 1>&2
    ;;
  *)
    echo "error: invalid command '$cmd'" 1>&2
    ;;
esac

exit 0
