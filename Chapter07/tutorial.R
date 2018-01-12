library(doMC)
registerDoMC(cores = 8)

data("PimaIndiansDiabetes2",package = 'mlbench')
set.seed(100)
diab <- PimaIndiansDiabetes2

diab <- knnImputation(diab)
training_index <- createDataPartition(diab$diabetes, p = .8, list = FALSE, times = 1)

diab_train <- diab[training_index,]
diab_test  <- diab[-training_index,]

diab_control <- trainControl("repeatedcv", number = 10, repeats = 3, search = "random", classProbs = TRUE)

nn_model <- train(diabetes ~ ., data = diab_train, method = "nnet", 
                  preProc = c("center", "scale"), trControl = diab_control, tuneLength = 10, metric = "Accuracy")


varImp(nn_model)

predictions <- predict(nn_model, diab_test[,-ncol(diab_test)])
head(predictions)

cf <- confusionMatrix(predictions, diab_test$diabetes)
cf

plot(nn_model)
fourfoldplot(cf$table)


