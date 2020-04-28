---
title: "CodeBook.md"
output: html_document
---
# Data Description



Human Activity Recognition Using Smartphones Dataset
Version 1.0

Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Università degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws


The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:


- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:


- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

Notes: 

- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

For more information about this dataset contact: activityrecognition@smartlab.ws

License:

Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.



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
write.csv(tidy,"tidy.txt",row.names = FALSE)
```
