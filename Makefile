PWD=$(shell pwd)

APP_NAME=Magda
APP_BUILD_DIR=$(PWD)
APP_SRC_DIR=$(PWD)/external/magda-core
JUCE_DIR=$(APP_SRC_DIR)/third_party/JUCE
AAP_DIR=$(PWD)/external/aap-core
AAP_JUCE_DIR=$(PWD)/external/aap-juce

APP_MODULE_DIRS=app
PATCH_DEPTH=1
PATCH_FILE=$(PWD)/magda-core.patch
AAP_JUCE_PATCH_FILE=$(PWD)/aap-juce.patch
PRE_BUILD_TASKS += ensure-faust ensure-magda-lfs patch-aap-juce
AAP_JUCE_CMAKE_PATCH_HOSTING=1
JUCE_PATCHES= \
    $(PWD)/juce-modules.patch \
    $(PWD)/external/aap-juce/juce-patches/8.0.12/juce-component-peer-view-touch.patch
JUCE_PATCH_DEPTH=1

ensure-faust:
	@if command -v faust >/dev/null 2>&1; then \
		echo "Faust found: $$(command -v faust)"; \
	elif [ "$$(uname)" = "Darwin" ]; then \
		brew install faust; \
	elif command -v apt-get >/dev/null 2>&1; then \
		if [ "$$(id -u)" -eq 0 ]; then \
			apt-get update && apt-get install -y faust; \
		else \
			sudo apt-get update && sudo apt-get install -y faust; \
		fi; \
	else \
		echo "Faust is required but no supported package manager was found" >&2; \
		exit 1; \
	fi

ensure-magda-lfs:
	@if [ -f "$(APP_SRC_DIR)/assets/fonts/NotoSansCJKsc-Regular.otf" ] && \
		grep -q '^version https://git-lfs\.github\.com/spec/' "$(APP_SRC_DIR)/assets/fonts/NotoSansCJKsc-Regular.otf"; then \
		if ! command -v git-lfs >/dev/null 2>&1; then \
			if [ "$$(uname)" = "Darwin" ]; then \
				brew install git-lfs; \
			elif command -v apt-get >/dev/null 2>&1; then \
				if [ "$$(id -u)" -eq 0 ]; then \
					apt-get update && apt-get install -y git-lfs; \
				else \
					sudo apt-get update && sudo apt-get install -y git-lfs; \
				fi; \
			else \
				echo "Git LFS is required but no supported package manager was found" >&2; \
				exit 1; \
			fi; \
		fi; \
		git -C "$(APP_SRC_DIR)" lfs install --local; \
		git -C "$(APP_SRC_DIR)" lfs pull --include="assets/fonts/NotoSansCJKsc-Regular.otf"; \
	else \
		echo "Magda LFS assets are already available"; \
	fi

patch-aap-juce: $(AAP_JUCE_DIR)/.stamp-aap-juce

$(AAP_JUCE_DIR)/.stamp-aap-juce:
	cd $(AAP_JUCE_DIR) && git apply $(AAP_JUCE_PATCH_FILE) --ignore-space-change
	touch $(AAP_JUCE_DIR)/.stamp-aap-juce

include $(AAP_JUCE_DIR)/Makefile.cmake-common
