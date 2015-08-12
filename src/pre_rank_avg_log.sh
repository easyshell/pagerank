#!/bin/bash

while [ 1 -lt 2 ]; do
	ori_last=$(tail -1 pre_rank_avg.txt)
	des_last=$(tail -1 log_rank_avg.txt)
	echo $ori_last","$des_last
	if [ "$ori_last" !=  "$des_last" ]; then 
		echo "$ori_last" >> log_rank_avg.txt
		sleep 3m
	fi
	sleep 30s
done

	


