#!/bin/bash
echo "DDI conversion test"

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TEST_OUT_DIR="test/out"

SAXON_IMAGE='klakegg/saxon:9.9.1-7-he@sha256:18bd88758073d37fe5798dde9cb0aed91c1874957c0d03575d585ec977835012'
XSLT_FILE='adp-ddi_2_5_to_datacite.xsl'
SOURCE_RECORD='test/razjed10-en.xml'
TARGET_RECORD='test/razjed10-en-datacite.xml'

main() {
	init

	CONVERSION_OUT="$(mktemp "${TEST_OUT_DIR}/converted.xml.XXXX")"
	if run_xslt "${XSLT_FILE}" "${SOURCE_RECORD}" "${CONVERSION_OUT}" \
		&& [ -e "${BASE_DIR}"/"${CONVERSION_OUT}" ]; then
		echo "Conversion completed"
		
		if compare_xml "${CONVERSION_OUT}" "${TARGET_RECORD}"; then
			echo "Conversion output and target file comparison succeeded"
		else
			echo "FAILED: conversion output and target file comparison failed"
			cleanup "${CONVERSION_OUT}"; exit 1
		fi
		
	else
		echo "FAILED: conversion did not finish successfully!"
		cleanup "${CONVERSION_OUT}"; exit 1
	fi

	cleanup "${CONVERSION_OUT}"	
	
	echo "Done. SUCCESS!"
	exit 0
}

init() {
	echo "------ Init -----"
	mkdir -p "${TEST_OUT_DIR}"
	docker pull "${SAXON_IMAGE}"
	
	if ! ( [ -e "${SOURCE_RECORD}" ] && [ -e "${TARGET_RECORD}" ] && [ -e "${XSLT_FILE}" ] ); then
		echo "ERROR: Source file and/or target file and/or XSLT file does not exist"
		exit 1
	fi
	echo "-----------------"
}

cleanup() {
	echo "------ Cleanup -------"
	for f in "$@"; do
		if [ -e "$f" ]; then
			echo "- $f"
			rm "$f"
		fi
	done
	echo "----------------------"
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

compare_xml() {
	SRC="$1"
	TARGET="$2"	
	
	SRC_NORMALIZED="$(mktemp "${TEST_OUT_DIR}/src_normalized.xml.XXXX")"
	OUT_NORMALIZED="$(mktemp "${TEST_OUT_DIR}/target_normalized.xml.XXXX")"
	
	echo "------ Comparing -----"
	[ -e "${SRC}" ] && xmllint "${SRC}" > "${SRC_NORMALIZED}"
	[ -e "${TARGET}" ] && xmllint "${TARGET}" > "${OUT_NORMALIZED}"
	
	diff "${SRC_NORMALIZED}" "${OUT_NORMALIZED}"
	SUCCESS="$?"
	
	echo "Diff exit code: ${SUCCESS}"
	echo "----------------------"
	
	cleanup "${SRC_NORMALIZED}" "${OUT_NORMALIZED}"
	
	return "${SUCCESS}"
}

main
