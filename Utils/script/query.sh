#!/bin/sh
# 
# Run a Wikidata query from command line.
# 
# Usage examples:
# 
# ./query-wikidata.sh "SELECT DISTINCT ?item WHERE {?item wdt:P31 wd:Q3917681. ?item wdt:P137 wd:Q16. ?item wdt:P131*/wdt:P17 wd:Q142.}"
# 
# OR this less convenient but more readable syntax:
# 
# echo "
#  SELECT DISTINCT
#    ?item
#  WHERE {
#    ?item wdt:P31 wd:Q3917681.
#    ?item wdt:P137 wd:Q16.
#    ?item wdt:P131*/wdt:P17 wd:Q142.
#  }
#  " |./query-wikidata.sh

ARG=$1

# Read command-line argument
#SPARQL="SELECT DISTINCT ?citylabel WHERE { ?city rdf:type dbpedia-owl:City. ?city rdfs:label ?citylabel. FILTER (lang(?citylabel) = \"fr\"). FILTER REGEX (?citylabel, \"(^$ARG)$\")} LIMIT 100"
SPARQL="SELECT DISTINCT ?name WHERE { ?r geo:lat ?latitude . ?r geo:long ?longitude . ?r rdfs:label ?name. FILTER (lang(?name) = 'fr'). FILTER (?name=\"$ARG\"@fr) .}"
# If no command-line argument, read from standard input
if [ -z "$SPARQL" ]
then
  SPARQL=$(cat)
fi

ONELINESPARQL=`echo $SPARQL | tr "\n" " "| sed 's/\//%2F/g'|sed 's/?/%3F/g'|sed 's/:/%3A/g'| sed 's/&/%26/g' | sed 's/=/%3D/g'`

URL="http://dbpedia.org/sparql?query=" # Wikidata SPARQL endpoint

URL="$URL PREFIX  dbpedia-owl:  <http://dbpedia.org/ontology/>"
URL="$URL PREFIX dbpedia: <http://dbpedia.org/resource>"
URL="$URL PREFIX dbpprop: <http://dbpedia.org/property>"
#URL="$URL PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos>"


#URL="$URL PREFIX wikibase: <http://wikiba.se/ontology#>" # Disabled these prefixes because they trigger a "Bad request" error from Wikidata
#URL="$URL PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"
URL="$URL $ONELINESPARQL"
#echo "$URL"
# HTMLize some possible query characters
URL=$(echo "$URL"|sed 's/(/%28/g'| sed 's/)/%29/g'| sed 's/*/%2a/g')

# Run HTTP request and send response to standard output
res=$(wget -O - "$URL")

echo "$res"
#echo "$res" > "../Utils/text/test.xml"
#echo "/Utils/text/test.xml"


#"SELECT DISTINCT ?citylabel WHERE { ?city rdf:type dbpedia-owl:City. ?city rdfs:label ?citylabel. FILTER REGEX (?citylabel, "(^Nantes)$")} LIMIT 100"
