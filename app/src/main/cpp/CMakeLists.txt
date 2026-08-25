cmake_minimum_required(VERSION 3.24)
project(MagdaAAP LANGUAGES C CXX)
# Keep the Android CMake graph sensitive to MAGDA's platform compatibility
# modules and retain the single magda_daw_app native target.
# Mutable DSP and libfaust are compiled into the Android build tree by MAGDA's dependency layer.

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT DEFINED MAGDA_DIR)
    set(MAGDA_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../external/magda-core")
endif()
if(NOT DEFINED AAP_DIR)
    set(AAP_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../external/aap-core")
endif()
if(NOT DEFINED AAP_JUCE_DIR)
    set(AAP_JUCE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../external/aap-juce")
endif()

# MAGDA's desktop build obtains libxml2 from vcpkg.  Android has no system
# libxml2, so provide the same library in this one normal application build.
# The DAWproject validator uses the real schema implementation; this is not a
# stub or a separate headless configuration.
include(FetchContent)
set(LIBXML2_WITH_ICONV OFF CACHE BOOL "" FORCE)
set(LIBXML2_WITH_LZMA OFF CACHE BOOL "" FORCE)
set(LIBXML2_WITH_PROGRAMS OFF CACHE BOOL "" FORCE)
set(LIBXML2_WITH_PYTHON OFF CACHE BOOL "" FORCE)
set(LIBXML2_WITH_ZLIB OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(libxml2
    GIT_REPOSITORY https://github.com/gnome/libxml2.git
    GIT_TAG v2.13.8
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(libxml2)

# MAGDA's existing CMakeLists.txt uses find_package(LibXml2), while the
# FetchContent build exposes the same LibXml2::LibXml2 target directly.
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# Keep the application target and its normal JUCE/Tracktion dependency graph
# intact.  This is deliberately not a second headless or Android-only MAGDA
# target.
set(JUCEAAP_ENABLED 1 CACHE BOOL "Enable AAP integration" FORCE)
# Keep the normal MAGDA application target, but do not ask Android's native
# build to produce desktop test/tools executables alongside it.
set(MAGDA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(MAGDA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(MAGDA_BUILD_FAUST_VEC_BENCH OFF CACHE BOOL "" FORCE)
set(MAGDA_BUILD_JUCE_ADAPTER OFF CACHE BOOL "" FORCE)
set(MAGDA_BUILD_NATIVE_ENGINE OFF CACHE BOOL "" FORCE)
set(MAGDA_HAVE_CLAP OFF CACHE BOOL "" FORCE)
set(MAGDA_FAUST_BACKEND interp CACHE STRING "" FORCE)
set(INCLUDE_EXECUTABLE OFF CACHE BOOL "" FORCE)
set(INCLUDE_STATIC ON CACHE BOOL "" FORCE)
# MAGDA's existing CMake files use CMAKE_SOURCE_DIR for paths into its source
# tree.  Since Android's externalNativeBuild entry point is this wrapper, make
# that established project-root assumption true while adding MAGDA.
set(CMAKE_SOURCE_DIR "${MAGDA_DIR}")
add_subdirectory("${MAGDA_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/magda-core")

target_sources(magda_daw_app PRIVATE
    "${CMAKE_CURRENT_LIST_DIR}/android_message_manager_compat.cpp")

# Android loads this library from the APK with dlopen().  MAGDA, JUCE, and
# Tracktion use C++ thread_local state, which must use emulated TLS in a
# dynamically loaded Android shared library rather than the initial-exec model.
foreach(_magda_android_target magda_daw magda_daw_app)
    if(TARGET ${_magda_android_target})
        target_compile_options(${_magda_android_target} PRIVATE -femulated-tls)
    endif()
endforeach()

# MAGDA enables strict warnings globally; JUCE's bundled Oboe sources contain
# upstream warnings that must not become errors in the Android build.
if(TARGET oboe)
    target_compile_options(oboe PRIVATE
        -Wno-error
        -Wno-unused-parameter
        -Wno-sign-compare
    )
endif()

# The existing MAGDA graph also creates its scanner/CLI helper targets.  They
# remain part of the same project, but Android has no AU/VST3/LV2 native
# formats, so override the desktop feature definitions for this invocation.
foreach(_magda_target magda_daw_app magda_plugin_scanner magda_cli)
    if(TARGET ${_magda_target})
        target_compile_definitions(${_magda_target} PRIVATE
            JUCE_PLUGINHOST_AU=0
            JUCE_PLUGINHOST_VST3=0
            JUCE_PLUGINHOST_LV2=0
        )
    endif()
endforeach()

find_package(androidaudioplugin REQUIRED CONFIG)
juce_add_module("${AAP_JUCE_DIR}/aap-modules/aap_audio_plugin_client")

# TracktionEngineWrapperInit.cpp is compiled into MAGDA's normal static
# library, so the AAP format's compile definitions and module usage requirements
# must reach that target as well as the final JNI shared library.
if(TARGET magda_daw)
    target_compile_definitions(magda_daw PRIVATE
        JUCEAAP_ENABLED=1
        JUCEAAP_HAVE_AUDIO_PLAYHEAD_NEW_POSITION_INFO=1
        JUCEAAP_USE_UNIQUE_ID=1
        JUCEAAP_HOSTED_PARAMETER=1
    )
    target_link_libraries(magda_daw PRIVATE
        androidaudioplugin::androidaudioplugin
        aap_audio_plugin_client
    )
endif()

target_link_libraries(magda_daw_app
    PRIVATE
    androidaudioplugin::androidaudioplugin
    aap_audio_plugin_client
)

target_compile_definitions(magda_daw_app PRIVATE
    JUCEAAP_ENABLED=1
    JUCEAAP_HAVE_AUDIO_PLAYHEAD_NEW_POSITION_INFO=1
    JUCEAAP_USE_UNIQUE_ID=1
    JUCEAAP_HOSTED_PARAMETER=1
    JUCE_DONT_AUTO_OPEN_MIDI_DEVICES_ON_MOBILE=1
    JUCE_USE_ANDROID_OBOE_STABILIZED_CALLBACK=1
    JUCE_PUSH_NOTIFICATIONS=1
    JUCE_PUSH_NOTIFICATIONS_ACTIVITY="com/rmsl/juce/JuceActivity"
)
