#!/bin/bash

#CONSTANTS
OLD_DATE=$(date -d "-1 days" +%F)
TOMORROW_DATE=$(date -d "+1 days" +%F)
TODAY_DATE=$(date +%F)

#VARIABLES
work_path="."
log_file="lco.log"
operation=""
pattern="*"

#FUNCTIONS
function download {
	echo " Downloading LCO Files. Date:  $TODAY_DATE."
	wget_cmd="wget -o $log_file http://microcenter.mx/example.xml"
	echo "  Command: $wget_cmd"
	eval $wget_cmd
}

function decompress {
	echo "Moving old files"
	mv_cmd="find . -name '*XML' -exec mv {} backup/ \;"
	eval $mv_cmd
	echo " Decompressing LCO Files. Date:  $TODAY_DATE."
	find_cmd="find . -iname \"*$TODAY_DATE*\" -exec gzip -d {} \;"
	echo "  Command: $find_cmd"
	eval $find_cmd
}

function convert2json {
	echo "Converting files to JSON format"
	for i in $(ls -1 *.OK); do xsltproc xml2json.xsl $i > /tmp/JSON.txt && sed '/^$/d' /tmp/JSON.txt > $i.JSON && rm -f /tmp/JSON.txt; done
}

function validate {
	echo "Verify XML integrity"
	for i in $(ls -1 FTP-SAT/*.XML); do openssl smime -verify -in $i -inform DER -noverify > $i.OK; done
}

function insert2el {
	echo "Creating index lco$TODAY_DATE into Elasticsearch"
	curl -v -XPUT 'http://localhost:9200/lco$TODAY_DATE/' -d '{
    		"settings" : {
        	"index" : {
            	"number_of_shards" : 1,
            	"number_of_replicas" : 1
        		}
    		}
	}'
	echo "Inserting documents in Elasticsearch"
	curl -XPOST 'localhost:9200/lco$TODAY_DATE/_bulk?pretty' --data-binary @xaa
}

function usage {
	echo "usage: lco [OPERATION][--download|--decompress|--help] [OPTIONS][-lf|--log-file][-wp|--work-path]"
}

#MAIN
#PART1. VALIDATE OPERATION
if [ "$1" != "" ]; then
    case $1 in
        --download )
                operation="download"
                ;;

        --decompress )
                operation="decompress"
                ;;
	
	--convert2json )
		operation="convert2json"
		;;

	--validate )
		operation="validate"
		;;

	--insert2el )
		operation="validate"
		;;

        --help )
                usage
                exit 0
                ;;
        * )  
                usage
                exit 1
    esac
else
	usage
	exit 0
fi

#PART2. VALIDATE OPTIONS
while [ "$2" != "" ]; do
    case $2 in
        -lf | --log-file )
		shift
                log_file=$2
		;;

        -wp | --work-path )
		shift
		work_path=$2
		;;

	-pattern | --pattern)
		shift
		pattern=$2
		;;
        * )
		usage
                exit 1
    esac
    shift
done

#PART3. EXECUTE OPERATION WITH OPTIONS
cd $work_path
echo "+++++ LCO Shell Execution +++++"

#echo " Path: $PATH"
#echo " System Work Path: $(pwd)"
#echo " User Work Path: $work_path"

eval $operation
exit 0

