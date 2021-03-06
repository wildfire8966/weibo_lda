使用LDA模型进行主题相似博文推荐
===============================
1. LDA模型训练 
-------------------------------

hadoop版本训练基本成形，对阿尔法、贝塔、迭代次数、主题数等参数调优后稳定运行 

* hadoop版本扩展性强，数据量目前为130万预料，预计1千万内预料时间都不会线性增长
* 运行稳定，有中断机制，失败后可以接之前迭代进行
* 占用资源较少，适合多人作业

spark版本训练 

* 数据量在100万内存吃紧，且占用资源过多
* 运行不稳定，出现多种异常，中断后无法继续（缺乏中间结果回写磁盘机制）
* 迭代收敛速度较慢

2. 博文相似度计算
-------------------------------
* 相似度计算流程自动化：将LDA相似度结果加入协同计算进行补充，约定数据输出路径和格式，定时计算推送到指定HDFS路径下
* 进行了预测程序和相似度计算程序的优化，拉取数据—数据过滤—预测主题—相似度计算，控制在30分钟之内
* 当前数据量为3天博文，计算后约覆盖2-3万博文

下一步工作计划
===============================
1. LDA训练优化与探索
-------------------------------
* 尝试更细粒度的主题聚类：集群资源是否支持、最终效果是否更好
* 学习Hadoop Java API，尝试编写MR程序和使用压缩格式。对于时间要求较高的任务及需要封装工具包的任务，Java能提高更高的计算效率和更容易、规范的使用方式
2. Spark LDA探索
-------------------------------
*  磁盘回写机制，以便中断后可以从中断处继续运行
*  EM算法和Online算法尝试，目前集群设置Online算法报错

data下为项目必须数据
==============================
其中:
* data为hanlp java分词包使用的字典
* model.phi.3为LDA模型训练出的模型
* topic_words.list为过滤语料的词典
* lib下为项目使用的jar包:fenci.jar在分词步骤时使用
* tmp_data暂存整个计算流程中暂存的数据
* result存放两份数据，一份为行文本格式存放的简要输出文件，一份为格式化为json串的文件
