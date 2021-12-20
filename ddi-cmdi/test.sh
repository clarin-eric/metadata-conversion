#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TEST_OUT_DIR="test/out"

SAXON_IMAGE='klakegg/saxon:9.9.1-7-he@sha256:18bd88758073d37fe5798dde9cb0aed91c1874957c0d03575d585ec977835012'

if ! which xq; then
	echo "ERROR: xq utility not found"
	exit 1
fi

main() {	
	echo "============ DDI conversion test ============"
	
	OWD="$(pwd)"
	cd "${BASE_DIR}" || exit 1

	init
	
	if test_conversion 'adp-ddi_2_5_to_cmdi.xsl' 'test/razjed10-en.xml' 'test/target/razjed10-en-cmdi.xml'
	then
		echo "Done. SUCCESS!"
		cd "${OWD}" || exit 0
		exit 0
	else
		echo "One or more tests failed."
		cd "${OWD}" || exit 1
		exit 1
	fi
}

test_conversion() {
	XSLT_FILE="${1}"
	SOURCE_RECORD="${2}"
	TARGET_RECORD="${3}"
	
	if ! [ -e "${BASE_DIR}/${SOURCE_RECORD}" ] \
		&& [ -e "${BASE_DIR}/${TARGET_RECORD}" ] \
		&& [ -e "${BASE_DIR}/${XSLT_FILE}" ]; then
		echo "ERROR: Source file, target file and/or XSLT file does not exist: " \
			"${SOURCE_RECORD}" "${TARGET_RECORD}" "${XSLT_FILE}"
		return 1
	fi

	CONVERSION_OUT="$(mktemp "${TEST_OUT_DIR}/converted.xml.XXXX")"
	if run_xslt "${XSLT_FILE}" "${SOURCE_RECORD}" "${CONVERSION_OUT}" \
		&& [ -e "${BASE_DIR}"/"${CONVERSION_OUT}" ]; then
		echo "Conversion completed"
		
		if compare_xml "${CONVERSION_OUT}" "${TARGET_RECORD}"; then
			echo "Conversion output and target file comparison succeeded"
		else
			echo "FAILED: conversion (${XSLT_FILE}) output and target file comparison failed"
			cleanup "${BASE_DIR}/${CONVERSION_OUT}"; return 1
		fi
		
	else
		echo "FAILED: conversion (${XSLT_FILE}) did not finish successfully!"
		cleanup "${BASE_DIR}/${CONVERSION_OUT}"; return 1
	fi

	cleanup "${BASE_DIR}/${CONVERSION_OUT}"	
	
	return 0
}

init() {
	echo "------ Init ------"
	echo "Current directory: $(pwd)"
	echo "Base directory: ${BASE_DIR}"
	echo "Test output directory: ${TEST_OUT_DIR}"
	mkdir -p "${TEST_OUT_DIR}"
	docker pull "${SAXON_IMAGE}"
	echo "------------------"
}

cleanup() {
	echo "------- Cleanup -------"
	for f in "$@"; do
		if [ -e "$f" ]; then
			echo "- $f"
			rm "$f"
		fi
	done
	echo "-----------------------"
}

run_xslt() {
	XSLT="$1"
	SRC="$2"
	OUT="$3"
	
	echo "-------- Running XSLT -------"
	echo "Converting '${SRC}' with '${XSLT}'. Output file: '${OUT}'"

	docker run --rm -i \
    -u "$(id -u)" \
    -v "${BASE_DIR}:/src" \
    "${SAXON_IMAGE}" \
    xslt -s:"$SRC" -xsl:"${XSLT}" -o:"${OUT}"    
	echo "-----------------------------"
}

compare_xml() {
	SRC="${BASE_DIR}/$1"
	TARGET="${BASE_DIR}/$2"	
	
	SRC_NORMALIZED="$(mktemp "${BASE_DIR}/${TEST_OUT_DIR}/src_normalized.xml.XXXX")"
	OUT_NORMALIZED="$(mktemp "${BASE_DIR}/${TEST_OUT_DIR}/target_normalized.xml.XXXX")"
	
	echo "-------- Comparing -------"
	[ -e "${SRC}" ] && normalize_xml "${SRC}" > "${SRC_NORMALIZED}"
	[ -e "${TARGET}" ] && normalize_xml "${TARGET}" > "${OUT_NORMALIZED}"
	
	echo diff "${SRC_NORMALIZED}" "${OUT_NORMALIZED}"
	diff "${SRC_NORMALIZED}" "${OUT_NORMALIZED}"
	SUCCESS="$?"
	
	echo "Diff exit code: ${SUCCESS}"
	echo "--------------------------"
	
	cleanup "${SRC_NORMALIZED}" "${OUT_NORMALIZED}"
	
	return "${SUCCESS}"
}

normalize_xml() {
	xmllint "$@"  \
		| tidy -quiet -utf8 -asxml -xml -indent --hide-comments 1 \
		| xq --xml-output \
'.'\
'|(.["cmd:CMD"]["cmd:Components"]["DDICodebook"].MetadataInfo.ProvenanceInfo.Activity.ActivityInfo.When.date|="----")'\
'|(.["cmd:CMD"]["cmd:Resources"]["cmd:ResourceProxyList"]["cmd:ResourceProxy"][0]["@id"]|="lp1")'
}

main
