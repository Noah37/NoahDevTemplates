#!/bin/sh

#  install.sh
#  NoahDevTemplates
#
#  Created by daye on 2021/1/15.
#  Copyright © 2021 Noah. All rights reserved.

# custom templates directory
# /Users/caony/Library/Developer/Xcode/Templates/NoahDev

# tool directory
# /opt/NoahDev

CUR_USER=$(whoami)
TEMPLATES_PATH="/Users/${CUR_USER}/Library/Developer/Xcode/Templates/NoahDev"
PACK_TEMPLATES_PATH="${SRCROOT}/Pack/NoahDevTemp"
PACK_TOOLS_PATH="${SRCROOT}/Pack/NoahDevOpt"
OPT_DEV_PATH="/opt/NoahDev"

if [ ! -d "${OPT_DEV_PATH}" ]; then
    mkdir $OPT_DEV_PATH
fi

if [ ! -d "${TEMPLATES_PATH}" ]; then
    mkdir $TEMPLATES_PATH
fi

CUR_TIME=$(date "+%Y-%m-%d %H:%M:%S")
echo "CUR_TIME:${CUR_TIME}"
if [ -d "${TEMPLATES_PATH}" ]; then
    mv $TEMPLATES_PATH "${TEMPLATES_PATH}_${CUR_TIME}"
fi


if [ -d "${OPT_DEV_PATH}" ]; then
    mv $OPT_DEV_PATH "${OPT_DEV_PATH}_${CUR_TIME}"
fi
cp -rf $PACK_TEMPLATES_PATH $TEMPLATES_PATH
cp -rf $PACK_TOOLS_PATH ${OPT_DEV_PATH}
