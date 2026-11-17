#!/bin/sh

SHARED_DIR="/shared"
LOCK_FILE="$SHARED_DIR/.lock"

# Генерация случайного идентификатора контейнера 
ID=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-16)


counter=1


exec 9>> "$LOCK_FILE"


current_file=""
cleanup() {
    if [ -n "$current_file" ]; then
        rm -f "$SHARED_DIR/$current_file"
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM

while true; do

    flock -x 9
    filename=""
    i=1
    while [ "$i" -le 999 ]; do
        fname=$(printf "%03d" "$i")
        if [ ! -e "$SHARED_DIR/$fname" ]; then
            filename="$fname"
            echo "$ID $counter" > "$SHARED_DIR/$fname"
            break
        fi
        i=$((i + 1))
    done
    flock -u 9


    if [ -z "$filename" ]; then
       
        sleep 1
        continue
    fi

    current_file="$filename"
    counter=$((counter + 1))

   
    sleep 1

    rm -f "$SHARED_DIR/$filename"
    current_file=""

    sleep 1
done