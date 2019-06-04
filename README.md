# G-Research Forecasting Challenge

The goal of the challenge was to attempt to predict the values of stocks in a testing set given a training set to build a model. 

The competition was hosted by G-Research, a quantitative research and tech company. A description of the competition can be found via the link:
*https://financialforecasting.gresearch.co.uk/*

Data can be found via the G-Research link above. (Tried to upload in compressed folder but the file was still too large).

Code can be found in the file: **_coding sample.R_**

Since financial data tends to be nonlinear, I decided to model the data using a Support Vector Regression model. SVR performs relatively well on nonlinear data at the cost of increased computational time. Furthermore, after investingating the training and testing sets, I discovered they all came from the same source; the testing set seemed to be data points taken out of a larger set with the stock values stripped out and the training set composed of the remaining data points with the values. In other words, the training set contained missing time points for each stock and those missing points were used as the testing set. Thus a SVR model seemed to make an appropriate model. 
It was not until after the competition that I saw how much better boosting alogrithims performed over other models. 

Due to entering the competition late, I did not have a chance to experiment with the data by fitting different models, investigating the data, performing some form of varaible reduction, and properly tuning the models. What I did attempt was using fitting an individual model for each stock instead of the data as a whole. I split the data per stock type using a list and fit a SVR model for each stock having sufficient data points; if the stock had a certain number of data points under a cutoff, I used the mean of the stock to reduce computational time and the overall complexity of the script. 

To fine tune the models, I performed 10 fold cross validation, picking points randomly without replacement for each subgroup obviously, to choose the model with the smallest average mean squared error and fine tune the parameters of the model. Similarly, I split the test set by stocks and used the corresponding model to predict a point's stock value. Finally, I saved my values into a csv file.
The entire process of training the model and predicing the values took over an hour per run, limiting my ability to fine tune the model. 

Some things I didn't take into account or have a chance to include:
 - Only used the Gaussian Radial Basis function as the kernel for the SVR. Did not have the opportunity to try other kernel functions. 
 - find the optimal parameters for the GRB kerenl to the best of my abilities. 
 - perform some form of dimension reduction using PCA or other method to reduce computational cost
 - fit a model to the entire data set and hot one encoded the stock instead of separating by stock. 
 - optimize my code
 - investigate the correlation between certain variables
 - feature engineer
 - try other types of models


The competition did open my eyes to the importance of cleaning the data/engineering features and the superior prediction power of boosting algorithms. # GResearch-Forecasting-Challenge
