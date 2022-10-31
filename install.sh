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
TEMPLATES_PATH="/Users/${CUR_USER}/Library/Developer/Xcode/Templates/"
NOAHDEV_TEMPLATES_PATH="${TEMPLATES_PATH}/NoahDev"
PACK_TEMPLATES_PATH="${SRCROOT}/Pack/NoahDevTemp"
PACK_TOOLS_PATH="${SRCROOT}/Pack/NoahDevOpt/"
OPT_DEV_PATH="/opt/NoahDev"
PASSWORD='123456' # 替换成自己的电脑密码

CUR_TIME=$(date "+%Y-%m-%d %H:%M:%S")
echo "CUR_TIME:${CUR_TIME}"
if [ ! -d "${OPT_DEV_PATH}" ]; then
    echo $PASSWORD | sudo -S mkdir $OPT_DEV_PATH
else
    echo $PASSWORD | sudo -S mv $OPT_DEV_PATH "${OPT_DEV_PATH}_${CUR_TIME}"
fi

if [ ! -d "${TEMPLATES_PATH}" ]; then
    echo $PASSWORD | sudo -S mkdir $TEMPLATES_PATH
fi

if [ -d "${NOAHDEV_TEMPLATES_PATH}" ]; then
    echo $PASSWORD | sudo -S mv $NOAHDEV_TEMPLATES_PATH "${NOAHDEV_TEMPLATES_PATH}_${CUR_TIME}"
fi

echo $PASSWORD | sudo -S cp -rf $PACK_TEMPLATES_PATH $TEMPLATES_PATH
echo $PASSWORD | sudo -S cp -rf $PACK_TOOLS_PATH ${OPT_DEV_PATH}
