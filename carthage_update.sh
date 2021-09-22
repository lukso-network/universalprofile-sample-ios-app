#!/bin/bash

xcodebuild -version
xcode_version=($(xcodebuild -version | grep Xcode))

if [[ ${xcode_version[1]} == 12.* ]]
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
	$FILE update --no-use-binaries --platform iOS $@
else
	carthage update --no-use-binaries --platform iOS $@
fi

#
# Rewrite carthage-copy-frameworks.xcfilelist.
# Use "$(SRCROOT)/Carthage/Build/iOS/" prefix for each framework
#
# Rewrite output-carthage.xcfilelist
# Use "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/" prefix for each framework
#
declare -a frameworks=($(ls Carthage/Build/iOS/ | grep '.framework$'))
carthage_copy_frameworks_file_content=""
output_carthage_file_content=""
for index in ${!frameworks[@]}
    do
        carthage_copy_frameworks_file_content=${carthage_copy_frameworks_file_content}'$(SRCROOT)/Carthage/Build/iOS/'${frameworks[$index]}'\n'
        output_carthage_file_content=${output_carthage_file_content}'$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/'${frameworks[$index]}'\n'
    done
echo -e $carthage_copy_frameworks_file_content > carthage-copy-frameworks.xcfilelist
echo "Updated carthage-copy-frameworks.xcfilelist"
echo -e $output_carthage_file_content > output-carthage.xcfilelist
echo "Updated output-carthage.xcfilelist"
