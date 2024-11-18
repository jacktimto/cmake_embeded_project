set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY) #CMake 尝试编译一个静态库

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER) # 参数有 ONLY,BOTH,NEVER
                                             # ONLY只在指定路径下找  BOTH在指定路径和系统路径下找 NEVER只在系统路径下找
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)  
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

option(USE_ARMGCC "USE ARM GCC" ON)

if(USE_ARMGCC)
    set(COMPILER_ROOT_PATH C:/ARM_GCC/13.3_rel1/bin)
    set(CMAKE_C_COMPILER ${COMPILER_ROOT_PATH}/arm-none-eabi-gcc.exe) # 指定C编译器的路径
    set(CMAKE_ASM_COMPILER ${COMPILER_ROOT_PATH}/arm-none-eabi-gcc.exe)
    set(CMAKE_OBJCOPY ${COMPILER_ROOT_PATH}/arm-none-eabi-objcopy.exe) # 常用于复制二进制文件并转换文件格式的工具
    # set(CMAKE_SIZE ${COMPILER_ROOT_PATH}/arm-none-eabi-size.exe) # 显示编译后二进制文件的大小信息
endif()

# 这个文件会被包含在CMakeLists.txt中