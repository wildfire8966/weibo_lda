#!/bin/bash
# 将spark推导得出的数据(格式mid topics) 进行连接转化,作为计算博文相似度的输入

function step1() {
hive -e "
drop table if exists tmp_yy_filtered_blogs;
create external table if not exists tmp_yy_filtered_blogs
(
  mid string,
  words string,
  cates string
) row format delimited fields terminated by '\t' location '/user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs2_mid_blog_words_filtered';

drop table if exists tmp_yy_doc_topics;
create external table if not exists tmp_yy_doc_topics
(
  mid string,
  topics string
) row format delimited fields terminated by '\t' location '/user/weibo_bigdata_dm/yuanye8/spark_lda_train/doc_topics';

drop table if exists tmp_yy_input_for_cal_similarity;
create table if not exists tmp_yy_input_for_cal_similarity
(
  mid string,
  topics string,
  cates string,
  words string
) row format delimited fields terminated by '\t';
"
}

function step2() {
hive -e "
insert overwrite table tmp_yy_input_for_cal_similarity
select a.mid, a.topics, b.cates, b.words 
from tmp_yy_doc_topics a join tmp_yy_filtered_blogs b
on a.mid = b.mid;
"
hdaoop fs -rmr /user/weibo_bigdata_dm/yuanye8/spark_lda_train/spark_rs3_mid_topics
hadoop fs -mkdir /user/weibo_bigdata_dm/yuanye8/spark_lda_train/spark_rs3_mid_topics
hadoop fs -mv /user/weibo_bigdata_dm/warehouse/tmp_yy_input_for_cal_similarity/* /user/weibo_bigdata_dm/yuanye8/spark_lda_train/spark_rs3_mid_topics
}

step1 
step2
