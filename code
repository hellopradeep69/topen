#!/usr/bin/env bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

if [ $# -ne 1 ]; then
    echo -e "${YELLOW}Usage:${RESET} $0 <filename>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo -e "${RED}Error:${RESET} File not found!"
    exit 1
fi

EXT="${FILE##*.}"
BASENAME="${FILE%.*}"
CLASSNAME=$(basename "$BASENAME")

case "$EXT" in
py)
    CMD=("python3" "$FILE")
    ;;
java)
    CMD=("sh" -c "javac \"$FILE\" && java \"$CLASSNAME\"")
    ;;
c)
    CMD=("sh" -c "gcc \"$FILE\" -o \"$BASENAME\" && ./\"$BASENAME\"")
    ;;
cpp)
    CMD=("sh" -c "g++ \"$FILE\" -o \"$BASENAME\" && ./\"$BASENAME\"")
    ;;
sh)
    CMD=("bash" "$FILE")
    ;;
lua)
    CMD=("lua" "$FILE")
    ;;
js)
    CMD=("node" "$FILE")
    ;;
*)
    echo -e "${RED}Error:${RESET} Unsupported file type: $EXT"
    exit 1
    ;;
esac

echo " "
echo -e "${GREEN}=== OUTPUT ${FILE} ===${RESET}"
# Run interactively (keeps stdin open)
"${CMD[@]}"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${RED}=== PROGRAM ERROR (exit code $EXIT_CODE) ===${RESET}"
fi
