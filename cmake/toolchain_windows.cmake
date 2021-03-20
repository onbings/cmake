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
# History:		06 March 2021: Initial version
cmake_minimum_required(VERSION 3.0.2)

set(CMAKE_SYSTEM_NAME  DESKTOP_WIN64)
#SET(CMAKE_FIND_ROOT_PATH "C:/Program Files (x86)/Microsoft Visual Studio2")
find_program          (COMPILER_PATH cl.exe)	#Launch from a Visual Studio x64 Command Prompt Console. HINTS "C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/VC/Tools/MSVC/14.28.29333/bin/Hostx64/x64")

set(CMAKE_C_COMPILER    ${COMPILER_PATH})
set(CMAKE_CXX_COMPILER  ${COMPILER_PATH})

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MDd /EHsc /D_WIN32 /D_WIN64")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MD /EHsc /D_WIN32 /D_WIN64")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MDd /EHsc /D_WIN32 /D_WIN64")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD /EHsc /D_WIN32 /D_WIN64")

set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

#set(CMAKE_SYSROOT ${TOOLCHAIN_ROOT}/arm-unknown-linux-gnueabihf/sysroot)

set (BLD_COMPILER_ID ${CMAKE_CXX_COMPILER_ID} "_" ${CMAKE_CXX_COMPILER_VERSION})

