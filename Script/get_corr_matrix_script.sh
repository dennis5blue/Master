#mcc -R -nojvm -R -nodisplay -R -nodesktop -R -nosplash -mv -I ../SubME_1.6/ GenerateCorrMatrixRegion.m
for (( cam=6; cam<=6; cam=cam+1 ))
do
  for (( ref=1; ref<=50; ref=ref+1 ))
  do
    	echo "
    	### Job name
    	#PBS -N Prediction_"$cam"_"$ref"

    	### out files
    	#PBS -e ./log/Prediction_"$cam"_"$ref".err
    	#PBS -o ./log/Prediction_"$cam"_"$ref".log

    	### put the job to which queue (qwork)
    	#PBS -q qwork
    	" > ./temp/Prediction_"$cam"_"$ref".sh

    	echo '
    	# show the time and information
    	echo Working directory is $PBS_O_WORKDIR
    	cd $PBS_O_WORKDIR
    	echo Running on host `hostname`
    	echo Start time is `date`
    	time1=`date +%s`
    	echo Directory is `pwd`
    	' >> ./temp/Prediction_"$cam"_"$ref".sh

    	echo "
    	# run the script
    	MCR_tmp=\"/tmp/mcr_\$RANDOM\"
    	mkdir \$MCR_tmp
    	export MCR_CACHE_ROOT=\$MCR_tmp
    	./GenerateCorrMatrixRegion "$cam" "$ref"
    	rm -rf \$MCR_tmp						
    	" >>  ./temp/Prediction_"$cam"_"$ref".sh

    	echo '
    	echo End time is `date`
    	time2=`date +%s`
    	echo Computing time is `echo $time2-$time1 | bc` sec
    	' >>   ./temp/Prediction_"$cam"_"$ref".sh

    	qsub ./temp/Prediction_"$cam"_"$ref".sh
  done
done
