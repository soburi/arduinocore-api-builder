VERSION = 1.5.2

TOOLCHAIN_PREFIX ?= arm-zephyr-eabi-

CXX := $(TOOLCHAIN_PREFIX)g++
CC := $(TOOLCHAIN_PREFIX)gcc
AR := $(TOOLCHAIN_PREFIX)ar

CPU_ARCH ?= cortex-m0plus
CPU_FLAGS := -mcpu=$(CPU_ARCH) -mthumb -mabi=aapcs -mfp16-format=ieee -mtp=soft
SYSROOT ?= $(shell dirname $(CXX))
ARCH_FLAGS := $(CPU_FLAGS) --sysroot=$(SYSROOT)

SRC_DIR ?= ArduinoCore-API/api
OBJ_DIR ?= build/$(CPU_ARCH)/obj
LIB_DIR ?= build/lib
LIB_NAME ?= libarduinocore_api_$(CPU_ARCH).a
LIB := $(LIB_DIR)/$(LIB_NAME)

COMMON_FLAGS := -fno-strict-aliasing -Os -fno-common -g -gdwarf-4 -fdiagnostics-color=always \
  -fno-pic -fno-pie -fno-asynchronous-unwind-tables -ftls-model=local-exec \
  -fno-reorder-functions --param=min-pagesize=0 -fno-defer-pop -ffunction-sections \
  -fdata-sections -specs=picolibc.specs
WARNING_FLAGS := -Wall -Wformat -Wformat-security -Wno-format-zero-length -Wdouble-promotion \
  -Wpointer-arith -Wexpansion-to-defined -Wno-unused-but-set-variable

CXXFLAGS := $(COMMON_FLAGS) $(WARNING_FLAGS) $(ARCH_FLAGS) -fcheck-new -std=c++11 \
  -fno-exceptions -fno-rtti -nostdinc++

INCLUDES = -IArduinoCore-API/api

SOURCES := $(shell find $(SRC_DIR) -name '*.cpp' 2>/dev/null)
OBJECTS := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SOURCES))

.PHONY: all clean fetch

all: $(LIB)

$(LIB): $(OBJECTS)
	@mkdir -p $(LIB_DIR)
	@if [ -n "$(OBJECTS)" ]; then \
		$(AR) rcs $@ $(OBJECTS); \
		printf 'AR %s\n' $@; \
	else \
		echo "No object files produced, skipping archive $@"; \
	fi

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(INCLUDES) $(CXXFLAGS) -c $< -o $@

fetch:
	if [ ! -d ArduinoCore-API ]; then \
		git clone https://github.com/arduino/ArduinoCore-API -b $(VERSION); \
	fi


clean:
	rm -rf $(OBJ_DIR) $(LIB) ArduinoCore-API
