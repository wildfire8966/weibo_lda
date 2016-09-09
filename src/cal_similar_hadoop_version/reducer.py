#!/usr/bin/python
#coding=utf-8

import sys

import gc

gc.disable()

top_n = 2
current_mid = None
count_map = {}
info_map = {}
isTrace = False

def output_current_mid():
	if len(count_map) == 0:
		return
	sorted_list = sorted(count_map.items(), lambda x, y : cmp(x[1],y[1]),reverse=True)
	result_list = sorted_list[0:top_n]
	score = [ x[0] + '/' + x[1] for x in result_list ]
	score_str = ','.join(score)
	if isTrace:
		topics = [ info_map[x[0]].get("topics") for x in result_list ]
		topics_str = ','.join(list(set(topics)))
		cates = [ info_map[x[0]].get("cates") for x in result_list]
		cates_str = ','.join(list(set(cates)))
		print current_mid + '\t' + score_str + '\t' + topics_str + '\t' + cates_str
	else:
		print current_mid + '\t' + score_str

def main():
	global count_map
	global current_mid
	global info_map

	for line in sys.stdin:
		lines = line.strip().split('\t')
		if len(lines) != 5:
			continue
		mid1 = lines[0]
		mid2 = lines[1]
		score = lines[2]
		topics = lines[3]
		cates = lines[4]
		
		if current_mid == None:
			current_mid = mid1
		
		if current_mid != mid1:
			output_current_mid()
			current_mid = mid1
			count_map = {}
			if isTrace:
				info_map = {}
				info_map[mid2] = {"cates":cates, "topics":topics}
			count_map[mid2] = score
			continue

		count_map[mid2] = score
		if isTrace:
			info_map[mid2] = {"cates":cates, "topics":topics}
	
	if len(count_map) != 0:
		output_current_mid()

if __name__ == "__main__":
	if len(sys.argv) == 2:
		if sys.argv[1] == "trace":
			isTrace = True
	main()
