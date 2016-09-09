#!/usr/bin/python2.6
#coding=utf-8

import sys
from math import sqrt, pow

import gc

gc.disable()

file_map = {}
object_set = set()

# 读取文件转化为内存对象
def get_file_to_map(file_path):
	lines = open(file_path)
	for line in lines:
		line = line.strip().split("\t")
		if len(line) != 4 or line[1].strip() == "[]":
			continue
		file_map[line[0]] = trans_topics(line[1], line[2], line[3])
	return file_map

# 三级对象,用作过滤使用
def get_object_set(file_path):
	lines = open(file_path)
	for line in lines:
		field = line.strip()
		if field != "":
			object_set.add(field)

# 转化函数，被get_file_to_map调用
def trans_topics(line, line2, line3):
	#print line
	topic_pro = {}
	blog_info = {}
	line = line.strip().strip("[").strip("]")
	items = line.split(",")
	for item in items:
		tmp = item.split("/")
		topic_pro[tmp[0]] = tmp[1]
	blog_info["topics"] = topic_pro
	blog_info["cates"] = line2.strip()
	blog_info["words"] = line3.strip().split(" ")
	return blog_info

def str_to_set(s):
	ss = s.split(",")
	return set(ss)

def cal_each_point(map_obj):
	for line in sys.stdin:
		lines = line.strip().split('\t')
		mid = lines[0]
		if map_obj.has_key(mid):
			cates1 = str_to_set(map_obj.get(mid).get("cates"))
			topics1 = map_obj.get(mid).get("topics")
			words1 = map_obj.get(mid).get("words")
		else:
			continue
		for x in map_obj:
			if mid == x:
				continue
			cates2 = str_to_set(map_obj.get(x).get("cates"))
			topics2 = map_obj.get(x).get("topics")
			words2 = map_obj.get(x).get("words")
			
			cates3 = cates1.intersection(cates2)
			topics_keys = set(topics1.keys()).intersection(topics2.keys())
			words3 = set(words1).intersection(set(words2))
			
			has_common_objects = False
			#判断两条博文是否拥有相同的三级标签
			for word in words3:
				if word in object_set:
					has_common_objects = True
					break
			if len(cates3) == 0 or not has_common_objects:
				continue
			result = 0.0
			for y in topics_keys:
				a = float(topics1.get(y))
				b = float(topics2.get(y))
				#tmp_rs = pow(abs(sqrt(a) - sqrt(b)),2)
				tmp_rs = get_rs(a,b)
				result = result + tmp_rs
			if result > 0:
				print mid + '\t' + x + '\t' + str(round(result,3)) + '\t' + ",".join(list(topics_keys)) + '\t' + ",".join(list(cates3))		

# 暂时计算公式
def get_rs(a,b):
	div_percent = abs(a-b) / max(a,b)
	if a >= 0.9 and b >= 0.9:
		return 50.0 * (a + b)
	if a >= 0.8 and b >= 0.8:
		return 20.0 * (a + b)
	if a >= 0.7 and b >= 0.7:
		return 15.0 * (a + b)
	if div_percent < 0.37 and (a >= 0.6 or b>= 0.6):
		return 10.0 * (a + b)
	else:
		return 5.0 * (a + b)	

if __name__ == "__main__":
	if len(sys.argv) == 1:
		map_obj = get_file_to_map("rs3_mid_topics")
		get_object_set("object_set")
	if len(sys.argv) == 2 and sys.argv[1] == "local":
		map_obj = get_file_to_map("../../tmp_data/rs3_mid_topics")
		get_object_set("object_set")
	cal_each_point(map_obj)
