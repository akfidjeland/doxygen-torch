MACRO(ADD_TORCH_DOX dstdir section title rank)

    IF(DOXYGEN_FOUND AND LUA2DOX)

        ADD_CUSTOM_TARGET(documentation-dox ALL COMMENT "Built documentation")

        # If there's a local Doxyfile.in, use that; otherwise use the one
        # that's packaged with lua2dox.
        FIND_FILE(DOXYFILE
            Doxyfile.in
            PATHS ${CMAKE_CURRENT_SOURCE_DIR} ${Lua2Dox_INSTALL_PREFIX}/${Lua2Dox_INSTALL_CMAKE_SUBDIR}
            NO_DEFAULT_PATH
            DOC "Doxyfile.in: configuration for Doxygen"
        )

        SET(PROJECT_NAME ${title})
        # Need to set the source directory, since we're building out-of-source
        CONFIGURE_FILE(${DOXYFILE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)

        # Files go in the folder 'doc/html'
        ADD_CUSTOM_TARGET (${dstdir}-doxygen
            ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating API documentation with Doxygen" VERBATIM
        )
        INSTALL(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/doc/html/" DESTINATION "${Torch_INSTALL_HTML_SUBDIR}/${dstdir}")
        ADD_DEPENDENCIES(documentation-dox ${dstdir}-doxygen)

        # Update the main index
        ADD_CUSTOM_TARGET(${dstdir}-dok-index
          ${Torch_SOURCE_LUA} "${Torch_SOURCE_CMAKE}/dok/dokindex.lua" "${Torch_SOURCE_PKG}/dok/init.lua" "${TORCH_DOK_HTML_TEMPLATE}" "${CMAKE_BINARY_DIR}/dokindex.lua" "${Torch_INSTALL_SHARE}/torch/dokindex.lua" "${CMAKE_BINARY_DIR}/dok/index.txt" "${CMAKE_BINARY_DIR}/html/index.html" "${dstdir}" "${section}" "${title}" "${rank}"
          DEPENDS ${Torch_SOURCE_LUA} ${dstdir}-doxygen
          "${Torch_SOURCE_CMAKE}/dok/dokindex.lua"
          "${Torch_SOURCE_PKG}/dok/init.lua"
          COMMENT "Generating main documentation index")
        INSTALL(DIRECTORY "${CMAKE_BINARY_DIR}/html/" DESTINATION "${Torch_INSTALL_HTML_SUBDIR}")
        ADD_DEPENDENCIES(documentation-dox ${dstdir}-dok-index)
            
    ELSE()
        MESSAGE(WARNING "Failed to generate documentation due to missing tools. See earlier warnings")
    ENDIF()

ENDMACRO(ADD_TORCH_DOX)
