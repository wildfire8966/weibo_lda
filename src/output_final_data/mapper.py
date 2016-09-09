#!/usr/bin/python
#coding=utf-8

import json
import sys

import gc

gc.disable()

info_map = {}
final_map = {}

def read_info(file_path):
	data = open(file_path)
	for line in data:
		fields = line.strip().split("\t")
		cates = fields[1]
		gid = fields[2]
		if len(fields) < 3:
			continue
		info_map[fields[0]] = (cates, gid)

read_info("info_3")

for line in sys.stdin:
	fields = line.strip().split('\t')
	mid1 = fields[0]
	mids = fields[1].split(",")
	tmp = []
	for x in mids:
		items = x.split("/")
		mid = items[0]
		score = items[1]
		if not info_map.has_key(mid):
			continue
		cates = info_map[mid][0]
		gid = info_map[mid][1]
		cates = cates.strip().split(",")
		tmp_map = {}
		tmp_map["categoryid"] = cates 
		tmp_map["mid"] = mid
		tmp_map["weight"] = score
		tmp_map["groupid"] = gid
		tmp.append(tmp_map)
	if len(tmp) == 0:
		continue
	final_map["connection_type"] = "cfmid" 
	final_map["from_id"] = mid1
	final_map["to_id"] = tmp
	print mid1 + "\t" + json.dumps(final_map)
	

