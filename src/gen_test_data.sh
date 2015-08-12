#!/bin/bash

awk '{
	if (1 == ARGIND) {
		if (!has[$1]) print $1
		if (!has[$2]) print $2
		has[$1] = 1; has[$2] = 1
	}
}' weibo.200

