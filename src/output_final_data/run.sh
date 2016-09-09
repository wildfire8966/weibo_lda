#!/bin/bash
source /usr/home/weibo_dm/.bash_profile

echo -e "pull data from remote."
rsync -avz 10.73.20.41::yuanye/info_3 ./info_3_part1
rsync -avz 10.77.136.41::yuanye/info_3 ./info_3_part2
cat info_3_part1 > tmp
cat info_3_part2 >> tmp
cat tmp | sort | uniq > info_3
rm tmp
rm info_3_part1
rm info_3_part2
echo -e "pull data end."

HADOOP_HOME=/usr/local/hadoop-2.4.0
part=blog_similarity_output_json

echo "*******`date` start: $0 $* *******"

INPUT_PATH=/user/weibo_bigdata_dm/yuanye8/result/weibo_lda_output
OUTPUT_PATH=/user/weibo_bigdata_dm/yuanye8/result/weibo_lda_output_json

${HADOOP_HOME}/bin/hadoop fs -rmr $OUTPUT_PATH

$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.4.0.jar \
-input $INPUT_PATH -output $OUTPUT_PATH \
-mapper mapper.py -reducer reducer.py \
-file ./mapper.py -file ./reducer.py \
-file ./info_3 \
-jobconf mapred.map.tasks=50 -jobconf mapred.reduce.tasks=10 -jobconf mapred.job.name=$part

echo "*******`date` done: $0 $* *******"
