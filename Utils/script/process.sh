#!/bin/sh

# ONLY CHANGE UNITEX VARIABLE
unitex="/home/edgar/Unitex-GramLab-3.2rc"

Logger=$unitex"/App/UnitexToolLogger"
Foldertxt="../Utils/text"
Foldergraph="../Utils/graphs"
tmp="../Utils/tmp"

text=$2
graph=$1


mkdir ../Utils/tmp
mkdir $tmp/${text}_snt


$Logger Normalize $Foldertxt/$text.txt -r$unitex/French/Norm.txt --output_offsets=$tmp/${text}_snt/normalize.out.offsets -qutf8-no-bom

$Logger Grf2Fst2 $unitex/French/Graphs/Preprocessing/Sentence/Sentence.grf -y --alphabet=$unitex/French/Alphabet.txt -qutf8-no-bom
$Logger Flatten $unitex/French/Graphs/Preprocessing/Sentence/Sentence.fst2 --rtn -d5 -qutf8-no-bom

mv $Foldertxt/$text.snt $tmp

$Logger Fst2Txt -t$tmp/$text.snt $unitex/French/Graphs/Preprocessing/Sentence/Sentence.fst2 -a$unitex/French/Alphabet.txt -M --input_offsets=$tmp/${text}_snt/normalize.out.offsets --output_offsets=${tmp}/${text}_snt/normalize.out.offsets -qutf8-no-bom
$Logger Grf2Fst2 $unitex/French/Graphs/Preprocessing/Replace/Replace.grf -y --alphabet=$unitex/French/Alphabet.txt -qutf8-no-bom
$Logger Fst2Txt -t$tmp/$text.snt $unitex/French/Graphs/Preprocessing/Replace/Replace.fst2 -a$unitex/French/Alphabet.txt -R --input_offsets=$tmp/${text}_snt/normalize.out.offsets --output_offsets=${tmp}/${text}_snt/normalize.out.offsets -qutf8-no-bom
$Logger Tokenize $tmp/$text.snt -a$unitex/French/Alphabet.txt --input_offsets=$tmp/${text}_snt/normalize.out.offsets --output_offsets=$tmp/${text}_snt/tokenize.out.offsets -qutf8-no-bom
$Logger Dico -t$tmp/$text.snt -a$unitex/French/Alphabet.txt $unitex/French/Dela/dela-fr-public.bin $unitex/French/Dela/ajouts$text.bin $unitex/French/Dela/motsGramf-.bin -qutf8-no-bom
$Logger SortTxt $tmp/${text}_snt/dlf -l$tmp/${text}_snt/dlf.n -o$unitex/French/Alphabet_sort.txt -qutf8-no-bom
$Logger SortTxt $tmp/${text}_snt/dlc -l$tmp/${text}_snt/dlc.n -o$unitex/French/Alphabet_sort.txt -qutf8-no-bom
$Logger SortTxt $tmp/${text}_snt/err -l$tmp/${text}_snt/err.n -o$unitex/French/Alphabet_sort.txt -qutf8-no-bom
$Logger SortTxt $tmp/${text}_snt/tags_err -l$tmp/${text}_snt/tags_err.n -o$unitex/French/Alphabet_sort.txt  -qutf8-no-bom


$Logger Grf2Fst2 $Foldergraph/$graph.grf -y --alphabet=$unitex/French/Alphabet.txt -qutf8-no-bom

mv $Foldergraph/$graph.fst2 $tmp


$Logger Locate -t$tmp/$text.snt $tmp/$graph.fst2 -a$unitex/French/Alphabet.txt -A -M --all -b -Y --stack_max=1000 --max_matches_per_subgraph=200 --max_matches_at_token_pos=400 --max_errors=50 -qutf8-no-bom
$Logger Concord $tmp/${text}_snt/concord.ind --xml -a$unitex/French/Alphabet_sort.txt --CL -qutf8-no-bom
