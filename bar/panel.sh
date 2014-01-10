#!/bin/bash

# todo: fontello icons

# disable path name expansion or * will be expanded in the line
# cmd=( $line )
set -f

function uniq_linebuffered() {
    awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}
function get_mpd_song() {
    # use mpc to get currently playing song, uppercase it
    song=$(mpc current -h $HOME/.mpdsock -f %title%)
    # let's skip ft. parts, etc. to get some more space
    echo -n $song | sed 's/\(.*\)/\U\1/' | sed 's/(.*//' | sed 's/ -.*//' | sed 's/ $//'
}

monitor=${1:-0}

separator="\f0  |  \fr"
song=$(get_mpd_song)

herbstclient pad $monitor 18
{
    # events:
    # mpc events
    mpc -h $HOME/.mpdsock idleloop player &
    mpc_pid=$!

    # date
    while true ; do
        date="date $(date +'%A %e.' | tr '[:lower:]' '[:upper:]') \\\\f2$(date +'%H:%M')"
        echo $date
        sleep 1 || break
    done > >(uniq_linebuffered) &
    date_pid=$!

    # hlwm events
    herbstclient --idle

    # exiting; kill stray event-emitting processes
    kill $date_pid $mpd_pid
} | {
    TAGS=( $(herbstclient tag_status $monitor) )
    unset TAGS[${#TAGS[@]}-1]
    visible=true

    while true ; do
        echo -n "\l"
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#') # current tag
                    echo -n "\u2\f1\br"
                    ;;
                '+') # active on other monitor
                    echo -n "\u3\fr\br"
                    ;;
                ':')
                    echo -n "\ur\f1\br"
                    ;;
                '!') # urgent tag
                    echo -n "\u1\f1\b6"
                    ;;
                *)
                    echo -n "\ur\f2\br"
                    ;;
            esac
            echo -n "  ${i:1}  " | tr '[:lower:]' '[:upper:]'
        done
        # align left
        echo -n "\l"
        # display song and separator only if something's playing
        if [[ $song ]]; then
            echo -n "\ur\fr  $song$separator"
        fi

        # align right
        echo -n "\r\ur\fr\br"
        echo -n "$separator"
        echo -n "$date  "
        echo
        # wait for next event
        read line || break
        cmd=( $line )
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                TAGS=( $(herbstclient tag_status $monitor) )
                unset TAGS[${#TAGS[@]}-1]
                ;;
            date)
                date="${cmd[@]:1}"
                ;;
            player)
                song=$(get_mpd_song)
                ;;
            quit_panel)
                exit
                ;;
            reload)
                exit
                ;;
        esac
    done
} | ~/.config/bar/bar  
