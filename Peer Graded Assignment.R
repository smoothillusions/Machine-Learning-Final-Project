## Prep the Data 

library(caret, lib="C:/rprogramming/rPackages") 
library(ggplot2, lib="C:/rprogramming/rPackages") 

setwd("C:/rprogramming/Course 7 Practical Machine Learining/Course Project") 
ptrain <- read.csv("pml-training.csv") 
ptest <- read.csv("pml-testing.csv") 


set.seed(10) 
inTrain <- createDataPartition(y=ptrain$classe, p=0.7, list=F) 
ptrain1 <- ptrain[inTrain, ] 
ptrain2 <- ptrain[-inTrain, ] 


# remove variables with nearly zero variance 
nzv <- nearZeroVar(ptrain1) 
ptrain1 <- ptrain1[, -nzv] 
ptrain2 <- ptrain2[, -nzv] 


# remove variables that are almost always NA 
mostlyNA <- sapply(ptrain1, function(x) mean(is.na(x))) > 0.95 
ptrain1 <- ptrain1[, mostlyNA==F] 
ptrain2 <- ptrain2[, mostlyNA==F] 

# remove variables that don't make intuitive sense for prediction (X, user_name, raw_timestamp_part_1, raw_timestamp_part_2, cvtd_timestamp), which happen to be the first five variables 
ptrain1 <- ptrain1[, -(1:5)] 
 
## Build the model 
# instruct train to use 3-fold CV to select optimal tuning parameters 
fitControl <- trainControl(method="cv", number=3, verboseIter=F) 


## Problem with Packages loading ( if loaded correctly ## the next 2 lines out ) 
install.packages("e1071", lib="C:/rprogramming/rPackages") 
library(e1071, lib="C:/rprogramming/rPackages") 


# fit model on ptrain1 
fit <- train(classe ~ ., data=ptrain1, method="rf", trControl=fitControl) 

# print final model to see tuning parameters it chose 
fit$finalModel 

##Evaluate the model 
# use model to predict classe in validation set (ptrain2) 
preds <- predict(fit, newdata=ptrain2) 

# show confusion matrix to get estimate of out-of-sample error 
confusionMatrix(ptrain2$classe, preds) 


## Retrain the model 
# remove variables with nearly zero variance 
nzv <- nearZeroVar(ptrain) 
ptrain <- ptrain[, -nzv] 
ptest <- ptest[, -nzv] 


# remove variables that are almost always NA 
mostlyNA <- sapply(ptrain, function(x) mean(is.na(x))) > 0.95 
ptrain <- ptrain[, mostlyNA==F] 
ptest <- ptest[, mostlyNA==F] 

# remove variables that don't make intuitive sense for prediction (X, user_name, raw_timestamp_part_1, raw_timestamp_part_2, cvtd_timestamp), which happen to be the first five variables 
ptrain <- ptrain[, -(1:5)] 
ptest <- ptest[, -(1:5)] 

# re-fit model using full training set (ptrain) 
fitControl <- trainControl(method="cv", number=3, verboseIter=F) 
fit <- train(classe ~ ., data=ptrain, method="rf", trControl=fitControl) 

## Make Predctions 
# predict on test set 
preds <- predict(fit, newdata=ptest) 

# convert predictions to character vector 
preds <- as.character(preds) 

# create function to write predictions to files 
pml_write_files <- function(x) { 
 n <- length(x) 
 for(i in 1:n) { 
      filename <- paste0("problem_id_", i, ".txt") 
  write.table(x[i], file=filename, quote=F, row.names=F, col.names=F) 
 } 
} 

# create prediction files  
pml_write_files(preds) 
ptrain2 <- ptrain2[, -(1:5)] 
