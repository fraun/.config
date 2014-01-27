#!/bin/bash

function get_mail(){
    count=$(./newmail.sh | wc -l )
    count=$(expr $count - 1)
    count=$(expr $count / 2)
    echo -n $count
}

count=$(get_mail)
echo "$count"
