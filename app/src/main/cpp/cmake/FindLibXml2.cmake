# Bridge MAGDA's existing find_package(LibXml2 REQUIRED) call to the
# FetchContent-built libxml2 target used by the Android application.

if(TARGET LibXml2::LibXml2)
    set(LibXml2_FOUND TRUE)
    set(LIBXML2_FOUND TRUE)
    get_target_property(LIBXML2_INCLUDE_DIRS LibXml2::LibXml2
        INTERFACE_INCLUDE_DIRECTORIES)
    set(LIBXML2_INCLUDE_DIR "${LIBXML2_INCLUDE_DIRS}")
    set(LIBXML2_LIBRARIES LibXml2::LibXml2)
    set(LIBXML2_LIBRARY LibXml2::LibXml2)
else()
    set(LibXml2_FOUND FALSE)
endif()

