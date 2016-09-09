#!/usr/bin/python2.6
#coding=utf-8

import sys
import gc

gc.disable()

words_map = {}

# 读取过滤词表
def get_words_map(file_path):
	for line in open(file_path):
		fields = line.strip().split('\t')	
		words_map[fields[0]] = 1

# 获取分词后的语料输入
def get_blog_input(input_path):
	for line in input_path:
		fields = line.strip().split('\t')
		if len(fields) == 3:
			yield fields	

# 根据词库过滤输入语料
def filter_words():
	data = get_blog_input(sys.stdin)
	for lines in data:
		items = lines[1].split(" ")
		tmp = [ x for x in items if x in words_map ]
		if len(tmp) < 2:
			continue
		sout = " ".join(tmp)
		if sout.strip() != "":
			print lines[0] + '\t' + sout + '\t' + lines[2]

if __name__ == "__main__":
	get_words_map("topic_words.list")
	filter_words()
