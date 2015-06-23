#mcc -R -nojvm -R -nodisplay -R -nodesktop -R -nosplash -mv -I ./Utility/ BBselection.m
for (( numCam=10; numCam<=30; numCam=numCam+5 ))
do
    	echo "
    	### Job name
    	#PBS -N Selection_"$numCam"

    	### out files
    	#PBS -e ./log/Selection_"$numCam".err
    	#PBS -o ./log/Selection_"$numCam".log

    	### put the job to which queue (qwork)
    	#PBS -q qwork
    	" > ./temp/Selection_"$numCam".sh

    	echo '
    	# show the time and information
    	echo Working directory is $PBS_O_WORKDIR
    	cd $PBS_O_WORKDIR
    	echo Running on host `hostname`
    	echo Start time is `date`
    	time1=`date +%s`
    	echo Directory is `pwd`
    	' >> ./temp/Selection_"$numCam".sh

    	echo "
    	# run the script
    	MCR_tmp=\"/tmp/mcr_\$RANDOM\"
    	mkdir \$MCR_tmp
    	export MCR_CACHE_ROOT=\$MCR_tmp
    	./BBselection "$numCam"
    	rm -rf \$MCR_tmp						
    	" >>  ./temp/Selection_"$numCam".sh

    	echo '
    	echo End time is `date`
    	time2=`date +%s`
    	echo Computing time is `echo $time2-$time1 | bc` sec
    	' >>   ./temp/Selection_"$numCam".sh

    	qsub ./temp/Selection_"$numCam".sh
done
