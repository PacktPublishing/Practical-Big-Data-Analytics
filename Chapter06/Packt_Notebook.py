# Databricks notebook source
# MAGIC %md
# MAGIC #![Spark Logo](http://spark-mooc.github.io/web-assets/images/ta_Spark-logo-small.png) + ![Python Logo](http://spark-mooc.github.io/web-assets/images/python-logo-master-v3-TM-flattened_small.png)
# MAGIC # ** Basic Introduction to a few Spark Commands **
# MAGIC 
# MAGIC This notebook is based on tutorials conducted by [Databricks](https://databricks.com). The tutorial will be conducted using the Databricks' Community Edition of Spark available for sign up [here](https://databricks.com/try-databricks). Databricks is a leading provider of the commercial and enterprise supported version of Spark.
# MAGIC 
# MAGIC In this lab, we will introduce a few basic commands used in Spark. Users are encouraged to try out more extensive Spark tutorials and notebooks that are available on the web for more detailed examples.
# MAGIC 
# MAGIC Documentation for [Spark's Python API](https://spark.apache.org/docs/latest/api/python/pyspark.html#pyspark.sql).

# COMMAND ----------

# The SparkContext/SparkSession is the entry point for all Spark operations
# sc = the SparkContext = the execution environment of Spark, only 1 per JVM
# Note that SparkSession is now the entry point (from Spark v2.0)
# This tutorial uses SparkContext (was used prior to Spark 2.0)

from pyspark import SparkContext
# sc = SparkContext(appName = "some_application_name") # You'd normally run this, but in this case, it has already been created in the Databricks' environment

# COMMAND ----------

quote = "To be, or not to be, that is the question:  Whether 'tis nobler in the mind to suffer  The slings and arrows of outrageous fortune,  Or to take Arms against a Sea of troubles,  And by opposing end them: to die, to sleep  No more; and by a sleep, to say we end  the heart-ache, and the thousand natural shocks  that Flesh is heir to? 'Tis a consummation  devoutly to be wished. To die, to sleep,  To sleep, perchance to Dream; aye, there's the rub,  for in that sleep of death, what dreams may come,  when we have shuffled off this mortal coil, must give us pause."

# COMMAND ----------

sparkdata = sc.parallelize(quote.split(' '))

# COMMAND ----------

print "sparkdata = ", sparkdata
print "sparkdata.collect = ", sparkdata.collect
print "sparkdata.collect() = ", sparkdata.collect()[1:10]

# COMMAND ----------

# A simple transformation - map

def mapword(word):
  return (word,1)

print sparkdata.map(mapword) # Nothing has happened here
print sparkdata.map(mapword).collect()[1:10] # collect causes the DAG to execute

# COMMAND ----------

# Another Transformation

def charsmorethan2(tuple1):
  if len(tuple1[0])>2:
    return tuple1
  pass

rdd3 = sparkdata.map(mapword).filter(lambda x: charsmorethan2(x))
# Multiple Transformations in 1 statement, nothing is happening yet

rdd3.collect()[1:10] # The DAG gets executed. Note that since we didn't remove punctuation marks ... 'be,', etc are also included

# COMMAND ----------

# With Tables, a general example

cms = sc.parallelize([[1,"Dr. A",12.50,"Yale"],[2,"Dr. B",5.10,"Duke"],[3,"Dr. C",200.34,"Mt. Sinai"],[4,"Dr. D",5.67,"Duke"],[1,"Dr. E",52.50,"Yale"]])

# COMMAND ----------

def findPayment(data):
  return data[2]

print "Payments = ", cms.map(findPayment).collect()
print "Mean = ", cms.map(findPayment).mean() # Mean is an action

# COMMAND ----------

# Creating a DataFrame (familiar to Python programmers)

cms_df = sqlContext.createDataFrame(cms, ["ID","Name","Payment","Hosp"])
print cms_df.show()
print cms_df.groupby('Hosp').agg(func.avg('Payment'), func.max('Payment'),func.min('Payment'))
print cms_df.groupby('Hosp').agg(func.avg('Payment'), func.max('Payment'),func.min('Payment')).collect()
print
print "Converting to a Pandas DataFrame"
print "--------------------------------"
pd_df = cms_df.groupby('Hosp').agg(func.avg('Payment'), func.max('Payment'),func.min('Payment')).toPandas()
print type(pd_df)
print
print pd_df




# COMMAND ----------

wordsList = ['to','be','or','not','to','be']
wordsRDD = sc.parallelize(wordsList, 3) # Splits into 2 groups
# Print out the type of wordsRDD
print type(wordsRDD)

# COMMAND ----------

# Glom coallesces all elements within each partition into a list
print wordsRDD.glom().take(2) # Take is an action, here we are 'take'-ing the first 2 elements of the wordsRDD
print wordsRDD.glom().collect() # Collect

# COMMAND ----------

# An example with changing the case of words

# One way of completing the function
def makeUpperCase(word):
    return word.upper()

print makeUpperCase('cat')


# COMMAND ----------

upperRDD = wordsRDD.map(makeUpperCase)
print upperRDD.collect()

# COMMAND ----------

upperLambdaRDD = wordsRDD.map(lambda word: word.upper())
print upperLambdaRDD.collect()

# COMMAND ----------

# Pair RDDs
wordPairs = wordsRDD.map(lambda word: (word, 1))
print wordPairs.collect()

# COMMAND ----------

# MAGIC %md
# MAGIC #### Part 2: Counting with pair RDDs 
# MAGIC There are multiple ways of performing group-by operations in Spark
# MAGIC One such method is groupByKey()
# MAGIC 
# MAGIC ** Using groupByKey() **
# MAGIC 
# MAGIC This method creates a key-value pair whereby each key (in this case word) is assigned a value of 1 for our wordcount operation. It then combines all keys into a single list. This can be quite memory intensive, especially if the dataset is large.

# COMMAND ----------

# Using groupByKey
wordsGrouped = wordPairs.groupByKey()
for key, value in wordsGrouped.collect():
    print '{0}: {1}'.format(key, list(value))

# COMMAND ----------

# Summation of the key values (to get the word count)
wordCountsGrouped = wordsGrouped.map(lambda (k,v): (k, sum(v)))
print wordCountsGrouped.collect()

# COMMAND ----------

# MAGIC %md
# MAGIC ** (2c) Counting using reduceByKey **
# MAGIC 
# MAGIC reduceByKey creates a new pair RDD. It then iteratively applies a function first to each key (i.e., within the key values) and then across all the keys, i.e., in other words it applies the given function iteratively.

# COMMAND ----------

wordCounts = wordPairs.reduceByKey(lambda a,b: a+b)
print wordCounts.collect()

# COMMAND ----------

# MAGIC %md
# MAGIC ** Combining all of the above into a single statement **

# COMMAND ----------

wordCountsCollected = (wordsRDD
                       .map(lambda word: (word, 1))
                       .reduceByKey(lambda a,b: a+b)
                       .collect())
print wordCountsCollected

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC This tutorial has provided a basic overview of Spark and introduced the Databricks community edition where users can upload and execute their own Spark notebooks. There are various in-depth tutorials on the web and also at Databricks on Spark and users are encouraged to peruse them if interested in learning further about Spark. 
