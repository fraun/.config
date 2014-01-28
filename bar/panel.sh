#!/bin/bash

# todo: fontello icons

# disable path name expansion or * will be expanded in the line
# cmd=( $line )
set -f
#mcptime=$(mpc | grep ^'\[p.*]' | tr ' ' '\012 ' | grep :)
function uniq_linebuffered() {
    awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}
function get_mpd_song() {
    # use mpc to get currently playing song, uppercase it
    song=$(mpc current)
    mpcvol=$(mpc volume | sed 's/://g' | sed 's/v/V/g' | sed 's/%/ %/g' | sed 's/e1/e 1/g' | cut -c -11)
    mpcpaus=$(mpc | grep "paused")

    #mcptime=$(mpc | grep ^'\[p.*]' | tr ' ' '\012 ' | grep :)
# let's skip ft. parts, etc. to get some more space
    #echo -n $song
    if [[ $mpcpaus ]]; then
	echo -ne "ç "
    else
	echo -ne "æ "
    fi

    echo -n $song
#    echo -n " - "
   # echo -ne $mpctime
    
}

pw=$(less ~/pw.safe)

function get_mail() {

    
    count=$(curl -u gday1992@gmail.com:$pw --silent "https://mail.google.com/mail/feed/atom" | perl -ne 'print "\t" if //; print "$2\n" if /<(title|name)>(.*)<\/\1>/;' | wc -l)
    #echo "$count"
    count=$(expr $count - 1)
    count=$(expr $count / 2)
    #fin="$count"
    echo -n $count
}


monitor=${1:-0}
volume=$(amixer get Master -M | grep -oE "[[:digit:]]*%")
separator="\f0  |  \fr"
song=$(get_mpd_song)
mcptime=$(mpc | grep ^'\[p.*]' | tr ' ' '\012 ' | grep :)
gcount=$(get_mail)
herbstclient pad $monitor 18
{
    # events:
    # mpc events
    mpc idleloop player &
    mpc_pid=$!


#    while true ; do
#	count=$(get_mail)
#	echo $count
#	sleep 100 || break
 #   done



    # date
    while true ; do
        date="date $(date +'%A %e.%m.%Y. ' | tr '[:lower:]' '[:upper:]') \\\\f2$(date +'%H:%M:%S')"
	 
	mcptime=$(mpc | grep ^'\[p.*]' | tr ' ' '\012 ' | grep :)
	volume=$(amixer get Master -M | grep -oE "[[:digit:]]*%")
	#echo $volume
	if [$num -eq 100]; then
	    gcount=$(get_mail)
	    $num=0
	fi
	num=$(expr $num + 1)
        echo $date
	#volume='amixer get Master -M | grep -oE "[[:digit:]]*%"'
	#get_mpd_song
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
        echo -n "\c"
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
            echo -n " ä " | tr '[:lower:]' '[:upper:]'
        done
        # align left
        echo -n "\l"
        # display song and separator only if something's playing
        if [[ $song ]]; then
            echo -n "\ur\fr  $song$separator"
        fi

        # align right
        echo -n "\r\ur\fr\br"
	#echo -n "$mpctime"
	echo -n "$separator"
	echo -n "Ê $gcount"
	echo -n "$separator"
	echo -n "í $volume"
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
		#mcptime=$(mpc | grep ^'\[p.*]' | tr ' ' '\012 ' | grep :)
		volume=$(amixer get Master -M | grep -oE "[[:digit:]]*%")
		gcount=$(get_mail)
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
