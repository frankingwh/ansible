#! /bin/bash
reportpath="/tmp/kernel_module_report.txt"
kermods=$(lsmod | awk '{print $1}' | grep -v Module)

if [ -f $reportpath ]; then
  $(rm -f $reportpath)
fi

for mod in $kermods; do
  echo "$mod" >> $reportpath
  $(modinfo $mod | grep version >> $reportpath)
  echo -e "\n" >> $reportpath
done 

cat $reportpath
