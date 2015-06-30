for (( cam=1; cam<=30; cam=cam+1 ))
do
  echo "
  ### Job name
  #PBS -N Encode_"$cam"

  ### out files
  #PBS -e ./log/Encode_"$cam".err
  #PBS -o ./log/Encode_"$cam".log

  ### put the job to which queue (qwork)
  #PBS -q qwork
  " > ./temp/Encode_"$cam".sh

  echo '
  # show the time and information
  echo Working directory is $PBS_O_WORKDIR
  cd $PBS_O_WORKDIR
  echo Running on host `hostname`
  echo Start time is `date`
  time1=`date +%s`
  echo Directory is `pwd`
  ' >> ./temp/Encode_"$cam".sh

  echo "
  # run the script
  MCR_tmp=\"/tmp/mcr_\$RANDOM\"
  mkdir \$MCR_tmp
  export MCR_CACHE_ROOT=\$MCR_tmp
  python encode_phase1.py --yuv camera_$cam.yuv
  rm -rf \$MCR_tmp						
  " >>  ./temp/Encode_"$cam".sh

  echo '
  echo End time is `date`
  time2=`date +%s`
  echo Computing time is `echo $time2-$time1 | bc` sec
  ' >>   ./temp/Encode_"$cam".sh

  qsub ./temp/Encode_"$cam".sh
done
