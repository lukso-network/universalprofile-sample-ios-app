#!/bin/bash

if [[ $@ == "-h" || $@ == "--help" ]]
then
    echo "
# ==================================================================================================
# https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md
#
# Carthage builds fat frameworks, which means that the framework contains binaries
# for all supported architectures. Until Apple Silicon was introduced it all worked just fine, but
# now there is a conflict as there are duplicate architectures (arm64 for devices and arm64 for
# simulator).
# This means that Carthage cannot link architecture specific frameworks to a single fat framework.
# You can find more info in respective issue #3019: https://github.com/Carthage/Carthage/issues/3019
#
# This script will remove the arm64 architecture for simulator,
# so the above mentioned conflict doesn't exist.
#
# This script also contains two versions of the same fix: for Xcode 12 and Xcode 13.
# ==================================================================================================

This script has constant flags that are used when executing carthage.
They are:
    1) --platform iOS
    2) --cache-builds
    3) --use-xcframeworks
        
Options:
    - Mode [not required; default - bootstrap].
      Call script with \"update\"/\"bootstrap\" (or empty) mode argument to execute \"carthage update/bootstrap\".
    
        Example 0:
            user: ./carthage_update.sh update
            will translate to
            user: carthage update --platform iOS --cache-builds --use-xcframeworks
        
        Example 1:
            user: ./carthage_update.sh
            will translate to
            user: carthage bootstrap --platform iOS --cache-builds --use-xcframeworks
    
    - Specify dependencies [not required; default - all dependencies].
      A list of specific dependencies you want to update/bootstrap.
      **Mode is required.**
      
        Example 0:
            user: ./carthage_update.sh update Alamofire
            will translate to
            user: carthage update Alamofire --platform iOS --cache-builds --use-xcframeworks
      
        Example 1:
            user: ./carthage_update.sh bootstrap Alamofire universalprofile-ios-sdk
            will translate to
            user: carthage bootstrap Alamofire universalprofile-ios-sdk --platform iOS --cache-builds --use-xcframeworks
    "
    exit 1;
fi

xcodebuild -version
xcode_version=($(xcodebuild -version | grep Xcode))
xcode_version_number=($(echo ${xcode_version[1]} | tr "." "\n"))
xcode_major_version=$((xcode_version_number[0]))

arguments=$@

if [[ -z "$@" ]]
then
    arguments="bootstrap"
    echo "Using bootstrap Carthage argument"
fi

if ! [[ $arguments =~ ^update.*$ || $arguments =~ ^bootstrap.*$ ]]; then
    echo "Use update or bootstrap command before a list of dependencies"
    exit 0;
fi

if (( $xcode_major_version == 12 ));
then
    echo "Carthage produces errors when used with Xcode 12+"
    echo "For details about the script see: https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md"

    FILE=/usr/local/bin/carthage.sh
    if [ -f "$FILE" ]; then
        echo "$FILE already exists; rewriting it's content."
        cat /dev/null > $FILE
    else
        touch $FILE
    fi

    echo "
    # carthage.sh
    # Usage example: ./carthage.sh build --platform iOS
    #

    set -euo pipefail

    xcconfig=\$(mktemp /tmp/static.xcconfig.XXXXXX)
    trap 'rm -f \"\$xcconfig\"' INT TERM HUP EXIT

    # For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
    # the build will fail on lipo due to duplicate architectures.

    CURRENT_XCODE_VERSION=\$(xcodebuild -version | grep \"Build version\" | cut -d' ' -f3)
    echo \"EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_\$CURRENT_XCODE_VERSION = arm64 arm64e armv7 armv7s armv6 armv8\" >> \$xcconfig

    echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = \$(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_\$(XCODE_PRODUCT_BUILD_VERSION))' >> \$xcconfig
    echo 'EXCLUDED_ARCHS = \$(inherited) \$(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_\$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_\$(NATIVE_ARCH_64_BIT)__XCODE_\$(XCODE_VERSION_MAJOR))' >> \$xcconfig

    export XCODE_XCCONFIG_FILE=\"\$xcconfig\"
    carthage \"\$@\"\
    " >> $FILE

    echo "---------------------------------------------"

    chmod +x $FILE
    export PATH=$PATH:$FILE
    carthageCmd="$FILE $arguments --platform iOS --cache-builds --use-xcframeworks"
    echo $carthageCmd
    $carthageCmd
elif (( $xcode_major_version == 13 ));
then
    echo "Carthage produces errors when used with Xcode 13+"
    echo "For details about the script see: https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md"

    FILE=/usr/local/bin/carthage.sh
    if [ -f "$FILE" ]; then
        echo "$FILE already exists; rewriting it's content."
        cat /dev/null > $FILE
    else
        touch $FILE
    fi

    echo "
    #!/bin/bash

    # carthage.sh
    # Usage example: ./carthage.sh build --platform iOS

    set -euo pipefail

    xcconfig=\$(mktemp /tmp/static.xcconfig.XXXXXX)
    trap 'rm -f \"\$xcconfig\"' INT TERM HUP EXIT

    # For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
    # the build will fail on lipo due to duplicate architectures.

    CURRENT_XCODE_VERSION=\$(xcodebuild -version | grep \"Build version\" | cut -d' ' -f3)
    echo \"EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300__BUILD_\$CURRENT_XCODE_VERSION = arm64 arm64e armv7 armv7s armv6 armv8\" >> \$xcconfig

    echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300 = \$(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300__BUILD_\$(XCODE_PRODUCT_BUILD_VERSION))' >> \$xcconfig
    echo 'EXCLUDED_ARCHS = \$(inherited) \$(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_\$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_\$(NATIVE_ARCH_64_BIT)__XCODE_\$(XCODE_VERSION_MAJOR))' >> \$xcconfig

    export XCODE_XCCONFIG_FILE=\"\$xcconfig\"
    /usr/local/bin/carthage \"\$@\"\
    " >> $FILE

    echo "---------------------------------------------"

    chmod +x $FILE
    export PATH=$PATH:$FILE
    carthageCmd="$FILE $arguments --platform iOS --cache-builds --use-xcframeworks"
    echo $carthageCmd
    $carthageCmd
else
    carthageCmd="carthage $arguments --platform iOS --cache-builds --use-xcframeworks"
    echo $carthageCmd
    $carthageCmd
fi
