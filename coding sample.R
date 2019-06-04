library(e1071); library(dummies); library(caroline); library(MTS); library(mvtnorm); library(caret); library(tseries); library(elasticnet);


##  Setting up Data for analysis

traindat=read.csv("train.csv",header=T)   #read training dataset
traindat$Market=as.factor(traindat$Market)   #change market variable to categorical variable
#traindat$Stock=as.factor(traindat$Stock)
#traindat$Day=as.factor(traindat$Day)          # Exclude


testdat=read.csv("test.csv" , header=T)   #read testing dataset to predict values
test=testdat[,-c(1,2,3)]      #  new working testing data frame removing index, market, day vars

train=traindat[,-c(1,2,3)]    #  new working training data frame removing index, market,
mis =matrix( c(1917,rep(0,13)) , nrow=1)    # inserting stock identification number
mis = as.data.frame(mis); names(mis) = names(train); #mis$Stock = as.factor(mis$Stock);
train = rbind(mis, train)

train.gr=groupBy(train , train$Stock , aggregation = NULL)   # deconstruct the working training set into a list of datasets grouped by their respective stock IDs
test.gr=groupBy(test , test$Stock , aggregation = NULL)      # same as above for working test set


# fill in missing infromation with variables mean from the stocks subgroup
for(i in 1:nrow(train)){
  for(j in 1:ncol(train)){
    if( is.na(train[i,j]) == T ) train[i,j] = mean( train.gr[[train[i,1] +1 ]][,j] , na.rm=T)
  }
}


# fill in missing infromation with variables mean from the stocks subgroup
for(i in 1:nrow(test)){
  for(j in 1:ncol(test)){
    if( is.na(test[i,j]) == T ) test[i,j] = mean( test.gr[[test[i,1] +1 ]][,j] , na.rm=T)
  }
}

# create a vector containing the sample size of the training "sub" datasets grouped by stock IDs
n=matrix(nrow=length(train.gr))
for(i in 1:length(train.gr) ){
  n[i] = nrow( train.gr[[i]] )
}









##  Run 10 fold cross validation to compare  models 
# Models are compared by smallest average weighted MSE


err0 = err1 = err2 = matrix(nrow = 3022 , ncol = 10)  #preallocate to save error for each model and fold

# Loop for each stock ID data set
for(i in 1:3021){
  
  #Stratody sample each subset of data to create the folds
  k.folds = createFolds( 1:n[i] , 10 )
  y=train.gr[[i]]$y
  x=train.gr[[i]][,-c(1,17,18)]
  weights = train.gr[[i]]$Weight
  e = matrix( nrow = n[i] )
  
  
  # Run 10-fold CV
  for(k in 1:10){     
    
    x.train = x[ -k.folds[[k]] ,]
    y.train = y[ -k.folds[[k]] ]
    x.test = x[ k.folds[[k]] ,]
    y.test = y[ k.folds[[k]] ]
    w.train = weights[ -k.folds[[k]] ]
    w.test  = weights[ k.folds[[k]] ]
    
    svm.mod0 = svm(x.train , y.train , scale = T , type = "eps" , kernel = "radial" , cost = 5 )    # SVM with radial kernel and C = 5
    svm.mod1 = svm(x.train , y.train , scale = T , type = "eps" , kernel = "radial" , cost = 10 )    # SVM with radial kernel and C = 10
    svm.mod2 = svm(x.train , y.train , scale = T , type = "eps" , kernel = "radial" , cost = 1 )    # SVM with radial kernel and C = 1
    
    err0[i,k] = sum( w.test*( y.test - predict(svm.mod0 , x.test) )^2 )
    err1[i,k] = sum( w.test*( y.test - predict(svm.mod1 , x.test) )^2 )
    err2[i,k] = sum( w.test*( y.test - predict(svm.mod2 , x.test) )^2 )
    
    
  }
}



####   train model chosen from previous section on entire dataset


error = matrix(nrow = 3022)
fit.models = list()  #Preallocate list to save trained models

# Trained SVM model on datasets with sample size >12
# For sample size <12, kept simple and used data's mean as model

cutoff = 12

for(i in 1:length(train.gr)){
  
  x=train.gr[[i]][,-c(1,13,14)]
  y=train.gr[[i]]$y
  weights = train.gr[[i]]$Weight
  
  if( n[i] > cutoff ){
    
    svm.fit = svm( x = x , y = y , scale = T , type = "eps" , kernel = "radial" , cost = 2 , gamma = 0.15 )
    fit.models[[i]] = svm.fit
    
    yhat = predict(svm.fit , x)
    error[i] = sum(weights * ( yhat - y )^2 )
    
  } else{
    
    fit.models[i] = yhat = mean(y)
    error[i] = sum(weights * ( yhat - y )^2 )
    
  }
  
}

total.error = sum(error)
print(total.error)





###  Predict the values for the testing set using the trained model from previous section 


y.pred = matrix(nrow = nrow(test) )  # To save predicted values

#Loop looks at sock ID numbers then searches list of saved models, chooses corresponding to predict value

for(i in 1:nrow(test)){
  
  ind = test[i,1] + 1
  
  if( n[ind] > cutoff ){
    
    y.pred[i] = predict( fit.models[[ ind ]] , test[i,-1] )
    
  } else{
    
    y.pred[i] = fit.models[[ ind ]]
    
  }
  
}


y.out = as.data.frame(cbind(testdat$Index , y.pred))  # Save y values with index number to prepare for submission
names(y.out) = c("Index" , "y")
write.table(y.out , file = "y predictions2.csv" , col.names = T , sep = ",")  # create CSV file with y values and index










