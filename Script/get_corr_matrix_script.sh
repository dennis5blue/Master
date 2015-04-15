#mcc -R -nojvm -R -nodisplay -R -nodesktop -R -nosplash -mv -I ../SubME_1.6/ GenerateCorrMatrix.m
for (( nn=0; nn<=9; nn=nn+1 ))
do
  for (( mm=0; mm<=9; mm=mm+1 ))
  do
    echo "
    ### Job name
    #PBS -N Prediction_"$nn"_"$mm"

    ### out files
    #PBS -e ./log/Prediction_"$nn"_"$mm".err
    #PBS -o ./log/Prediction_"$nn"_"$mm".log

    ### put the job to which queue (qwork)
    #PBS -q qwork
    " > ./Prediction_"$nn"_"$mm".sh

    echo '
    # show the time and information
    echo Working directory is $PBS_O_WORKDIR
    cd $PBS_O_WORKDIR
    echo Running on host `hostname`
    echo Start time is `date`
    time1=`date +%s`
    echo Directory is `pwd`
    ' >> ./Prediction_"$nn"_"$mm".sh

    echo "
    # run the script
    MCR_tmp=\"/tmp/mcr_\$RANDOM\"
    mkdir \$MCR_tmp
    export MCR_CACHE_ROOT=\$MCR_tmp
    ./GenerateCorrMatrix "$nn" "$mm"
    rm -rf \$MCR_tmp						
    " >>  ./Prediction_"$nn"_"$mm".sh

    echo '
    echo End time is `date`
    time2=`date +%s`
    echo Computing time is `echo $time2-$time1 | bc` sec
    ' >>   ./Prediction_"$nn"_"$mm".sh

    qsub ./Prediction_"$nn"_"$mm".sh
  done
done
