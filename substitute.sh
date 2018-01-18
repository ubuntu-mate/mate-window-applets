#! /bin/bash

cp $1 $2

sed -i -e 's,@VERSION@,1.5.1,g' $2;

if [[ ! -z $3 ]]; then

	sed -i -e 's,@LOCATION@,'${3}',g' $2;

fi
