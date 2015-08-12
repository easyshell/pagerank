#!/bin/bash

relation_file="weibo.txt"
rank_file="rank.txt"
pre_rank_avg="None"

if !(test -f $rank_file); then
	echo "generate ori rank file, current time is $(date +%H:%M:%S)"
	awk '{
		if (1 != has[$1]) {
			has[$1] = 1
			printf("%s\t%s\t%s\n", $1, "1", "rank-1")
		}
		if (1 != has[$2]) {
			has[$2] = 1
			printf("%s\t%s\t%s\n", $2, "1", "rank-1")
		}
	}' $relation_file  > $rank_file
fi
echo $(date +%H:%M:%S)

relation_file_on_hadoop="hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/relation"
rank_file_on_hadoop="hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rank"
allotrank_on_hadoop="hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/allotrank"
hadoop fs -rm -r $relation_file_on_hadoop/
hadoop fs -rm -r $rank_file_on_hadoop/
hadoop fs -mkdir $relation_file_on_hadoop
hadoop fs -mkdir $rank_file_on_hadoop
hadoop fs -copyFromLocal $relation_file $relation_file_on_hadoop
hadoop fs -copyFromLocal $rank_file $rank_file_on_hadoop

function rankavgtmp {
	hadoop fs -rm -R -skipTrash /dev/maoxu.wang/pagerank/rankavg_tmp
	hadoop jar /opt/hadoop-2.2.0/share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar \
	-D stream.num.map.output.key.fields=1 \
	-input hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rank/* \
	-output hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rankavg_tmp \
	-mapper mapavg.py \
	-reducer reduceavg.py \
	-numReduceTasks 20 \
	-file mapavg.py reduceavg.py \
	-cmdenv "key_num=20" 
}

function calrankavg {
	rankavgtmp
	hadoop fs -rm -R -skipTrash /dev/maoxu.wang/pagerank/rankavg
	hadoop jar /opt/hadoop-2.2.0/share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar \
	-D stream.num.map.output.key.fields=1 \
	-input hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rankavg_tmp/* \
	-output hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rankavg \
	-mapper mapavg_1.py \
	-reducer reduceavg_1.py \
	-numReduceTasks 1 \
	-file mapavg_1.py reduceavg_1.py 
	hadoop fs -cat hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rankavg/* > pre_rank_avg.txt
	pre_rank_avg=$(cat pre_rank_avg.txt | awk '{print $2}')
}

function allotrank {
	hadoop fs -rm -R -skipTrash /dev/maoxu.wang/pagerank/allotrank
	hadoop jar /opt/hadoop-2.2.0/share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar \
	-D stream.num.map.output.key.fields=1 \
	-input hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/relation/* \
	-input hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rank/* \
	-output hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/allotrank \
	-mapper map2.py \
	-reducer reduce2.py \
	-numReduceTasks 20 \
	-file map2.py reduce2.py 
}

function calrank {
	calrankavg
	echo $pre_rank_avg
	hadoop fs -rm -R -skipTrash /dev/maoxu.wang/pagerank/output
	hadoop jar /opt/hadoop-2.2.0/share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar \
	-D stream.num.map.output.key.fields=1 \
	-input hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/allotrank/* \
	-output hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/output \
	-mapper map3.py \
	-reducer reduce3.py \
	-numReduceTasks 20 \
	-file map3.py reduce3.py \
	-cmdenv "pre_rank_avg=$pre_rank_avg" 
}

echo "start main"
for i in $(seq 1 1000); do
	allotrank
	if !(hadoop fs -test -d $allotrank_on_hadoop); then
		echo "allotrank is not gensrate"
		exit 1
	fi
	calrank
	hadoop fs -rm -R -skipTrash /dev/maoxu.wang/pagerank/rank
	hadoop fs -mv hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/output hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rank
	if [ $(echo "$i%10" | bc) -eq 0 ]; then 
		hadoop fs -cp hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rank hdfs://DEV-m162p111/dev/maoxu.wang/pagerank/rank_back_new/$i
	fi
	echo $(date +%H:%M:%S) >> log.txt
done

