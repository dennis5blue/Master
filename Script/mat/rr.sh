#!/bin/bash
for i in 10
do
  mv corrMatrix_$i\_9.mat corrMatrix_$i\_10.mat
  mv corrMatrix_$i\_8.mat corrMatrix_$i\_9.mat
  mv corrMatrix_$i\_7.mat corrMatrix_$i\_8.mat
  mv corrMatrix_$i\_6.mat corrMatrix_$i\_7.mat
  mv corrMatrix_$i\_5.mat corrMatrix_$i\_6.mat
  mv corrMatrix_$i\_4.mat corrMatrix_$i\_5.mat
  mv corrMatrix_$i\_3.mat corrMatrix_$i\_4.mat
  mv corrMatrix_$i\_2.mat corrMatrix_$i\_3.mat
  mv corrMatrix_$i\_1.mat corrMatrix_$i\_2.mat
  mv corrMatrix_$i\_0.mat corrMatrix_$i\_1.mat
done
