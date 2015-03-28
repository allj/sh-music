# sh-music
Control music playback with this shell script.

## Requirements

- sh
- [mpv](https://github.com/mpv-player/mpv)
- [beets](https://github.com/sampsyo/beets)
- [fzf](https://github.com/junegunn/fzf)


## Usage

Add `music`, `music-player`, and `music-mpv` to your `$PATH` along with this
`MUSIC=<SOME_DIR>` variable to your environment.

    $ music play [ QUERY | FILES... ]
            queue [ QUERY | FILES... ]
            select [ QUERY | FILES... ]
            list QUERY
            now-playing [ TAG_FIELDS... ]
            edit QUERY
            remove QUERY
            pause ( yes | no | 0..100 )
            seek [-]SECONDS
            next
            prev
            quit
            kill
            volume ( up | down | 0..100 )

If no arguments are given, files are to be passed through stdin.
