#!/usr/bin/python
#coding=utf-8

import sys
import gc

gc.disable()

left_1 = "（".decode("utf-8")
right_1 = "）".decode("utf-8")
left_2 = "(".decode("utf-8")
right_2 = ")".decode("utf-8")

for line in sys.stdin:
	line = line.strip().decode("utf-8")
	
	index_l = line.find(left_1)
	if index_l == -1:
		index_l = line.find(left_2)
	index_r = line.find(right_1)
	if index_r == -1:
		index_r = line.find(right_2)
	
	if index_l == -1 or index_r == -1:
		print line.encode("utf-8")
		continue
	print (line[0:index_l]).encode("utf-8")
	print (line[index_l+1:index_r]).encode("utf-8")
