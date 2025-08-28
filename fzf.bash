#!/bin/bash

function candidates() {
    find "$PREFIX" -name '*.gpg' | sed -e "s:$PREFIX/::gi" -e 's:.gpg$::gi'
}

function candidate_selector_fzf() {
    query=$1
    candidates | fzf -q "$query" --select-1
}

function usage() {
    echo "Usage: $0 [-s] [-C] [query]"
    exit 1
}

select_only=0
clip=1

while getopts "Cs" o
do
    case "${o}" in
        C)
            clip=0
            ;;
        s)
            select_only=1
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))
query="$@"

res=$(candidate_selector_fzf "$query")
if [ -n "$res" ]; then
    [ $select_only -ne 0 ] && echo "$res" && exit 0

    if [ $clip -eq 1 ]; then
        pass show "$res" | tail -n +2 || exit $?
        pass show -c "$res"
    else
        pass show "$res"
    fi
else
    exit 1
fi
