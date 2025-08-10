#\!/bin/bash

# Process CLAUDE.md with all the replacements
sed -i '' \
    -e 's/## The Four Buses (10s)/## 100 Series - Foundation Buses/g' \
    -e 's/## LLM\/AI Services (20s)/## 200 Series - LLM Models/g' \
    -e 's/## UI\/Input System (30s)/## 300 Series - Input System/g' \
    -e 's/## Personas (40s)/## 400 Series - Personas/g' \
    -e 's/## Core Services (50s)/## 500 Series - Conversations/g' \
    -e 's/## Infrastructure (60s)/## 600 Series - App Theme/g' \
    -e 's/## Developer Tools (70s)/## 700 Series - Developer Tools/g' \
    CLAUDE.md

echo "CLAUDE.md updated with new series names"
