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
PRE_BUILD_TASKS += patch-aap-juce
AAP_JUCE_CMAKE_PATCH_HOSTING=1
JUCE_PATCHES= \
    $(PWD)/juce-modules.patch \
    $(PWD)/external/aap-juce/juce-patches/8.0.12/juce-component-peer-view-touch.patch
JUCE_PATCH_DEPTH=1

patch-aap-juce: $(AAP_JUCE_DIR)/.stamp-aap-juce

$(AAP_JUCE_DIR)/.stamp-aap-juce:
	cd $(AAP_JUCE_DIR) && git apply $(AAP_JUCE_PATCH_FILE) --ignore-space-change
	touch $(AAP_JUCE_DIR)/.stamp-aap-juce

include $(AAP_JUCE_DIR)/Makefile.cmake-common
