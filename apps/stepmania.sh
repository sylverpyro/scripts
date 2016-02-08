#!/bin/bash
SM_DIR="/usr/local/src/sm-ssc"

SM_EXE="${SM_DIR}/stepmania"

cd "${SM_DIR}"

#pavucontrol & "${SM_EXE}"; killall pavucontrol
"${SM_EXE}"
