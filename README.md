


# Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.  
2. Extracts only the measurements on the mean and standard deviation for each measurement.  
3. Uses descriptive activity names to name the activities in the data set  
4. Appropriately labels the data set with descriptive variable names.  
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.  
Good luck!


## Steps 

######  **Load data.table Library**
```{r}
library(data.table)
```

###### **Dowload Files if folder doese not exist**
```{r}
url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!dir.exists('./UCI HAR Dataset')){
   download.file(url,'./UCI HAR Dataset.zip', mode = 'wb')
   unzip("UCI HAR Dataset.zip", exdir = getwd())
}
```

###### **Reading Featues Data**
```{r}
tmp = read.csv("UCI HAR Dataset\\features.txt",sep = " ",header = FALSE)
FeaturesName = as.character(tmp[,2])
```

###### **Reading Training Data**
```{r}

Subject_train = fread("UCI HAR Dataset\\train\\subject_train.txt", col.names = "S", sep = " " )
X_train = fread("UCI HAR Dataset\\train\\X_train.txt", col.names = FeaturesName, sep = " " )
y_train = fread("UCI HAR Dataset\\train\\y_train.txt",col.names = "Y" )
```
###### **Reading Test Data**
```{r}
Subject_test = fread("UCI HAR Dataset\\test\\subject_test.txt", col.names = "S", sep = " " )
X_test = fread("UCI HAR Dataset\\test\\X_test.txt", col.names = FeaturesName )
y_test = fread("UCI HAR Dataset\\test\\y_test.txt" ,col.names = "Y")
```
###### **Join Tarin Data in Data Frame**
```{r}
data_train = data.frame(Subject_train,y_train,X_train)
```
###### **Join Test Data in Data Frame**
```{r}
data_test = data.frame(Subject_test,y_test,X_test)
```
## Solutions
##### 1. Merges the training and the test sets to create one data set.
```{r}
data = rbind(data_train,data_test)
```

##### 2. Extracts only the measurements on the mean and standard deviation for each measurement.
```{r}
mean <- grep("mean", FeaturesName)
std <- grep("std", FeaturesName)
columns = sort( c(mean , std ))
FeaturesName = c("S","Y",FeaturesName[columns])
mean_std <- data[,c(1,2,columns+2)]
```

##### 3. Uses descriptive activity names to name the activities in the data set
```{r}
activity_labels =  fread("UCI HAR Dataset\\activity_labels.txt",col.names = c("id","Name" ))
mean_std$Y <- activity_labels[mean_std$Y,]$Name
```
##### 4. Appropriately labels the data set with descriptive variable names.
```{r}
New_name =FeaturesName
New_name = gsub("-","_",New_name )
New_name = gsub("^t", "TimeDomain_",New_name )
New_name = gsub("^f", "FrequencyDomain_",New_name )
New_name = gsub("Gyro", "Gyroscope",New_name )
New_name = gsub("Mag", "Magnitude",New_name )
New_name = gsub("Acc", "Accelerometer",New_name )
New_name = gsub("[(][)]", "",New_name )

names(mean_std) = New_name
```

##### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```{r}
tidy = data.frame()
activties = unique( mean_std$Y)
subjectes = sort (unique(mean_std$S))
for(activity in activties)
  for(subject in subjectes)
  {
    temp = sapply (mean_std[mean_std$Y == activity & mean_std$S == subject,c(3:81)],mean)
    tidy = rbind(tidy ,data.frame(S = subject,Y = activity,as.list(temp)))
  }
write.csv(tidy,"tidy.csv",row.names = FALSE)
```