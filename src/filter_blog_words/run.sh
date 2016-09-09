#!/bin/bash
source /usr/home/weibo_dm/.bash_profile

HADOOP_HOME=/usr/local/hadoop-2.4.0
part=mid_blog_words_filtered

echo "*******`date` start: $0 $* *******"

INPUT_PATH=/user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs2_mid_blog_words
OUTPUT_PATH=/user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs2_mid_blog_words_filtered

${HADOOP_HOME}/bin/hadoop fs -rmr $OUTPUT_PATH

$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.4.0.jar \
-input $INPUT_PATH -output $OUTPUT_PATH \
-mapper filter_blog_words.py -reducer cat \
-file ./filter_blog_words.py -file ../../data/topic_words.list \
-jobconf mapred.map.tasks=50 -jobconf mapred.reduce.tasks=10 -jobconf mapred.job.name=$part

echo "*******`date` done: $0 $* *******"
