#!/bin/bash
source /usr/home/weibo_dm/.bash_profile

DT_PART="20160714"

function get_object_set() {
hive -e "
insert overwrite local directory './object_words'
select object_name from bigdata_mds_object_info where dt='$DT_PART'
"
}

get_object_set
cat object_words/* | python2.6 trim.py > object_set
rm -rf object_words
