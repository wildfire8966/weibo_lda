#!/bin/bash
source /usr/home/weibo_bigdata_dm/.bash_profile

#基础路径
SRC_PATH=`pwd`
BASE_DATA="$SRC_PATH/../data"
BASE_TMP_DATA="$SRC_PATH/../tmp_data"
BASE_RESULT="$SRC_PATH/../result"
#LDA模型数据
LDA_DATA_PATH="$BASE_DATA/model.phi.3"
#临时数据
TMP="$BASE_TMP_DATA/tmp"
#分词JAR包
FENCI_JAR="$SRC_PATH/../lib/fenci.jar"
#抽取后数据
MID_MBLOG_PATH="$BASE_TMP_DATA/rs1_mid_blog_3"
#分词后数据
MID_MBLOG_WORDS_PATH="$BASE_TMP_DATA/rs2_mid_blog_words"
#过滤后数据
MID_MBLOG_WORDS_PATH_FILTER="$BASE_TMP_DATA/rs2_mid_blog_words_filtered"
#使用LDA模型后输出top5主题
MID_TOPICS_PATH="$BASE_TMP_DATA/rs3_mid_topics"
#最终结果
RESULT_DATA=`date '+%Y%m%d'`
RESULT="$BASE_RESULT/result_${RESULT_DATA}"

#日期格式化
function log() {
echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] $1\n"
}

#删除指定文件
function deleteFile() {
if [ -f "$1" ];then
  rm $1
else
  echo "file $1 is not exist."
fi
}

#删除指定文件夹内的全部文件
function deleteFiles() {
DIRECTORY=$1
FILE_LIST=`ls $1`
if [ ! -d "$DIRECTORY" ];then
  echo "$FILE_LIST"
  echo "$DIRECTORY not a directory.";
  exit -1;
fi
echo $FILE_LIST;
for file in $FILE_LIST;
do
  rm $1/$file
  echo "delete file $file"
done
echo "delete tmp file end."
}

#检查文件是否存在
function checkFileExists() {
if [ ! -f "$1" ]; then
	echo "get path:$1 ready failed!";
	exit -1;
fi	
}

#检查文件目录是否存在
function checkDirectoryExists() {
if [ ! -d "$1" ]; then
  echo "get directory:$1 ready failed!";
  exit -1;
fi
}

log "Program start."

#预处理操作
deleteFiles $BASE_TMP_DATA

echo -e "pull data from 41.\n"
rsync -avz 10.77.136.41::yuanye/rs1_mid_blog_3_part1 $BASE_TMP_DATA
rsync -avz 10.73.20.41::yuanye/rs1_mid_blog_3_part2 $BASE_TMP_DATA
cat $BASE_TMP_DATA/rs1_mid_blog_3_part1 > $BASE_TMP_DATA/tmp
cat $BASE_TMP_DATA/rs1_mid_blog_3_part2 >> $BASE_TMP_DATA/tmp
cat $BASE_TMP_DATA/tmp | sort | uniq > $BASE_TMP_DATA/rs1_mid_blog_3
deleteFile $BASE_TMP_DATA/tmp
deleteFile $BASE_TMP_DATA/rs1_mid_blog_3_part1
deleteFile $BASE_TMP_DATA/rs1_mid_blog_3_part2
echo -e "pull data end.\n"

checkFileExists $MID_MBLOG_PATH

/usr/local/jdk1.7.0_67/bin/java -cp $FENCI_JAR WeiboSegment "$MID_MBLOG_PATH" "$MID_MBLOG_WORDS_PATH" fenci

checkFileExists $MID_MBLOG_WORDS_PATH

cat $MID_MBLOG_WORDS_PATH | sort | uniq > $TMP
mv $TMP $MID_MBLOG_WORDS_PATH

#通过词库过滤数据
echo "filter blog....."
hadoop fs -rm /user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs2_mid_blog_words
hadoop fs -put $MID_MBLOG_WORDS_PATH /user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs2_mid_blog_words
cd filter_blog_words 
./run.sh
if [ -d rs2_mid_blog_words_filtered ];then
  rm -rf rs2_mid_blog_words_filtered
fi
hadoop fs -get /user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs2_mid_blog_words_filtered .
echo " [get file to $MID_MBLOG_WORDS_PATH_FILTER] "
cat rs2_mid_blog_words_filtered/* > $MID_MBLOG_WORDS_PATH_FILTER
rm -rf rs2_mid_blog_words_filtered
cd ..
echo "filter blog end....."

checkFileExists $MID_MBLOG_WORDS_PATH_FILTER

if [ "$1" == "step1" ];then
  echo "============stage1 end==============="
  exit 0
fi

function hadoop_infer() {
# 输入分词博文,进行主题计算,取top-5输出
log "input data in LDA for topic cal..."
cat "$MID_MBLOG_WORDS_PATH_FILTER" | ./TopicAnalysis "$LDA_DATA_PATH" > "$MID_TOPICS_PATH"
hadoop fs -rm /user/weibo_bigdata_dm/yuanye8/weibo_lda_input/rs3*
echo " [ upload file $MID_TOPICS_PATH to HDFS. ] "
hadoop fs -put $MID_TOPICS_PATH /user/weibo_bigdata_dm/yuanye8/weibo_lda_input
log "cal lda topics end."
}

hadoop_infer

checkFileExists $MID_TOPICS_PATH

# 计算博文相似度并取top-n输出,结果拉取到本地
log "cal each other's similarity and output final result..."
#python2.6 cal_blog_similar.py "$MID_TOPICS_PATH" "$RESULT"
cd cal_similar_hadoop_version
./run.sh
if [ -d ../../result/weibo_lda_output ];then
  rm -rf ../../result/weibo_lda_output
fi
hadoop fs -get /user/weibo_bigdata_dm/yuanye8/weibo_lda_output ../../result
log "cal similarity end."

checkDirectoryExists "../../result/weibo_lda_output"

# 统计输出信息
cd $SRC_PATH/../result/weibo_lda_output
rm _SUCCESS
lines=`cat * | wc -l`
echo "output: $lines lines data. path: [project]/result/weibo_lda_output"

# 推送到指定输出目录
log "mv output data to result direcotry."
nohup hadoop fs -ls /user/weibo_bigdata_dm/yuanye8/weibo_lda_output > /dev/null

if [ "$?" == 0 ];then
  hadoop fs -rmr /user/weibo_bigdata_dm/yuanye8/result/weibo_lda_output
  hadoop fs -mv /user/weibo_bigdata_dm/yuanye8/weibo_lda_output /user/weibo_bigdata_dm/yuanye8/result
else
  echo "get final similarity file failed, data still be previous results."
fi

# 转化json格式进行输出
log "trans data to json format."
cd $SRC_PATH/output_final_data
./run.sh
nohup hadoop fs -ls /user/weibo_bigdata_dm/yuanye8/result/weibo_lda_output_json > /dev/null
if [ "$?" == 0 ];then
  rm -rf ../../result/weibo_lda_output_json
  hadoop fs -get /user/weibo_bigdata_dm/yuanye8/result/weibo_lda_output_json ../../result/weibo_lda_output_json
else
  echo "trans json format file failed, data still be previous json results."
fi
