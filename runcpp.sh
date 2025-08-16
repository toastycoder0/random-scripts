#!/bin/bash

# cpprun: Script to compile and run C++ files automatically and globally.
#
# Usage: cpprun <path/to/your/file.cpp>
#
# Features:
# - Verifies if the file is a .cpp and if it exists.
# - Compiles using g++.
# - Creates a temporary executable in /tmp (or current directory if /tmp is not writable).
# - Executes the program.
# - Deletes the temporary executable after execution.

# --- Configuration (you can change these) ---
# Compiler to use (g++ is common on macOS if you installed Command Line Tools)
COMPILER="g++"

# Temporary directory for executables.
# Use /tmp for temporary files, or . for the current directory if preferred.
TEMP_DIR="/tmp"

# Clean up executable after running? (true/false)
# If set to 'false', the executable will remain in TEMP_DIR.
CLEAN_AFTER_RUN=true
# --- End of Configuration ---

# --- Internal Functions ---
# Function to display error messages and exit
error_exit() {
  echo "Error: $1" >&2 # Print to stderr
  echo "Usage: cpprun <path/to/your/file.cpp>" >&2
  exit 1
}

# --- Main Logic ---
# 1. Check if an argument was provided
if [ -z "$1" ]; then
  error_exit "No source file provided."
fi

SOURCE_FILE="$1"

# 2. Verify if the file is a .cpp and if it exists
if [[ ! "$SOURCE_FILE" =~ \.cpp$ ]]; then
  error_exit "File '$SOURCE_FILE' is not a valid .cpp file."
fi

if [ ! -f "$SOURCE_FILE" ]; then
  error_exit "File '$SOURCE_FILE' not found."
fi

# 3. Determine the executable name
# Use basename to get just the filename, then strip the extension.
BASE_NAME=$(basename "$SOURCE_FILE")
EXECUTABLE_NAME="${BASE_NAME%.cpp}"

# Append a timestamp to ensure a unique name if run multiple times quickly
# This avoids collisions if many programs have the same base name,
# especially useful if we don't clean up the executable.
TIMESTAMP=$(date +%s%N) # Seconds since Epoch + nanoseconds for uniqueness
EXECUTABLE_PATH="$TEMP_DIR/$EXECUTABLE_NAME-$TIMESTAMP"

# 4. Compile the file
echo "✨ Compiling '$SOURCE_FILE'..."
"$COMPILER" "$SOURCE_FILE" -o "$EXECUTABLE_PATH"

# Check if compilation was successful
if [ $? -ne 0 ]; then
  error_exit "Compilation of '$SOURCE_FILE' failed. Please check your C++ code for errors."
fi

# 5. Execute the compiled program
echo "🚀 Running '$EXECUTABLE_PATH'..."
"$EXECUTABLE_PATH"

# Capture the exit code of the C++ program
PROGRAM_EXIT_CODE=$?

# 6. Clean up the executable (if CLEAN_AFTER_RUN is true)
if [ "$CLEAN_AFTER_RUN" = true ]; then
  echo "🗑️ Cleaning up temporary executable '$EXECUTABLE_PATH'..."
  rm -f "$EXECUTABLE_PATH"
fi

# Exit with the same exit code as the C++ program
exit $PROGRAM_EXIT_CODE
