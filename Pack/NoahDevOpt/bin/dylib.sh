#!/bin/sh

#  dylib.sh
#  InsertDemo
#
#  Created by daye on 2021/1/13.
#  Copyright © 2021 Noah. All rights reserved.

#LOGOS_PL_PATH="/opt/theos/bin/logos.pl"
#TARGET_NAME=${PRODUCT_NAME}
#
#echo "Start to generate ${TARGET_NAME}.mm"
#$LOGOS_PL_PATH "${TARGET_NAME}/${TARGET_NAME}.xm" > "${TARGET_NAME}/${TARGET_NAME}.mm"

TARGET_NAME=${PRODUCT_NAME}

echo "TARGET_NAME:${TARGET_NAME}"

function panic() # args: exitCode, message...
{
    local exitCode=$1
    set +e
    
    shift
    [[ "$@" == "" ]] || \
        echo "$@" >&2

    exit $exitCode
}

#预处理xm、x文件
function Processor()
{
    local logosProcessor="$1"
    local currentDirectory="$2"

    echo "currentDirectory:$currentDirectory"

    if [[ $currentDirectory =~ "Build/Products" ]] || [[ $currentDirectory =~ "Build/Intermediates" ]] || [[ $currentDirectory =~ "Index/DataStore" ]] || [[ $currentDirectory =~ "/LatestBuild/" ]]; then
        echo "???????"
        return
    fi
    
    for file in `ls "$currentDirectory"`;
    do
        echo "file:${file}"
        extension="${file#*.}"
        filename="${file##*/}"
        if [[ -d "$currentDirectory""$file" ]]; then
            Processor "$logosProcessor" "$currentDirectory""$file"
        elif [[ "$extension" == "xm" ]]; then
            echo "XMFile:${file}"
            if [[ ! -f "$currentDirectory/${file%.*}.mm" ]] || [[ `ls -l "$currentDirectory/${file%.*}.mm" | awk '{ print $5 }'` < 10 ]] || [[ `stat -f %c "$currentDirectory/$file"` > `stat -f %c "$currentDirectory/${file%.*}.mm"` ]]; then
                  echo "Logos Processor: $filename -> ${filename%.*}.mm..."
                  logosStdErr=$(("$logosProcessor" "$currentDirectory""$file" > "$currentDirectory""${file%.*}.mm") 2>&1) || \
                    panic $? "Failed Logos Processor: $logosStdErr"
            fi

        elif [[ "$extension" == "x" ]]; then
            if [[ ! -f "$currentDirectory/${file%.*}.m" ]] || [[ `ls -l "$currentDirectory/${file%.*}.m" | awk '{ print $5 }'` < 10 ]] || [[ `stat -f %c "$currentDirectory/$file"` > `stat -f %c "$currentDirectory/${file%.*}.m"` ]]; then
                  echo "Logos Processor: $filename -> ${filename%.*}.m..."
                logosStdErr=$(("$logosProcessor" "$currentDirectory/$file" > "$currentDirectory/${file%.*}.m") 2>&1) || \
                    panic $? "Failed Logos Processor: $logosStdErr"
            fi
        fi
    done
}

logosProcessor="/opt/theos/bin/logos.pl"
echo "Start to genarate xxx.mm"
Processor "$logosProcessor" "$PROJECT_DIR/${TARGET_NAME}/"
