#Loading used packages
library("dplyr")
library("data.table")
#Reading the files (the ziped folder should be in the working directory)
unzip("./getdata_projectfiles_UCI HAR Dataset.zip")
xtest<-fread("./UCI HAR Dataset/test/X_test.txt")
ytest<-fread("./UCI HAR Dataset/test/Y_test.txt")
test_subject<-fread("./UCI HAR Dataset/test/subject_test.txt")
xtrain<-fread("./UCI HAR Dataset/train/X_train.txt")
ytrain<-fread("./UCI HAR Dataset/train/Y_train.txt")
train_subject<-fread("./UCI HAR Dataset/train/subject_train.txt")
feat<-fread("./UCI HAR Dataset/features.txt")
#Merging X & Y
test<-cbind(test_subject, ytest, xtest)
train<-cbind(train_subject, ytrain, xtrain)
#naming columns
colnames(test)<-c("subject","activity", feat$V2)
colnames(train)<-c("subject","activity", feat$V2)
##removing dupicated coulmns names, which causes problem downstream
v<- make.names(names=names(test), unique=TRUE, allow_ = TRUE)
names(test)<-v
x<- make.names(names=names(train), unique=TRUE, allow_ = TRUE)
names(train)<-x
##adding new column to indicate the type of the data (training or test)
test2<-mutate(test, type="test")
train2<-mutate(train, type="train")
#Merging data (1)
merged<-rbind(test2, train2)
#extracting the mean and standard of deviation values (2)
selected<-select(merged, activity, type, subject, contains("mean"),contains("Mean"), contains("std"))
# Using descriptive activity names to name the activities in the data set (3)
selected$activity<-gsub(1, "WALKING", selected$activity)
selected$activity<-gsub(2, "WALKING_UPSTAIRS", selected$activity)
selected$activity<-gsub(3, "WALKING_DOWNSTAIRS", selected$activity)
selected$activity<-gsub(4, "SITTING", selected$activity)
selected$activity<-gsub(5, "STANDING", selected$activity)
selected$activity<-gsub(6, "LAYING", selected$activity)
#Appropriately labeling the data set with descriptive variable names (4)
names(selected)<-sub("...Z", "-Z-direction", names(selected))
names(selected)<-sub("...X", "-X-direction", names(selected))
names(selected)<-sub("...Y", "-Y-direction", names(selected))
names(selected)<-sub("fBodyBody", "fBody", names(selected))
names(selected)<-sub("tBodyAcc", "BodyAccelerationTime", names(selected))
names(selected)<-sub("tGravityAcc", "GravityAccelerationTime", names(selected))
names(selected)<-sub("tBodyGyro", "BodyGyroscopeTime", names(selected))
names(selected)<-sub("Mag", "Magnitude", names(selected))
names(selected)<-sub("fBodyAcc", "BodyAccelerationFrequency", names(selected))
names(selected)<-sub("fGravityAcc", "GravityAccelerationFrequency", names(selected))
names(selected)<-sub("fBodyGyro", "BodyGyroscopeFrequency", names(selected))
#creating data set with the average of each variable for each activity and each subject (5)
byActivity<-aggregate(selected[, 4:89], list(selected$activity), mean)
bySubject<-aggregate(selected[, 4:89], list(selected$subject), mean)
bySubject$Group.1<-paste("Subject",bySubject$Group.1, sep = " " ) #renaming the subjects to make it more readable when merged with activities
Summarized<-rbind(byActivity, bySubject)
names(Summarized)[1]<-"Activity/Subject"
write.table(Summarized, file="Getting and Cleaning Data Course Project.txt",row.name=FALSE)