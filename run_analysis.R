library(plyr)
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataUrl, "finaldata.zip", method="curl")
if(!file.exists("./UCI HAR Dataset")) {
    unzip("finaldata.zip")
}
#Read and merge feature files
xTrain    <- read.table("./UCI HAR Dataset/train/X_train.txt")
xTest     <- read.table("./UCI HAR Dataset/test/X_test.txt")
xFeaturesData <- rbind(xTrain, xTest)
#Read and merge activity files
yTrain    <- read.table("./UCI HAR Dataset/train/Y_train.txt")
yTest     <- read.table("./UCI HAR Dataset/test/Y_test.txt")
yActivityData <- rbind(yTrain, yTest)
#Read and merge subject files
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjectTest  <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subjectData <- rbind(subjectTrain, subjectTest)
#Read labels and features
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
featuresNames  <- read.table("./UCI HAR Dataset/features.txt")
#New names
names(subjectData)   <- "subject"
names(yActivityData) <- "activity"
names(xFeaturesData) <- featuresNames$V2
#Complete merge
mergeData <- cbind(xFeaturesData, yActivityData, subjectData)
#Subset mean and std
keyFeatures <- featuresNames$V2[grep("mean\\(\\)|std\\(\\)", featuresNames$V2)]
selectedColumns <- c(as.character(keyFeatures), "subject", "activity" )
mergeData <- subset(mergeData, select=selectedColumns)
mergeData$activity <- activityLabels[mergeData$activity, 2]
#Rename variables
names(mergeData) <-gsub("^t", "time", names(mergeData))
names(mergeData) <-gsub("^f", "frequency", names(mergeData))
names(mergeData) <-gsub("Acc", "Accelerometer", names(mergeData))
names(mergeData) <-gsub("Gyro", "Gyroscope", names(mergeData))
names(mergeData) <-gsub("Mag", "Magnitude", names(mergeData))
names(mergeData) <-gsub("BodyBody", "Body", names(mergeData))
#Create an independent tidy data set
newData <- ddply(mergeData, .(subject, activity), function(x) colMeans(x[, 1:66]))
write.table(newData, "tidy.txt", row.name=FALSE)