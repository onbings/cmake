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
	message(STATUS "bld_cxx_init [" ${BLD_TARGET_PLATFORM} "," ${CMAKE_FIND_ROOT_PATH} "]")
	if("${BLD_TARGET_PLATFORM}" STREQUAL "")
		set (BLD_TARGET_PLATFORM "DESKTOP_LINUX64")
		if ((${CMAKE_SYSTEM_NAME} STREQUAL "Windows") OR (${CMAKE_SYSTEM_NAME} STREQUAL "DESKTOP_WIN64"))
			set (BLD_TARGET_PLATFORM "DESKTOP_WIN64")
		endif()
		message(FATAL_ERROR "You must define BLD_TARGET_PLATFORM")
#		message(WARNING "BLD_TARGET_PLATFORM was not specified -> Default to " ${BLD_TARGET_PLATFORM})
	else()
		message(STATUS "BLD_TARGET_PLATFORM is " ${BLD_TARGET_PLATFORM})
	endif()

	if ("${CMAKE_FIND_ROOT_PATH}" STREQUAL "")
		message(FATAL_ERROR "You must define CMAKE_FIND_ROOT_PATH")
	endif()
	#by default set it to the same loc
	set (CMAKE_INSTALL_PREFIX ${CMAKE_FIND_ROOT_PATH})

	set (CMAKE_CXX_STANDARD 14)
	set (CMAKE_CONFIGURATION_TYPES "Debug;Release") 
	set (CMAKE_VERBOSE_MAKEFILE TRUE) 
	set (CMAKE_COLOR_MAKEFILE  TRUE)
	set (CMAKE_RELEASE_POSTFIX "_r")
	set (CMAKE_DEBUG_POSTFIX "_d")

	if("${BLD_COMPILER_ID}" STREQUAL "")
		set (BLD_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}_${CMAKE_CXX_COMPILER_VERSION}")
	endif()

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
		set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DDEBUG -g")	 #add -fsanitize=leak to check for leak
	endif()
	find_package(Doxygen)
	#message(STATUS "----------------------->DOXYGEN_FOUND ${DOXYGEN_FOUND}")

	if (DOXYGEN_FOUND AND NOT TARGET GenerateDoxygenDoc)
		message(STATUS "In  " ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in)
		if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in")
			message(STATUS "Out " ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile)
		#	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile @ONLY)
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/help/${PROJECT_NAME}.Doxyfile @ONLY)
		#	add_custom_target(documentation ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/help/${PROJECT_NAME}.Doxyfile WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMENT "Generating SDK documentation with Doxygen" VERBATIM)
			add_custom_target(GenerateDoxygenDoc ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/help/${PROJECT_NAME}.Doxyfile WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMENT "Generating documentation with Doxygen" VERBATIM)
		else()
			message(STATUS "Doxygen project file not found")
		endif()
	endif ()
endmacro()

macro(bld_find_package BLD_PACKAGE_NAME BLD_PACKAGE_VERSION BLD_USE_LEGACY_REPO)
#	set (BLD_USE_LEGACY_REPO ${ARGN})
	message(STATUS "bld_find_package(" ${BLD_PACKAGE_NAME} "," ${BLD_PACKAGE_VERSION} "," ${BLD_USE_LEGACY_REPO} ")")
	if ("${BLD_USE_LEGACY_REPO}" STREQUAL "TRUE")
		message(STATUS "Use old legacy repo layout to find ${BLD_PACKAGE_NAME}")
		#Y:\repo\DESKTOP_DEBIAN\bofstd\2.1.0\cmake
		set(BLD_PACKAGE_NAME_SUFFIX "${BLD_TARGET_PLATFORM}/${BLD_PACKAGE_NAME}/${BLD_PACKAGE_VERSION}/cmake")
	else()
		message(STATUS "Use NEW legacy repo layout to find ${BLD_PACKAGE_NAME}")
		#Y:\repo\DESKTOP_DEBIAN\bofstd\3.1.0.1\GNU_6.3.0\lib\cmake
		set(BLD_PACKAGE_NAME_SUFFIX "${BLD_TARGET_PLATFORM}/${BLD_PACKAGE_NAME}/${BLD_PACKAGE_VERSION}/${BLD_COMPILER_ID}/lib/cmake/${BLD_PACKAGE_NAME}")
	endif()
	# Search in the repository 
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
	message(STATUS "bld_std_cxx_install_setting")
	if ("${BLD_INSTALL_REV}" STREQUAL "")
		message("-- No BLD_INSTALL_REV -> default to 1")
		set (BLD_INSTALL_REV .1)
	endif()
	if (BLD_USE_LEGACY_REPO)
		set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/${BLD_TARGET_PLATFORM}/${PROJECT_NAME}/${PROJECT_VERSION}${BLD_INSTALL_REV}")
		install(EXPORT ${PROJECT_NAME} DESTINATION "cmake")
		install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME} DESTINATION "lib")
		#Install custom CMake configuration file
		install(FILES ${PROJECT_NAME}Config.cmake DESTINATION "cmake")
	else()
		set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/${BLD_TARGET_PLATFORM}/${PROJECT_NAME}/${PROJECT_VERSION}${BLD_INSTALL_REV}/${BLD_COMPILER_ID}")
		install(EXPORT ${PROJECT_NAME} DESTINATION "lib/cmake/${PROJECT_NAME}")
		install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME} DESTINATION "lib")
	#Install custom CMake configuration file
		install(FILES ${PROJECT_NAME}Config.cmake DESTINATION "lib/cmake/${PROJECT_NAME}")
	#pkgconfig
		set(BLD_PKG_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc")

		configure_file("${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.pc.in" "${BLD_PKG_CONFIG_FILE}" @ONLY)
		install(FILES "${BLD_PKG_CONFIG_FILE}" DESTINATION "lib/pkgconfig")
	endif()
#post info for Github
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
	message(STATUS "Use legacy repo  = " ${BLD_USE_LEGACY_REPO})
endmacro()

macro(bld_add_test BLD_TEST_PACKAGE_NAME BLD_TEST_PACKAGE_VERSION BLD_TEST_USE_LEGACY_REPO BLD_TEST_SUBDIR)
	message(STATUS "bld_add_test(" ${BLD_TEST_PACKAGE_NAME} "," ${BLD_TEST_PACKAGE_VERSION} "," ${BLD_TEST_USE_LEGACY_REPO} "," ${BLD_TEST_SUBDIR} ")")
	#message("====bld_add_test===> ${PROJECT_NAME}.gtest COMMAND $<TARGET_FILE_NAME:${PROJECT_NAME}> --gtest_output=xml:${CMAKE_BINARY_DIR}/GTestResult/$<CONFIG>/${PROJECT_NAME}.xml ${ARGV1} WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>" )

	enable_testing()
	add_test(NAME ${PROJECT_NAME}.gtest COMMAND $<TARGET_FILE_NAME:${PROJECT_NAME}> --gtest_output=xml:${CMAKE_BINARY_DIR}/GTestResult/$<CONFIG>/${PROJECT_NAME}.xml ${ARGV1} WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}> )
	bld_find_package(${BLD_TEST_PACKAGE_NAME} ${BLD_TEST_PACKAGE_VERSION} ${BLD_TEST_USE_LEGACY_REPO})
	add_subdirectory(${BLD_TEST_SUBDIR})
endmacro()

macro(bld_display_all_variable)
	get_cmake_property(_variableNames VARIABLES)
	foreach (_variableName ${_variableNames})
		message(STATUS "${_variableName}=${${_variableName}}")
	endforeach()
endmacro()