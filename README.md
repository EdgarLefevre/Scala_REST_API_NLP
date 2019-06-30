# NLP_ReactiveProgramming

REST API used to find named entities in an upload text.

It use a SPARQL request to get a list of named entities, then use Unitex with a graph in order to list the entities present in the text.

The API allows the user to upload a file, list all files previously uploaded and find the named entities in the text.


## Requirements

Scala 2.12

Sbt :
```
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt
```

Unitex (https://unitexgramlab.org) with French package

Wget

```
sudo apt-get install wget
```

## Project Architecture

```
Doc
    -> Useful documentation about the project

Utils
---- Text -> uploaded texts
---- Graph -> uploaded graphs
---- Script -> useful scripts

Nlp_REST
    -> Scala application
```


## Endpoints

```
--- GET     	/                               -> List text files
--- Post     	/                               -> Add text file(s)
--- Get     	/graph                          ->List graph files
--- Post     	/graph                          -> Add graph file(s)
--- Get     	/graph/$name_graph/$name_txt    -> Process graph on text (file names without extension)
```

To upload a file you need to perform a JSON request with those elements :  
```
{
	"name" : "filename.extension",
	"text" : " text content"
}
```

Be careful when you upload text to use the escape char :
```
\b  Backspace (ascii code 08)
\f  Form feed (ascii code 0C)
\n  New line
\r  Carriage return
\t  Tab
\"  Double quote
\\  Backslash character
```


## Run



After modify the value of Unitex path in `/utils/scripts/process.sh`, in Nlp_REST :
```
sbt run
```

## Requete SPARQL

Check if the string has longitude and latitude, the most generalist query, allows to treat the named spatial entities compound of several words (like "rue" or "avenue") in case of improvement by changing the strict equality to bif:contains.

```sparql
SELECT DISTINCT ?name WHERE
    { ?var geo:lat ?latitude .
    ?var geo:long ?longitude .
    ?var rdfs:label ?name.
    FILTER (lang(?name) = 'fr').
    FILTER (?name=\"$ARG\"@fr) .}"

```

## Known Issues

Sometimes, the folder Dela in Unitex/French magically disappear (at least some files), make a copy of your original dela folder in order to be sure to not loose it.
