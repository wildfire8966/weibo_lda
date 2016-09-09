#!/usr/bin/python2.6
# coding=utf-8
# Author:yuanye

import sys,os,json,time
import gc

gc.disable()

'''
Use example:
>>> from reader import Reader
>>> r = Reader()
Load data duration: 6.80373883247 seconds. Load 29608 items.
>>> r.get("something does not exists")
[]
>>> r.get("4017147388977894")
[(u'4017362506640743', u'1042015:tagCategory_041', u'G4017362506640743', u'93.98'), (u'4017102120228281', u'1042015:tagCategory_041', u'G4017102120228281', u'93.549')]
>>> r.next()
(u'4017402184572791', [(u'4017070842961757', u'1042015:tagCategory_050,1042015:tagCategory_033', u'G4017070842961757', u'25.278'), (u'4017731432387739', u'1042015:tagCategory_050,1042015:tagCategory_033', u'G4017731432387739', u'24.48')])
>>> r.current_size()
29606
'''

class Reader(object):

	file_path = '/usr/home/weibo_bigdata_dm/yuanye8/weibo_lda_similar_cal/result/weibo_lda_output_json'

	blog_map = {}

	def __init__(self, *file_path):
		if len(file_path) > 1:
			print 'Param number of init method can not be more than one.'
			sys.exit(-1)
		if len(file_path) == 1:
			self.file_path = file_path[0]
		self.load(self.file_path)
	
	def load(self, path):
		start = time.time()
		self.blog_map = {}
		print 'Loading data from ' + path
		if not os.path.isdir(path):
			print path + ' is not a directory.'
			sys.exit(-1)
		
		files =  os.listdir(path)
		for file in files:
			abs_path = path + "/" + file
			with open(abs_path) as f:
				try:
					for line in f:
						line = line.strip()
						tmp_map = json.loads(line)
						self.blog_map[tmp_map["from_id"]] = tmp_map
				except:
					continue
		duration = time.time() - start
		print "Load data duration: " + str(duration) + " seconds." + " Load " + str(len(self.blog_map)) + " items."

	def has_next(self):
		if len(self.blog_map) > 0:
			return True
		return False

	def current_size(self):
		return len(self.blog_map)

	def next(self):
		if len(self.blog_map) == 0:
			return None
		tup = self.blog_map.popitem()
		mid = tup[0]
		tmp_map = tup[1]
		tmp_list = tmp_map["to_id"]
		rs_list = self.maplist_to_tuplelist(tmp_list)
		return (mid, rs_list)

	def get(self, mid):
		if not self.blog_map.has_key(mid):
			return []
		tmp_list = self.blog_map.pop(mid)["to_id"]
		return self.maplist_to_tuplelist(tmp_list)

	def maplist_to_tuplelist(self, maplist):
		rs_list = []
		for item in maplist:
			mid = item["mid"]
			gid = item["groupid"]
			cates = ",".join(item["categoryid"])
			weight = item["weight"]
			rs_list.append((mid, cates, gid, weight))
		return rs_list

if __name__=="__main__":
	r = Reader()
	
	print "test get() with no result, return value: ",
	t = r.get("yuanye")
	print t
	
	print "test get() with result, return value: ",
	t = r.get("4016750339742109")
	print t
	
	print "test next() with result, return value: ",
	count = 0
	while r.has_next():
		r.next()
		count += 1
	print "total number => " + str(count)	
	
	print "test next() with no result, return value: ",
	t = r.next()
	print t
