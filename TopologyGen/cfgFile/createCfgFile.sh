#!/bin/bash
for i in {1..17}
do
  cp ./01cam0Diff.cfg ./01cam${i}Diff.cfg
  sed -i s/cam0/cam${i}/g 01cam${i}Diff.cfg
done
