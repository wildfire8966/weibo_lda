#!/usr/bin/python
#coding=utf-8

import sys

for line in sys.stdin:
	line = line.split("\t")
	print line[1].strip()
