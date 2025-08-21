#!/bin/bash

# javarun: Script to compile and run Java files automatically and globally.
#
# Usage: javarun <path/to/your/file.java>
#
# Features:
# - Verifies if the file is a .java and if it exists.
# - Compiles using 'javac'.
# - Executes the compiled '.class' file using 'java'.
# - Cleans up the generated '.class' file after execution.

# --- Configuration (you can change these) ---
# Compiler to use
JAVAC_COMPILER="javac"

# Java interpreter to use
JAVA_RUNNER="java"

# Clean up the .class file after running? (true/false)
# If set to 'false', the .class file will remain in the same directory as the source file.
CLEAN_AFTER_RUN=true
# --- End of Configuration ---

# --- Internal Functions ---
# Function to display error messages and exit
error_exit() {
  echo "Error: $1" >&2 # Print to stderr
  echo "Usage: javarun <path/to/your/file.java>" >&2
  exit 1
}

# --- Main Logic ---
# 1. Check if an argument was provided
if [ -z "$1" ]; then
  error_exit "No source file provided."
fi

SOURCE_FILE="$1"

# 2. Verify if the file is a .java and if it exists
if [[ ! "$SOURCE_FILE" =~ \.java$ ]]; then
  error_exit "File '$SOURCE_FILE' is not a valid .java file."
fi

if [ ! -f "$SOURCE_FILE" ]; then
  error_exit "File '$SOURCE_FILE' not found."
fi

# 3. Determine the class name and directory
# Use basename to get just the filename, then strip the extension.
BASE_NAME=$(basename "$SOURCE_FILE")
CLASS_NAME="${BASE_NAME%.java}"
SOURCE_DIR=$(dirname "$SOURCE_FILE")

# 4. Compile the file
echo "✨ Compiling '$SOURCE_FILE'..."
"$JAVAC_COMPILER" "$SOURCE_FILE"

# Check if compilation was successful
if [ $? -ne 0 ]; then
  error_exit "Compilation of '$SOURCE_FILE' failed. Please check your Java code for errors."
fi

# 5. Execute the compiled program
echo "🚀 Running '$CLASS_NAME'..."
# Use pushd and popd to handle the execution from the correct directory
# so that the 'java' command can find the '.class' file.
pushd "$SOURCE_DIR" >/dev/null
"$JAVA_RUNNER" "$CLASS_NAME"
# Capture the exit code of the Java program
PROGRAM_EXIT_CODE=$?
popd >/dev/null

# 6. Clean up the .class file (if CLEAN_AFTER_RUN is true)
if [ "$CLEAN_AFTER_RUN" = true ]; then
  CLASS_FILE="$SOURCE_DIR/$CLASS_NAME.class"
  echo "🗑️ Cleaning up temporary file '$CLASS_FILE'..."
  rm -f "$CLASS_FILE"
fi

# Exit with the same exit code as the Java program
exit $PROGRAM_EXIT_CODE
