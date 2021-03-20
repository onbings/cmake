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
# Remarks: 
# None
# 
# History:		05 June 2014: Initial version
#               06 March 2021 remove dependency on third party and cmake helpers
cmake_minimum_required(VERSION 3.0.2)

set(CMAKE_SYSTEM_NAME  Linux)
set(TOOLCHAIN_PREFIX   )

find_program          (COMPILER_PATH ${TOOLCHAIN_PREFIX}gcc-${COMPILER_VERSION}${EXTENSION}) 
get_filename_component(COMPILER_ROOT ${COMPILER_PATH}     DIRECTORY)
get_filename_component(TOOLCHAIN_ROOT ${COMPILER_ROOT}/.. REALPATH)

#set toolchain components
set(CMAKE_C_COMPILER    ${COMPILER_ROOT}/${TOOLCHAIN_PREFIX}gcc${EXTENSION})
set(CMAKE_CXX_COMPILER  ${COMPILER_ROOT}/${TOOLCHAIN_PREFIX}g++${EXTENSION})
      
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DNDEBUG -g")	#Add -g to debug release code
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DDEBUG")	 #add -fsanitize=leak to check for leak
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DNDEBUG")			#Add -g to debug release code
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fPIC -Wall -Wconversion -Wextra -Wno-long-long -pedantic -DDEBUG -g")	 #add -fsanitize=leak to check for leak	

set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_SYSROOT ${TOOLCHAIN_ROOT}/i686-intel386_32_mtpc-linux-gnu/sysroot)

set (BLD_COMPILER_ID ${CMAKE_CXX_COMPILER_ID} "_" ${CMAKE_CXX_COMPILER_VERSION})