# Makefile for Mini Task Manager V2
# Compiler: MinGW-w64 (gcc)
# Usage:
#   mingw32-make          - Build the project
#   mingw32-make clean    - Remove build artifacts
#   mingw32-make run      - Build and run

# Compiler settings
CC = gcc
CFLAGS = -O2 -Wall -Wextra -Iinclude -DCOBJMACROS -DINITGUID
LDFLAGS = -lpsapi -ldxgi -lole32

# Directories
SRC_DIR = src
BUILD_DIR = build

# Source and target
SRCS = $(SRC_DIR)/main.c $(SRC_DIR)/cpu.c $(SRC_DIR)/memory.c $(SRC_DIR)/process.c $(SRC_DIR)/gpu.c $(SRC_DIR)/ui.c
TARGET = $(BUILD_DIR)/mini_task_manager.exe

# Default target
all: $(BUILD_DIR) $(TARGET)

# Create build directory
$(BUILD_DIR):
	if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)

# Link
$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Clean
clean:
	if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)

# Run
run: all
	$(TARGET)

.PHONY: all clean run
