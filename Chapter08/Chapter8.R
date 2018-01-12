# Chapter 8: Packt
# Regression
library("mlbench")
data("PimaIndiansDiabetes")
lm_model <- lm(glucose ~ pressure + triceps + insulin, data=PimaIndiansDiabetes[1:100,])
plot(lm_model)

# Decision Trees
install.packages("rpart")
install.packages("rpart.plot")

library(rpart)
library(rpart.plot)

rpart_model <- rpart (diabetes ~ glucose + insulin + mass + age, data = PimaIndiansDiabetes)
rpart_model

# Fast & Frugal Decision Trees

install.packages("FFTrees")
library(caret)
library(mlbench)
library(FFTrees)
set.seed(123)

data("PimaIndiansDiabetes")
diab <- PimaIndiansDiabetes
diab$diabetes <- 1 * (diab$diabetes=="pos")

train_ind <- createDataPartition(diab$diabetes,p=0.8,list=FALSE,times=1)

training_diab <- diab[train_ind,]
test_diab <- diab[-train_ind,]

diabetes.fft <- FFTrees(diabetes ~.,data = training_diab,data.test = test_diab)
plot(diabetes.fft)

# Random Forest

rf_model1 <- randomForest(diabetes ~ ., data=PimaIndiansDiabetes)
rf_model1

library(caret)
library(doMC)

# THE NEXT STEP IS VERY CRITICAL – YOU DO ‘NOT’ NEED TO USE MULTICORE
# NOTE THAT THIS WILL USE ALL THE CORES ON THE MACHINE THAT YOU ARE
# USING TO RUN THE EXERCISE

# REMOVE THE # MARK FROM THE FRONT OF registerDoMC BEFORE RUNNING
# THE COMMAND

# registerDoMC(cores = 8) # CHANGE NUMBER OF CORES TO MATCH THE NUMBER OF CORES ON YOUR MACHINE 
  
rf_model <- train(diabetes ~ ., data=PimaIndiansDiabetes, method="rf")
rf_model

getTrainPerf(rf_model)

# Boosting - eXtreme Gradient Boosting
library(caret)
library(xgboost)

set.seed(123)
train_ind <- sample(nrow(PimaIndiansDiabetes),as.integer(nrow(PimaIndiansDiabetes)*.80))

training_diab <- PimaIndiansDiabetes[train_ind,]
test_diab <- PimaIndiansDiabetes[-train_ind,]

diab_train <- sparse.model.matrix(~.-1, data=training_diab[,-ncol(training_diab)])
diab_train_dmatrix <- xgb.DMatrix(data = diab_train, label=training_diab$diabetes=="pos")

diab_test <- sparse.model.matrix(~.-1, data=test_diab[,-ncol(test_diab)])
diab_test_dmatrix <- xgb.DMatrix(data = diab_test, label=test_diab$diabetes=="pos")



param_diab <- list(objective = "binary:logistic",
                   eval_metric = "error",
                   booster = "gbtree",
                   max_depth = 5,
                   eta = 0.1)

xgb_model <- xgb.train(data = diab_train_dmatrix,
                       param_diab, nrounds = 1000,
                       watchlist = list(train = diab_train_dmatrix, test = diab_test_dmatrix),
                       print_every_n = 10)


predicted <- predict(xgb_model, diab_test_dmatrix)
predicted <- predicted > 0.5

actual <- test_diab$diabetes == "pos"
confusionMatrix(actual,predicted)

# Support Vector Machines


library(mlbench)
library(caret)
library(e1071)
set.seed(123)


data("PimaIndiansDiabetes")
diab <- PimaIndiansDiabetes

train_ind <- createDataPartition(diab$diabetes,p=0.8,list=FALSE,times=1)

training_diab <- diab[train_ind,]
test_diab <- diab[-train_ind,]

svm_model <- svm(diabetes ~ ., data=training_diab)
plot(svm_model,training_diab, glucose ~ mass)

svm_predicted <- predict(svm_model,test_diab[,-ncol(test_diab)])
confusionMatrix(svm_predicted,test_diab$diabetes)

# K-Means

library(data.table)
library(ggplot2)
library()

historyData <- fread("history.csv") # Change to your appropriate location
ggplot(historyData,aes(american_history,asian_history)) + geom_point() + geom_jitter()

historyCluster <- kmeans(historyData,2) # Create 2 clusters
historyData[,cluster:=as.factor(historyCluster$cluster)]
ggplot(historyData, aes(american_history,asian_history,color=cluster)) + geom_point() + geom_jitter()

# Neural Network
library(mlbench)
library(caret)
set.seed(123)

data("PimaIndiansDiabetes")
diab <- PimaIndiansDiabetes

train_ind <- createDataPartition(diab$diabetes,p=0.8,list=FALSE,times=1)
training_diab <- diab[train_ind,]
test_diab <- diab[-train_ind,]

nnet_grid <- expand.grid(.decay = c(0.5,0.1), .size = c(3,5,7))
nnet_model <- train(diabetes ~ ., data = training_diab, method = "nnet", metric = "Accuracy", maxit = 500, tuneGrid = nnet_grid)
nnet_predicted <- predict(nnet_model, test_diab)

confusionMatrix(nnet_predicted,test_diab$diabetes)




