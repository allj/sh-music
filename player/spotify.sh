SPOTIFY_DEST="org.mpris.MediaPlayer2.spotify"
SPOTIFY_PATH="/org/mpris/MediaPlayer2"
SPOTIFY_MEMB="org.mpris.MediaPlayer2"

playerRun() {
  spotify > /dev/null 2>&1
}

playerPlay() {
  xargs -I % dbus-send --print-reply --dest=$SPOTIFY_DEST $SPOTIFY_PATH ${SPOTIFY_MEMB}.Player.OpenUri string:% > /dev/null
}

playerQueue() {
  echo 'error: not implemented for spotify' >&2
}

playerTogglePause() {
  dbus-send --print-reply --dest=$SPOTIFY_DEST $SPOTIFY_PATH ${SPOTIFY_MEMB}.Player.PlayPause > /dev/null
}

playerNext() {
  dbus-send --print-reply --dest=$SPOTIFY_DEST $SPOTIFY_PATH ${SPOTIFY_MEMB}.Player.Next > /dev/null
}

playerPrevious() {
  dbus-send --print-reply --dest=$SPOTIFY_DEST $SPOTIFY_PATH ${SPOTIFY_MEMB}.Player.Previous > /dev/null
}

playerStop() {
  dbus-send --print-reply --dest=$SPOTIFY_DEST $SPOTIFY_PATH ${SPOTIFY_MEMB}.Player.Stop > /dev/null
}

playerSeek() {
  echo 'error: not implemented for spotify' >&2
}

# Copied from here: https://gist.github.com/wandernauta/6800547
playerNowPlaying() {
  dbus-send                                                                   \
  --print-reply                                  `# We need the reply.`       \
  --dest=$SPOTIFY_DEST                                                        \
  $SPOTIFY_PATH                                                               \
  org.freedesktop.DBus.Properties.Get                                         \
  string:"$SP_MEMB" string:'Metadata'                                         \
  | grep -Ev "^method"                           `# Ignore the first line.`   \
  | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' `# Filter interesting fiels.`\
  | sed -E '2~2 a|'                              `# Mark odd fields.`         \
  | tr -d '\n'                                   `# Remove all newlines.`     \
  | sed -E 's/\|/\n/g'                           `# Restore newlines.`        \
  | sed -E 's/(xesam:)|(mpris:)//'               `# Remove ns prefixes.`      \
  | sed -E 's/^"//'                              `# Strip leading...`         \
  | sed -E 's/"$//'                              `# ...and trailing quotes.`  \
  | sed -E 's/"+/|/'                             `# Regard "" as seperator.`  \
  | sed -E 's/ +/ /g'                            `# Merge consecutive spaces.`\
  | column -n -t -s '|'
}

playerListQueue() {
  echo 'error: not implemented for spotify' >&2
}

playerVolume() {
  echo 'error: not implemented for spotify' >&2
}

playerQuit() {
  dbus-send --print-reply --dest=$SPOTIFY_DEST $SPOTIFY_PATH ${SPOTIFY_MEMB}.Quit > /dev/null
}

playerPid() {
  ps -e -o comm,pid | grep -m 1 spotify | grep -P -o '[0-9]+'
}

playerPath() {
  which spotify
}
