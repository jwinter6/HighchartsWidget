#!/usr/bin/env bash

name=$1
file="$name.js"

echo "Highcharts.chart('container$name'," > tmp
cat $file >> tmp
mv tmp $file
echo ");" >> $file
