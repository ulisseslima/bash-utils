#!/bin/bash
source /etc/profile

word=$1
nterms=$2
fverbs=/tmp/verbs
if [ ! -n "$word" ]; then
	if [ ! -f "$DICTIONARY_PT" ]; then
		>&2 echo "no dictionary file found. define it with DICTIONARY_PT"
		exit 1
	fi

	cat $DICTIONARY_PT | sed '/^a/ d' | grep 'r$' > $fverbs
	word=$(random.sh $fverbs)
fi

terms='à disruptura
do paradigma
da dinamização
estrutural
fenomenológico
nada
ao mesmo tempo,
no tempo
, posto que é
, partindo do pressuposto que nunca foi
quasi-misantropo
com democratização,
do trabalho
alternativamente
incôngruo
e idempotente
pelo mindset
top of mind
num brainstorm
sustentado por sua arquitetura hexagonal
integral
pela falsa dicotomia
paralelamente
surpreendentemente
desconstruído
de regressão
progressivo
atrelado
cerceante
do estado da arte
ahead-of-time
da análise preemptiva
tal complexidade
federado
suplementado
porém modularizado
sem ser modular
sindicação
compilado
às vezes ingerenciável
passando pelo worflow
sistematizado
nem pelo portal
das equipes,'

particles='do
da
para
é
'

fterms=/tmp/terms
echo "$terms" > $fterms

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
	use="$(random.sh $fterms)"
	grep -v "$use" $fterms > "${fterms}.2"
	rm $fterms && mv "${fterms}.2" $fterms
	usable="$usable $use"
done

echo "using $nterms terms"

echo -n "'$word' é um conceito "
while read term
do
	echo -n "$term "
done < <(echo "$usable" | shuf)

echo ""
