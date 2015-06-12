for (( n=2; n<=30; n=n+1  ))
do
  rm "01cam"$n"Diff.cfg"
  cp "01cam1Diff.cfg" "01cam"$n"Diff.cfg"
  sed -i 's/cam1/cam'$n'/g' "01cam"$n"Diff.cfg" 
done
