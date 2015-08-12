
round=$1
export hh="/dev/maoxu.wang/pagerank"
export selfdir=$(pwd);
test -e $selfdir/$round
if [ ! $? -eq 0 ]; then
	hadoop fs -copyToLocal $hh/rank_back/$round $selfdir
fi

echo $selfdir
echo $round
ori_dir=$selfdir/$round
echo "has downloaded $ori_dir to local"
for file in $(ls $ori_dir | grep -v "SUCCESS"); do
	echo $file
done
part_tot=$(ls $ori_dir | grep -v "SUCCESS" | wc -l)
echo "has part file total: $part_tot"

partsort_dir=$selfdir/partsort_"$round"
test -e $partsort_dir
if [ ! $? -eq 0 ]; then mkdir $partsort_dir; fi

part_file_list=$(ls $ori_dir | grep -v "SUCCESS")
#echo $part_file_list

for file in $part_file_list; do
	id=$(echo $file | awk -F'[-]' '{print int($2)}')
	echo $partsort_dir/$id
	$selfdir/bin/single_file_sort $ori_dir/$file $partsort_dir/$id
done 

merge_sort_result_file=$selfdir/output/merge_sort_result_file.txt
echo "write merge sort result to: $merge_sort_result_file"
if [ ! -d $(dirname $merge_sort_result_file) ]; then
	mkdir -p $(dirname $merge_sort_result_file)
fi

echo "remove $merge_sort_result_file before write to avoid it is alreadly exist"
rm -f $merge_sort_result_file

part_tot=$(ls $partsort_dir | wc -l)
echo "has part file to merge is $part_tot"
cd $partsort_dir; $selfdir/bin/merge_sort $merge_sort_result_file $part_tot
cd $selfdir;

unset hh
unset selfdir

echo "successful, all has done!"
