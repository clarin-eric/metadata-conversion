#!/bin/bash
echo "DDI conversion test"

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TEST_OUT_DIR="test/out"

SAXON_IMAGE="klakegg/saxon:9.9.1-7-he"
XSLT_FILE="adp-ddi_2_5_to_datacite.xsl"
SOURCE_RECORD="test/razjed10-en.xml"
TARGET_RECORD="test/razjed10-en-cmdi.xml"

main() {
	init

	CONVERSION_OUT="$(mktemp "${TEST_OUT_DIR}/converted.xml.XXXX")"
	if run_xslt "${XSLT_FILE}" "${SOURCE_RECORD}" "${CONVERSION_OUT}" \
		&& [ -e "${BASE_DIR}"/"${CONVERSION_OUT}" ]; then
		echo "Conversion completed"
		# TODO: compare against target
		
		cleanup "${CONVERSION_OUT}"
	else
		echo "FAILED: conversion did not finish successfully!"
		cleanup "${CONVERSION_OUT}"
		exit 1
	fi
	
	echo "SUCCESS!"
	exit 0
}

init() {
	echo "------ Init -----"
	mkdir -p "${TEST_OUT_DIR}"
	docker pull "${SAXON_IMAGE}"
	echo "-----------------"
}

cleanup() {
	echo "------ Cleanup -----"
	for f in "$@"; do
		if [ -e "$f" ]; then
			echo "- $f"
			rm "$f"
		fi
	done
	echo "--------------------"
}

run_xslt() {
	XSLT="$1"
	SRC="$2"
	OUT="$3"
	
	echo "Converting '${SRC}' with '${XSLT}'. Output file: '${OUT}'"

	docker run --rm -i \
    -u "$(id -u)" \
    -v "${BASE_DIR}:/src" \
    "${SAXON_IMAGE}" \
    xslt -s:"$SRC" -xsl:"${XSLT}" -o:"${OUT}"    
}

main
