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



cp -rf $PACK_TEMPLATES_PATH $TEMPLATES_PATH
cp -rf $PACK_TOOLS_PATH "/opt/NoahDev"
