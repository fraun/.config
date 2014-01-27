#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

#fonts
xset +fp /usr/share/fonts/local
xset fp rehash

mpd

feh --bg-fill ~/wall/stag.jpg
#bar scripts

xbindkeys&

#cursor
# default cursor
xsetroot -cursor_name left_ptr &

#set backgnd
sh ~/.wall.sh &

#terminal 
xrdb -load ~/.Xresources

#compton
compton -cb -o0 --vsync opengl

#btsync

#btsync

#urxvt

#keyboard 
setxkbmap -layout gb


# exec gnome-session
# exec startkde
# exec cinnamon-session
# exec awesome
# exec cwm
# set cursor 
# xsetroot -cursor_name left_ptr 
# French keyboard layout 
# setxkbmap -layout gb 
# start xmonad 
# exec xmonad 
#sxhkd &
#[ -e "$PANEL_FIFO" ] && rm "$PANEL_FIFO"
#mkfifo "$PANEL_FIFO"
#exec bspwm -s "$PANEL_FIFO" -p W

# start herbstluftwm in locked mode (it will be unlocked at the end of your
# autostart)
exec herbstluftwm --locked
#terminator

# ...or the Window Manager of your choice



#exec i3











