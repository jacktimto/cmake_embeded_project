cmake_minimum_required(VERSION 3.20) # 设定cmake的最低版本

cmake_policy(SET CMP0123 NEW) # 用于设置 CMake 的策略CMP0123,有OLD行为  NEW行为

set(CMAKE_SYSTEM_NAME Generic) # 用于指定目标系统的名字,比如Generic:通用,还有其他的比如 windows,Linux,mac
set(CPU_CORE cortex-m3)
set(CMAKE_SYSTEM_PROCESSOR ${CPU_CORE}) # 用于指定目标处理器的型号或架构

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/toolchain.cmake) # CMAKE_CURRENT_LIST_DIR是CM艾克Lists.txt所在的路径
                                                                    # 指定工具链
project(TEST C ASM) # 指定项目名称:TEST,和它支持的语言C ASM

string(TOUPPER ${CMAKE_BUILD_TYPE} BUILD_TYPE_UPPER) # 它将变量${CMAKE_BUILD_TYPE}的值转换为大写,并把结果存储在新的变量   BUILD_TYPE_UPPER
if(${BUILD_TYPE_UPPER} STREQUAL "RELEASE")           # 如果编译选项是RELEASE,则选用 -Os 来编译
    add_compile_options(-Os)
else()
    add_compile_options(-Og)
endif()

include_directories(                                         # 添加头文件
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/Firmware/CMSIS/
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/Firmware/CMSIS/GD/GD32F10x/Include/
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/Firmware/GD32F10x_standard_peripheral/Include/
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/inc/
)

file(GLOB SOURCE_FILE                                        # 添加源文件
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/Firmware/CMSIS/GD/GD32F10x/Source/*.c
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/Firmware/GD32F10x_standard_peripheral/Source/*.c
    ${CMAKE_CURRENT_LIST_DIR}/Firmware/src/*.c
)

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/output)      # 固件格式转换
set(HEX_FILE ${EXECUTABLE_OUTPUT_PATH}/${PROJECT_NAME}.hex)
set(BIN_FILE ${EXECUTABLE_OUTPUT_PATH}/${PROJECT_NAME}.bin)
set(MAP_FILE ${EXECUTABLE_OUTPUT_PATH}/${PROJECT_NAME}.map) 

if(USE_ARMGCC)
    SET(STARTUP_FILE ${CMAKE_CURRENT_LIST_DIR}/Firmware/gcc_startup/startup_gd32f10x_hd.S) #  设置启动文件
    SET(LINKER_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/Firmware/gd32f10x_flash.ld) # 设置链接脚本

    add_compile_options(            # 添加全局编译选项
        -mcpu=${CPU_CORE}           # 告诉编译器目标处理器的型号
        -mthumb                     # 生成 Thumb 指令集的代码，Thumb 是 ARM 架构的一种 16 位指令集，用于减小代码大小
        -mthumb-interwork           # 允许在 ARM 和 Thumb 指令集之间进行切换，这对于混合使用两种指令集的代码是必要的
        -ffunction-sections  # 将每个函数放入其自己的段中，这可以使得在链接时能够删除未引用的函数，减少最终二进制文件的大小
        -fdata-sections      # 类似于-ffunction-sections  ，但是用于数据。这允许链接器删除未引用的数据
        -fno-common          # 告诉编译器不要为未初始化的全局变量和静态变量生成“common”区域，这在某些链接器中是默认行为
        -fmessage-length=0   # 设置诊断消息的长度限制为 0，这可以防止编译器警告和错误消息被截断
    )

    add_link_options(             
        -Wl,-Map=${MAP_FILE}      # 告诉链接器生成一个包含地址和大小信息的 Map 文件
        -Wl,--print-memory-usage  # 指示链接器在链接过程中打印内存使用情况
        -Wl,--gc-sections         # 启用链接器的垃圾收集功能，它会移除未使用的代码和数据段，从而减少最终二进制文件的大小
        -T ${LINKER_SCRIPT}       # 指定链接脚本文件的路径
    )
endif()

add_executable(${PROJECT_NAME} ${SOURCE_FILE} ${STARTUP_FILE})  # 命令用于创建一个可执行文件
set_target_properties(${PROJECT_NAME} PROPERTIES                # 命令用于设置指定目标（可执行文件、库等）的属性
    RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}
)

if(USE_ARMGCC)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${PROJECT_NAME}> ${HEX_FILE}   # 生成hex文件
        COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${PROJECT_NAME}> ${BIN_FILE}
        COMMAND ${CMAKE_SIEZE} $<TARGET_FILE:${PROJECT_NAME}>                        # 用于打印文件大小信息
    )
endif()