#mcc -R -nojvm -R -nodisplay -R -nodesktop -R -nosplash -mv -I ../SubME_1.6/ GenerateCorrMatrixRegion.m
for (( cc=1; cc<=1; cc=cc+1 ))
do
  for (( dd=1; dd<=10; dd=dd+1 ))
  do
    for (( xx=1; xx<=16; xx=xx+1 ))
    do
      for (( yy=1; yy<=9; yy=yy+1 ))
      	do
    	echo "
    	### Job name
    	#PBS -N Prediction_"$xx"_"$yy"_"$cc"_"$dd"

    	### out files
    	#PBS -e ./log/Prediction_"$xx"_"$yy"_"$cc"_"$dd".err
    	#PBS -o ./log/Prediction_"$xx"_"$yy"_"$cc"_"$dd".log

    	### put the job to which queue (qwork)
    	#PBS -q qwork
    	" > ./temp/Prediction_"$xx"_"$yy"_"$cc"_"$dd".sh

    	echo '
    	# show the time and information
    	echo Working directory is $PBS_O_WORKDIR
    	cd $PBS_O_WORKDIR
    	echo Running on host `hostname`
    	echo Start time is `date`
    	time1=`date +%s`
    	echo Directory is `pwd`
    	' >> ./temp/Prediction_"$xx"_"$yy"_"$cc"_"$dd".sh

    	echo "
    	# run the script
    	MCR_tmp=\"/tmp/mcr_\$RANDOM\"
    	mkdir \$MCR_tmp
    	export MCR_CACHE_ROOT=\$MCR_tmp
    	./GenerateCorrMatrixRegion "$xx" "$yy" "$cc" "$dd"
    	rm -rf \$MCR_tmp						
    	" >>  ./temp/Prediction_"$xx"_"$yy"_"$cc"_"$dd".sh

    	echo '
    	echo End time is `date`
    	time2=`date +%s`
    	echo Computing time is `echo $time2-$time1 | bc` sec
    	' >>   ./temp/Prediction_"$xx"_"$yy"_"$cc"_"$dd".sh

    	qsub ./temp/Prediction_"$xx"_"$yy"_"$cc"_"$dd".sh
      done
    done
  done
done
