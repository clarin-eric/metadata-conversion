#bin/sh
RED='\033[0;31m'
NC='\033[0m' # No Color

COLLECTIONS="92056_Ag_EU_TEL_a0022_Slovenia 9200401_Ag_EU_TEL_a0026_KB_NL 9200122_Ag_EU_TEL_a0031_KB 92031_Ag_EU_TEL_a0157 92033_Ag_EU_TEL_a0245 92012_Ag_EU_TEL_a0277_Newspapers_Iceland 92055_Ag_EU_TEL_a0308_Slovenia 92054_Ag_EU_TEL_a0309_Slovenia 92039_Ag_EU_TEL_a0493_Portugal 9200394_Ag_EU_TEL_a0512_Slovenia 9200114_Ag_EU_TEL_a0516_Bulgaria_Manuscript 9200140_Ag_EU_TEL_a0525_EUcollection14-18 9200280_Ag_EU_TEL_Collections_1914-1918_BL_a0558 9200292_Ag_EU_TEL_a0561_EUcollection14-18 9200115_Ag_EU_TEL_a0563_EUcollection14-18 9200228_Ag_EU_TEL_a0565_Collections_1914-1918 9200236_Ag_EU_TEL_a0567_Collections1914-1918 9200238_Ag_EU_TEL_a0569_Collections1914-1918 9200237_Ag_EU_TEL_a0571_Collections1914-1918 9200282_Ag_EU_TEL_Collections_1914-1918_BL_a0575 9200283_Ag_EU_TEL_Collections_1914-1918_BL_a0576 9200319_Ag_EU_TEL_a0578_Collections_1914-1918 9200154_Ag_EU_TEL_a0581_Europeana14-18_UK 92004_Ag_EU_TEL_a0588_TEL_NKP_manuscriptorium 9200136_Ag_EU_TEL_a0590_Bulgaria 9200302_Ag_EU_TEL_a0597_Newspapers_Spain 9200300_Ag_EU_TEL_a0600_Newspapers_ONB 9200359_Ag_EU_TEL_a0601_Newspapers_Netherlands 9200301_Ag_EU_TEL_a0611_Newspapers_Finland 9200384_Ag_EU_TEL_a0613_Newspapers_ONB 9200303_Ag_EU_TEL_a0617_Newspapers_Latvia 9200357_Ag_EU_TEL_a0618_Newspapers_poland 9200320_Ag_EU_TEL_a0625_Collections_1914-1918 9200366_Ag_EU_TEL_a0641_Newspapers_Slovenia 9200373_Ag_EU_TEL_a0642_Newspapers_Portugal 9200375_Ag_EU_TEL_a0643_Newspapers_Romania 9200374_Ag_EU_TEL_a0645_Newspapers_Bulgaria 9200332_Ag_EU_TEL_a0660_ONB 9200112_Ag_EU_TEL_a1025_ERegia 9200165_Ag_EU_TEL_a1055b_Eu_Libraries_Sibiu 9200141_Ag_EU_TEL_a1058_E.Libraries_Ghent 92099_Ag_EU_TEL_a1080_Europeana_Regia_France 9200179_Ag_EU_TEL_a1123_EULibraries_Sibiu 9200215_Ag_EU_TEL_a1135_Bulgaria 9200386_Ag_EU_TEL_a1194_BSB 9200322_Ag_EU_TEL_a1221_Collections_1914-1918 9200334_Ag_EU_TEL_a1223_EC1914_Slovak 9200376_Ag_EU_TEL_a1226_NationalLibrarySpain 9200377_Ag_EU_TEL_a1228_NationalLibraryBulgaria 9200368_Ag_EU_TEL_a1229_NationalLibraryBulgaria 9200353_Ag_EU_TEL_a1237_Bulgaria_Manuscript 9200367_Ag_EU_TEL_a1265_Newspapers_Serbia"

BASE_DIR=./target/sample
OAI_DIR=${BASE_DIR}/oai
EDM_DIR=${BASE_DIR}/edm
mkdir -p "${OAI_DIR}"
mkdir -p "${EDM_DIR}"

for SET_ID in $COLLECTIONS
do
	#set
	echo "- Set: $SET_ID"
	URL="http://oai.europeana.eu/oaicat/OAIHandler?verb=ListIdentifiers&metadataPrefix=edm&set=${SET_ID}"
	RECORD_ID=`curl -s "$URL" \
		|egrep -o "<identifier>[^<]+</identifier>" \
		|head -n 1 \
		|egrep -o "http[^<]+"`
	if [ "" != "$RECORD_ID" ]
		then
			#record
			echo "  - Record: ..."`echo $RECORD_ID|tail -c 30`
			
			#get record from OAI
			echo "    - Retrieving OAI record"
			URL="http://oai.europeana.eu/oaicat/OAIHandler?verb=GetRecord&metadataPrefix=edm&identifier=${RECORD_ID}"
			OAI_FILE="${OAI_DIR}/${SET_ID}-example.oai.xml"
			EDM_FILE="${EDM_DIR}/${SET_ID}-example.xml"
			TMP_FILE="${BASE_DIR}/tmp"
			curl -s "$URL" > "${TMP_FILE}"
			xmllint -format "${TMP_FILE}" > "$OAI_FILE"
			rm "${TMP_FILE}"
			
			#extract EDM record
			echo "    - Extracing EDM record"
			EDM_BEGIN=`grep -n "<metadata>" "${OAI_FILE}"|cut -f1 -d:`
			EDM_END=`grep -n "</metadata>" "${OAI_FILE}"|cut -f1 -d:`
			tail -n +$(($EDM_BEGIN + 1)) "${OAI_FILE}" | head -n $(($EDM_END - $EDM_BEGIN - 1)) > "$EDM_FILE"
		else
			echo -e "${RED}  - No records for ${SET_ID}!${NC}"
	fi
done
