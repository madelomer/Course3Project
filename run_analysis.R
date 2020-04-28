
url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!dir.exists('./UCI HAR Dataset')){
   download.file(url,'./UCI HAR Dataset.zip', mode = 'wb')
   unzip("UCI HAR Dataset.zip", exdir = getwd())
}


# Reading Featues 
tmp = read.csv("UCI HAR Dataset\\features.txt",sep = " ",header = FALSE)
FeaturesName = as.character(tmp[,2])

Subject_train = fread("UCI HAR Dataset\\train\\subject_train.txt", col.names = "S", sep = " " )
X_train = fread("UCI HAR Dataset\\train\\X_train.txt", col.names = FeaturesName, sep = " " )
y_train = fread("UCI HAR Dataset\\train\\y_train.txt",col.names = "Y" )
Subject_test = fread("UCI HAR Dataset\\test\\subject_test.txt", col.names = "S", sep = " " )
X_test = fread("UCI HAR Dataset\\test\\X_test.txt", col.names = FeaturesName )
y_test = fread("UCI HAR Dataset\\test\\y_test.txt" ,col.names = "Y")

data_train = data.frame(Subject_train,y_train,X_train)
data_test = data.frame(Subject_test,y_test,X_test)

################################################
data = rbind(data_train,data_test)

################################################
mean <- grep("mean", FeaturesName)
std <- grep("std", FeaturesName)
columns = sort( c(mean , std ))
FeaturesName = c("S","Y",FeaturesName[columns])
mean_std <- data[,c(1,2,columns+2)]

################################################

activity_labels =  fread("UCI HAR Dataset\\activity_labels.txt",col.names = c("id","Name" ))
mean_std$Y <- activity_labels[mean_std$Y,]$Name
################################################

New_name =FeaturesName
New_name = gsub("-","_",New_name )
New_name = gsub("^t", "TimeDomain_",New_name )
New_name = gsub("^f", "FrequencyDomain_",New_name )
New_name = gsub("Gyro", "Gyroscope",New_name )
New_name = gsub("Mag", "Magnitude",New_name )
New_name = gsub("Acc", "Accelerometer",New_name )
New_name = gsub("[(][)]", "",New_name )

names(mean_std) = New_name
################################################
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