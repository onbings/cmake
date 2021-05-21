# Copyright (c) 2014, Onbings. All rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
# KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
# PURPOSE.
# 
# Name: 		CMakeLists.txt
# Author: 		Bernard HARMEL
# Revision:		1.0
# 
# Remarks: bha2
# None
# 
# History:		05 June 2014: Initial version
cmake_minimum_required(VERSION 3.0.2)

#Unlike functions, macros run in the same scope as their caller. Therefore, all variables defined inside a macro are set in the caller’s scope.

macro(bld_cxx_init)
	message(STATUS "bld_cxx_init")
	set (CMAKE_CXX_STANDARD 14)
	set (CMAKE_CONFIGURATION_TYPES "Debug;Release") 
	set (CMAKE_VERBOSE_MAKEFILE TRUE) 
	set (CMAKE_COLOR_MAKEFILE  TRUE)

	if("${BLD_TARGET_PLATFORM}" STREQUAL "")
		set (BLD_TARGET_PLATFORM "DESKTOP_LINUX64")
		if ((${CMAKE_SYSTEM_NAME} STREQUAL "Windows") OR (${CMAKE_SYSTEM_NAME} STREQUAL "DESKTOP_WIN64"))
			set (BLD_TARGET_PLATFORM "DESKTOP_WIN64")
		endif()
	endif()
	
	if ("${CMAKE_FIND_ROOT_PATH}" STREQUAL "")
		message(FATAL_ERROR "You must define CMAKE_FIND_ROOT_PATH")
	endif()
#by default set it to the same loc	
	set (CMAKE_INSTALL_PREFIX ${CMAKE_FIND_ROOT_PATH})
	
	if("${BLD_COMPILER_ID}" STREQUAL "")
		set (BLD_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}_${CMAKE_CXX_COMPILER_VERSION}")
	endif()
	set (CMAKE_DEBUG_POSTFIX "_d")
	
	if("${BLD_TARGET_PLATFORM}" STREQUAL "DESKTOP_WIN64")
		set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT /EHsc /bigobj")
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd /EHsc /bigobj")
		set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT /EHsc /bigobj")
		set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd /EHsc /bigobj")
	#elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	else()
		# Update if necessary
		# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wconversion -Wextra -Wno-long-long -pedantic")
		set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DNDEBUG -g")	#Add -g to debug release code
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DDEBUG")	 #add -fsanitize=leak to check for leak
		set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DNDEBUG")			#Add -g to debug release code
		set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DNDEBUG")			#Add -g to debug release code
		set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DDEBUG -g")	 #add -fsanitize=leak to check for leak
	endif()
	find_package(Doxygen)
	message(STATUS "----------------------->DOXYGEN_FOUND ${DOXYGEN_FOUND}")

	if (DOXYGEN_FOUND AND NOT TARGET documentation)
		message("In " ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in)
		message("Out " ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile)
		#	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile @ONLY)
		configure_file(${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/help/${PROJECT_NAME}.Doxyfile @ONLY)
		#	add_custom_target(documentation ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMENT "Generating SDK documentation with Doxygen" VERBATIM)
		add_custom_target(documentation ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/help/${PROJECT_NAME}.Doxyfile WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMENT "Generating documentation with Doxygen" VERBATIM)
	endif ()
endmacro()

macro(bld_find_package BLD_PACKAGE_NAME BLD_PACKAGE_VERSION)
	message(STATUS "bld_find_package(" ${BLD_PACKAGE_NAME} "," ${BLD_PACKAGE_VERSION} ")")
	# Search in the repository 
	set(BLD_PACKAGE_NAME_SUFFIX "${BLD_TARGET_PLATFORM}/${BLD_PACKAGE_NAME}/${BLD_PACKAGE_VERSION}/${BLD_COMPILER_ID}/lib/cmake/${BLD_PACKAGE_NAME}")
	set(${BLD_PACKAGE_NAME}_DIR "${CMAKE_FIND_ROOT_PATH}/${BLD_PACKAGE_NAME_SUFFIX}")	
	message(STATUS "Look for " ${BLD_PACKAGE_NAME} " with suffix " ${BLD_PACKAGE_NAME_SUFFIX})
	message(STATUS "${BLD_PACKAGE_NAME}_DIR is " ${${BLD_PACKAGE_NAME}_DIR})
	#set(CMAKE_FIND_DEBUG_MODE TRUE)
	find_package(${BLD_PACKAGE_NAME} REQUIRED PATH_SUFFIXES "${BLD_PACKAGE_NAME_DIR}")  
	#set(CMAKE_FIND_DEBUG_MODE FALSE)
	message(STATUS "${BLD_PACKAGE_NAME}_FOUND is " ${${BLD_PACKAGE_NAME}_FOUND})
endmacro()

macro(bld_std_cxx_compile_link_setting)
	message(STATUS "bld_std_cxx_compile_link_setting")
	if("${BLD_TARGET_PLATFORM}" STREQUAL "DESKTOP_WIN64")
		target_compile_definitions(  
			${PROJECT_NAME} PRIVATE 
			$<BUILD_INTERFACE:_WINSOCK_DEPRECATED_NO_WARNINGS>  
			$<BUILD_INTERFACE:_CRT_NONSTDC_NO_DEPRECATE>
			$<BUILD_INTERFACE:_CRT_SECURE_NO_WARNINGS>  
			$<BUILD_INTERFACE:_CRT_NON_CONFORMING_SWPRINTFS>
			$<BUILD_INTERFACE:UNICODE>
		)	
		set(BLD_STANDARD_LINK_LIBRARIES Winmm Ws2_32 Rpcrt4 Iphlpapi)		
	else()	
		target_compile_definitions(  
			${PROJECT_NAME} PRIVATE 
		)	
		set(BLD_STANDARD_LINK_LIBRARIES rt dl pthread)	
	endif()
endmacro()

macro(bld_std_cxx_install_setting)
	if ("${BLD_INSTALL_REV}" STREQUAL "")
		message("-- No BLD_INSTALL_REV -> default to 1")
		set (BLD_INSTALL_REV .1)
	endif()
	set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/${BLD_TARGET_PLATFORM}/${PROJECT_NAME}/${PROJECT_VERSION}${BLD_INSTALL_REV}/${BLD_COMPILER_ID}") 
	install(EXPORT ${PROJECT_NAME} DESTINATION "lib/cmake/${PROJECT_NAME}")
	install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME} DESTINATION "lib") 
#Install custom CMake configuration file
	install(FILES ${PROJECT_NAME}Config.cmake DESTINATION "lib/cmake/${PROJECT_NAME}") 	
#pkgconfig	
	set(BLD_PKG_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc")
    configure_file("${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.pc.in" "${BLD_PKG_CONFIG_FILE}" @ONLY)
    install(FILES "${BLD_PKG_CONFIG_FILE}" DESTINATION "lib/pkgconfig")
#post infor for Github	
	message(STATUS "Write info ${PROJECT_VERSION}${BLD_INSTALL_REV}@${BLD_COMPILER_ID} in ${CMAKE_CURRENT_BINARY_DIR}/BLD_CMAKE_INFO.TXT file.")
	file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/BLD_CMAKE_INFO.TXT ${PROJECT_VERSION}${BLD_INSTALL_REV}@${BLD_COMPILER_ID})
endmacro()



macro(bld_show_info)
	message(STATUS "bld_show_info")
	message(STATUS "Project          = " ${PROJECT_NAME})
	message(STATUS "Version          = " ${PROJECT_VERSION})
	message(STATUS "CrossCompile     = " ${CMAKE_CROSSCOMPILING})
	message(STATUS "Compiler         = " ${CMAKE_CXX_COMPILER}) 
	message(STATUS "Compiler Id      = " ${CMAKE_CXX_COMPILER_ID} "_" ${CMAKE_CXX_COMPILER_VERSION}) 
	message(STATUS "Source Dir       = " ${CMAKE_SOURCE_DIR})
	message(STATUS "Target Platform  = " ${BLD_TARGET_PLATFORM})
	message(STATUS "C Debug          = " ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS_DEBUG})
	message(STATUS "C Release        = " ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS_RELEASE})
	message(STATUS "C++ Debug        = " ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS_DEBUG})
	message(STATUS "C++ Release      = " ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS_RELEASE})
	message(STATUS "Sys Root         = " ${CMAKE_SYSROOT})
	message(STATUS "Install Prefix   = " ${CMAKE_INSTALL_PREFIX})
	message(STATUS "Find Root Path   = " ${CMAKE_FIND_ROOT_PATH})
endmacro()

#https://cristianadam.eu/20190501/bundling-together-static-libraries-with-cmake/
#The usage of this function is as simple as:
#add_library(awesome_lib STATIC ...);
#bundle_static_library(awesome_lib awesome_lib_bundled)

function(bld_bundle_static_library tgt_name bundled_tgt_name)
	list(APPEND static_libs ${tgt_name})

	function(_recursively_collect_dependencies input_target)
		set(_input_link_libraries LINK_LIBRARIES)
		get_target_property(_input_type ${input_target} TYPE)
		if (${_input_type} STREQUAL "INTERFACE_LIBRARY")
			set(_input_link_libraries INTERFACE_LINK_LIBRARIES)
		endif()
		get_target_property(public_dependencies ${input_target} ${_input_link_libraries})
		foreach(dependency IN LISTS public_dependencies)
			if(TARGET ${dependency})
				get_target_property(alias ${dependency} ALIASED_TARGET)
				if (TARGET ${alias})
					set(dependency ${alias})
				endif()
				get_target_property(_type ${dependency} TYPE)
				if (${_type} STREQUAL "STATIC_LIBRARY")
					list(APPEND static_libs ${dependency})
				endif()

				get_property(library_already_added
						GLOBAL PROPERTY _${tgt_name}_static_bundle_${dependency})
				if (NOT library_already_added)
					set_property(GLOBAL PROPERTY _${tgt_name}_static_bundle_${dependency} ON)
					_recursively_collect_dependencies(${dependency})
				endif()
			endif()
		endforeach()
		set(static_libs ${static_libs} PARENT_SCOPE)
	endfunction()

	_recursively_collect_dependencies(${tgt_name})

	list(REMOVE_DUPLICATES static_libs)

	set(bundled_tgt_full_name
			${CMAKE_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${bundled_tgt_name}${CMAKE_STATIC_LIBRARY_SUFFIX})

	if (CMAKE_CXX_COMPILER_ID MATCHES "^(Clang|GNU)$")
		file(WRITE ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in
				"CREATE ${bundled_tgt_full_name}\n" )

		foreach(tgt IN LISTS static_libs)
			file(APPEND ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in
					"ADDLIB $<TARGET_FILE:${tgt}>\n")
		endforeach()

		file(APPEND ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in "SAVE\n")
		file(APPEND ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in "END\n")

		file(GENERATE
				OUTPUT ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar
				INPUT ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar.in)

		set(ar_tool ${CMAKE_AR})
		if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)
			set(ar_tool ${CMAKE_CXX_COMPILER_AR})
		endif()

		add_custom_command(
				COMMAND ${ar_tool} -M < ${CMAKE_BINARY_DIR}/${bundled_tgt_name}.ar
				OUTPUT ${bundled_tgt_full_name}
				COMMENT "Bundling ${bundled_tgt_name}"
				VERBATIM)
	elseif(MSVC)
		find_program(lib_tool lib)

		foreach(tgt IN LISTS static_libs)
			list(APPEND static_libs_full_names $<TARGET_FILE:${tgt}>)
		endforeach()

		add_custom_command(
				COMMAND ${lib_tool} /NOLOGO /OUT:${bundled_tgt_full_name} ${static_libs_full_names}
				OUTPUT ${bundled_tgt_full_name}
				COMMENT "Bundling ${bundled_tgt_name}"
				VERBATIM)
	else()
		message(FATAL_ERROR "Unknown bundle scenario!")
	endif()

	add_custom_target(bundling_target ALL DEPENDS ${bundled_tgt_full_name})
	add_dependencies(bundling_target ${tgt_name})

	add_library(${bundled_tgt_name} STATIC IMPORTED)
	set_target_properties(${bundled_tgt_name}
			PROPERTIES
			IMPORTED_LOCATION ${bundled_tgt_full_name}
			INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${tgt_name},INTERFACE_INCLUDE_DIRECTORIES>)
	add_dependencies(${bundled_tgt_name} bundling_target)

endfunction()
