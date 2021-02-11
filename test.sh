#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# run all test.sh files in subdirectories

find "${BASE_DIR}" -mindepth 2 -maxdepth 2 -type f -name 'test.sh' -print | xargs bash
