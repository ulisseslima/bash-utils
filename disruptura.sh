#!/bin/bash
source /etc/profile

word=$1
nterms=$2
if [ ! -n "$word" ]; then
	cat $DICTIONARY_PT | sed '/^a/ d' | grep -v inha > /tmp/dict
	word=$(random.sh /tmp/dict)
fi

terms='à disruptura
do paradigma
da dinamização
estrutural
com democratização,
do trabalho
alternativo
de regressão
progressivo
do estado da arte
ahead-of-time
da análise preemptiva
das equipes,'

echo "$terms" > /tmp/terms

if [ "$nterms" == "all" ]; then
	nterms=$(echo "$terms" | wc -l)
else
	n=$(echo "$terms" | wc -l)
	nterms=$(((RANDOM % $n) +1))
fi

usable=

START=1
END=$nterms
for (( c=$START; c<=$END; c++ ))
do
	use="$(random.sh /tmp/terms)"
	grep -v "$use" /tmp/terms > /tmp/terms2
	rm /tmp/terms && mv /tmp/terms2 /tmp/terms
	usable="$usable $use"
done

echo "using $nterms terms"

echo -n "$word é um conceito "
while read term
do
	echo -n "$term "
done < <(echo "$usable" | shuf)

echo ""
