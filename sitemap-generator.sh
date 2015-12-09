#/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

die() {
    echo "${red}[ERROR]${reset} $1" > /dev/stderr
    exit 1
}

log() {
    $VERBOSE && echo "${green}[INFO]${reset} $1"
}

show_help() {
    echo "Usage: $0 [OPTIONS] url"
    echo ""
    echo "Options:"
    echo " -o,  --output       Define output filename. Default: sitemap.xml"
    echo " -d,  --domains      Restrict the crawling to this specific comma separated domains list"
    echo " -r,  --reject       Rejected comma separated list of file name suffixes or patterns."
    echo "                     Default: .jpg,.jpeg,.css,.js,.ico,.png,.gif,.swf"
    echo " -x,  --reject-regex Rejected regular expression of complete URL."
    echo " -f,  --frequency    Define URLs frequency. Default: monthly"
    echo "                     See: http://www.sitemaps.org/protocol.html#changefreqdef"
    echo " -p,  --priority     Define the priority for all urls. Default 0.8"
    echo "                     See: http://www.sitemaps.org/protocol.html#prioritydef"
    echo " -h,  --help         See this help"
    exit 0
}

URL=
DOMAINS=
OUTPUT="sitemap.xml"
REJECT=".jpg,.jpeg,.css,.js,.ico,.png,.gif,.swf"
REJECT_REGEX=
FREQUENCY="monthly"
PRIORITY=0.8
DATE=`date +%Y-%m-%d`
VERBOSE=false

while true; do
    case "$1" in
        -v | --verbose ) VERBOSE=true; shift ;;
        -u | --url ) URL="$2"; shift 2 ;;
        -d | --domain ) DOMAINS="$2"; shift 2 ;;
        -o | --output ) OUTPUT="$2"; shift 2 ;;
        -r | --reject ) REJECT="$2"; shift 2 ;;
        -x | --reject-regex ) REJECT_REGEX="--reject-regex=$2"; shift 2 ;;
        -f | --frequency ) FREQUENCY="$2"; shift 2 ;;
        -p | --priority ) PRIORITY="$2"; shift 2 ;;
        -h | --help ) show_help; shift 1;;
        * ) URL="$1"; break ;;
    esac
done

if [ -z "$URL" ]; then
    die "Usage: $0 [OPTIONS] url.\nTry $0 --help for more informations."
fi

if [ -z "$DOMAINS" ]; then
	DOMAINS=`echo $URL | awk -F/ '{print $3}'`
fi

TMP_TXT_FILE=$OUTPUT.txt
SED_LOG_FILE=$OUTPUT.sedlog.txt

log "URL: $URL"
log "Domains: $DOMAINS"
log "Rejected suffixes: $REJECT"
log "Rejected regex: $REJECT_REGEX"
log "Output: $OUTPUT"
log "Frequency: $FREQUENCY"
log "Priority: $PRIORITY\n"

log "Crawling $URL => $TMP_TXT_FILE ..."
wget --spider --recursive --output-file=$TMP_TXT_FILE --no-http-keep-alive --no-verbose --domains=$DOMAINS --reject=$REJECT $REJECT_REGEX $URL

log "Cleaning urls ..."
sed -n "s@.\+ URL:\([^ ]\+\) .\+@\1@p" $TMP_TXT_FILE | sed "s@&@\&amp;@" > $SED_LOG_FILE

log "Generating $OUTPUT ..."
echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUTPUT
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $OUTPUT

log "Generating XML metadata in $OUTPUT ..."
awk '{print "\t<url><loc>"$0"</loc><lastmod>'$DATE'</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>"}' $SED_LOG_FILE >> $OUTPUT

echo '</urlset>' >> $OUTPUT

log "Cleaning temp files ...\n"
rm -f $TMP_TXT_FILE  $SED_LOG_FILE

log "Done => $OUTPUT"
log "Found $((`cat $OUTPUT | wc -l` - 3)) urls\n"
