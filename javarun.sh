#!/bin/bash

java_file=$(find . -name "*.java" | fzf)

if [ -z "$java_file" ]; then
  echo "No file selected."
  exit 1
fi

class_name=$(basename "$java_file" .java)

javac "$java_file"

if [ $? -eq 0 ]; then
  java "$class_name"
else
  echo "Error compiling the file."
  exit 1
fi
