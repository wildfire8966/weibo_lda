#!/bin/bash
source /usr/home/weibo_dm/.bash_profile

HADOOP_HOME=/usr/local/hadoop-2.4.0
part=blog_similarity_calculation

echo "*******`date` start: $0 $* *******"

INPUT_PATH=/user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs3_mid_topics
OUTPUT_PATH=/user/weibo_bigdata_dm/yuanye8/weibo_lda_output

${HADOOP_HOME}/bin/hadoop fs -rmr $OUTPUT_PATH

$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.4.0.jar \
-input $INPUT_PATH -output $OUTPUT_PATH \
-mapper mapper.py -reducer reducer.py \
-file ./mapper.py -file ./reducer.py \
-file ../../tmp_data/rs3_mid_topics -file ./object_set \
-jobconf mapred.map.tasks=50 -jobconf mapred.reduce.tasks=10 -jobconf mapred.job.name=$part

echo "*******`date` done: $0 $* *******"
