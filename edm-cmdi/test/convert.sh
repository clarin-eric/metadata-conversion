#/bin/sh
set -e

SAXON_DISTR_URL="https://netcologne.dl.sourceforge.net/project/saxon/Saxon-HE/9.6/SaxonHE9-6-0-10J.zip"

SCRIPT_DIR="$(dirname "$0")"
SAXON_DIR="${SCRIPT_DIR}/target/saxon"
SAXON="${SAXON_DIR}/saxon9he.jar"
STYLESHEET="${SCRIPT_DIR}/../edm2cmdi.xsl"

# Determine input directory
IN_DIR=$1
if [ -z "$IN_DIR" ]
then
	IN_DIR="${SCRIPT_DIR}/edm"
	echo "Using default input directory $IN_DIR"
else
	echo "Using custom input directory $IN_DIR"
	shift
fi

# Check existence of input directory
if [ ! -d $IN_DIR ]
then
	echo "Input directory does not exist"
	exit 1
fi

# Determine output directory
OUT_DIR=$1
if [ -z "$OUT_DIR" ]
then
	OUT_DIR="${SCRIPT_DIR}/target/edm-cmdi"
	echo "Using default output directory $OUT_DIR"
else
	echo "Using custom output directory $OUT_DIR"
	shift
fi

if [ -z "$SAXON_OPTS" ]
then
	SAXON_OPTS="!indent=no"
fi

if [ ! -d "$SAXON_DIR" ]
then
	TMP_DIR="/tmp/edm-cmdi"
	SAXON_DISTR_TMP="/tmp/edm-cmdi/saxon.zip"

	echo -e "\n----- Retrieving Saxon binaries.... -----"
	mkdir -p "${TMP_DIR}"
	curl "${SAXON_DISTR_URL}" > "${SAXON_DISTR_TMP}"
	mkdir -p "${SAXON_DIR}"

	echo -e "\n----- Unpacking Saxon binaries.... -----"
	unzip "${SAXON_DISTR_TMP}" -d "${SAXON_DIR}"
	rm "${SAXON_DISTR_TMP}"
	rmdir "${TMP_DIR}"
	echo -e "\n"
fi

echo "----- Converting files in ${IN_DIR}, writing to ${OUT_DIR} -----"

if [ -f "$SAXON" ]
then
	echo "Saxon JAR found at $SAXON"
else
	echo "ERROR: Saxon JAR not found at expected location (${SAXON})"
	exit 1
fi

if [ -d "${OUT_DIR}" ]
then
	echo "Output directory $OUT_DIR already exists..."
else
	mkdir -p "${OUT_DIR}"
fi

java -jar "${SAXON}" -s:"${IN_DIR}" -o:"${OUT_DIR}" -xsl:"${STYLESHEET}" ${SAXON_OPTS} $@