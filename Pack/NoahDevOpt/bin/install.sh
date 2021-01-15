#!/bin/sh

#  install.sh
#  InsertDemo
#
#  Created by daye on 2021/1/13.
#  Copyright © 2021 Noah. All rights reserved.

TARGET_NAME=${PRODUCT_NAME}
TARGET_APP_ROOT_PATH="${SRCROOT}/${TARGET_NAME}/TargetApp"
TEMPLSTES_PATH="/opt/NoahDev"
DYLIBS_TO_INJECT_PATH="${TEMPLSTES_PATH}/Dylibs/"
BUILD_APP_PATH="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app"
OPTOOL="${TEMPLSTES_PATH}/Tools/optool"

function panic() { # args: exitCode, message...
    local exitCode=$1
    set +e
    
    shift
    [[ "$@" == "" ]] || \
        echo "$@" >&2

    exit ${exitCode}
}

function code_sign() {
    local unCodesignDir="$1"

    echo "开始对${unCodesignDir}下的动态库做签名"
    for file in `ls "${unCodesignDir}"`;
    do
        extension="${file#*.}"
        echo "？？？？？${unCodesignDir}/$file"
        if [[ -f "${unCodesignDir}""$file" ]]; then
            echo "开始对${unCodesignDir}""$file签名"
            if [[ "${extension}" == "dylib" ]]; then
                codesign -fs $EXPANDED_CODE_SIGN_IDENTITY "${unCodesignDir}""$file"
            fi
        fi
    done
}

function install() {

    # 1. 软链接BUILD目录到当前项目下
    ln -fhs "${BUILT_PRODUCTS_DIR}" "${PROJECT_DIR}"/LatestBuild
    
    # 2. 修改Plist文件
    TARGET_INFO_PLIST=${SRCROOT}/${TARGET_NAME}/Info.plist
    
    # 获取目标APP路径
    TARGET_APP_PATH=$(find "${TARGET_APP_ROOT_PATH}" -type d | grep ".app$" | head -n 1)
    
    echo "TARGET_APP_PATH:${TARGET_APP_PATH}"
    if [ ! -d "${TARGET_APP_PATH}" ]; then
        TARGET_APP_PATH="${TARGET_APP_ROOT_PATH}/${TARGET_NAME}.app"
        cp -rf $BUILD_APP_PATH $TARGET_APP_PATH
    fi
    # 当前二进制文件
    CURRENT_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "${TARGET_INFO_PLIST}" 2>/dev/null)
    
    # 3. 将目标app拷贝到当前app目录下替换当前app
    # 拷贝 当前app的embedded.mobileprovision
    if [ -f "${BUILD_APP_PATH}/embedded.mobileprovision" ]; then
        mv "${BUILD_APP_PATH}/embedded.mobileprovision" "${BUILD_APP_PATH}"/..
    fi
    
    # 删除当前APP并重新创建目录
    rm -rf "${BUILD_APP_PATH}" || true
    mkdir -p "${BUILD_APP_PATH}" || true
    
    # 拷贝目标app到当前app目录
    cp -rf "${TARGET_APP_PATH}/" "${BUILD_APP_PATH}/"
    
    # 拷贝embedded.mobileprovision到替换后的app目录下
    if [ -f "${BUILD_APP_PATH}/../embedded.mobileprovision" ]; then
        mv "${BUILD_APP_PATH}/../embedded.mobileprovision" "${BUILD_APP_PATH}"
    fi
    
    # 目标APP的bundleId
    ORIGIN_BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier"  "${TARGET_APP_PATH}/Info.plist" 2>/dev/null)
    
    # 目标二进制文件
    TARGET_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable"  "${TARGET_APP_PATH}/Info.plist" 2>/dev/null)
    # 拷贝目标Info.plist替换当前项目的Info.plist
    if [[ ${CURRENT_EXECUTABLE} != ${TARGET_EXECUTABLE} ]]; then
        cp -rf "${TARGET_APP_PATH}/Info.plist" "${TARGET_INFO_PLIST}"
    fi
    
    # 目标APP的名称
    TARGET_DISPLAY_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" "${TARGET_INFO_PLIST}" 2>/dev/null)
    
    # 3. 创建xxx.app/Frameworks文件夹并拷贝需要注入的动态库和依赖的动态库
    TARGET_APP_FRAMEWORKS_PATH="${BUILD_APP_PATH}/Frameworks/"
    if [ ! -d "${TARGET_APP_FRAMEWORKS_PATH}" ]; then
        mkdir -p "${TARGET_APP_FRAMEWORKS_PATH}"
    fi

    # 拷贝项目生成的xxxDylib.dylib到xxx.app/Frameworks
    cp -rf "${BUILT_PRODUCTS_DIR}/lib""${TARGET_NAME}""Dylib.dylib" "${TARGET_APP_FRAMEWORKS_PATH}"
    
    # 拷贝依赖的动态库到xxx.app/Frameworks
    cp -rf "${DYLIBS_TO_INJECT_PATH}" "${TARGET_APP_FRAMEWORKS_PATH}"
    
    # 4. 注入当前工程生成的xxxDylib.dylib到app的二进制文件中
    APP_BINARY=`plutil -convert xml1 -o - ${BUILD_APP_PATH}/Info.plist | grep -A1 Exec | tail -n1 | cut -f2 -d\> | cut -f1 -d\<`
    "$OPTOOL" install -c load -p "@executable_path/Frameworks/lib""${TARGET_NAME}""Dylib.dylib" -t "${BUILD_APP_PATH}/${APP_BINARY}"
    # 给二进制文件添加执行权限
    chmod +x "${BUILD_APP_PATH}/${APP_BINARY}"
    
    # InfoPlist.strings插入
    if [[ "${TARGET_DISPLAY_NAME}" != "" ]]; then
        for file in `ls "${BUILD_APP_PATH}"`;
        do
            extension="${file#*.}"
            if [[ -d "${BUILD_APP_PATH}/$file" ]]; then
                if [[ "${extension}" == "lproj" ]]; then
                    if [[ -f "${BUILD_APP_PATH}/${file}/InfoPlist.strings" ]];then
                        /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${TARGET_DISPLAY_NAME}" "${BUILD_APP_PATH}/${file}/InfoPlist.strings"
                    fi
                fi
            fi
        done
    fi
    
    # 设置目标plist文件的bundleID
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ORIGIN_BUNDLE_ID}" "${TARGET_INFO_PLIST}"

    # 删除目标plist文件的icons
    /usr/libexec/PlistBuddy -c "Delete :CFBundleIconFiles" "${TARGET_INFO_PLIST}"
    # 添加目标plist文件的icons
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFiles array" "${TARGET_INFO_PLIST}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFiles: string ${TARGET_NAME}/icon.png" "${TARGET_INFO_PLIST}"
    
    # 替换Info.plist
    cp -rf "${TARGET_INFO_PLIST}" "${BUILD_APP_PATH}/Info.plist"

    # 5. 对 xxx.app/Frameworks/下的所有动态库签名
    code_sign "${TARGET_APP_FRAMEWORKS_PATH}"

}

install
