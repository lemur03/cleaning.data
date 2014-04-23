
###########################
# Global variables
###########################
#path to the data folder
dataDir <- ".\\UCI HAR Dataset\\"
# Type of folders
folderType <-list("train"="train","test"="test")


############################################################################
#Code to read the csv files
############################################################################




#Read a csv file without header
fopen <- function(path,sep=" ")
{
  read.csv(paste0(dataDir,path), header=F, sep = sep)
}

# read the feature file
getfeaturesfile<- function()
{  
  labels<- fopen("features.txt")
  colnames(labels) <- c("id","feature")
  return(labels)
}

#get the activity file for a specific data type (train or test)
getactivityfile <- function(datatype)
{
  #check the param
  if(!datatype %in%  folderType)
  {
    stop("datatype can only be equal to : \"train\" or \"test\" ")
  }  
  fopen(paste(datatype,paste0("y_",datatype,".txt"),sep="\\"))  
}

#get the subject (1:30) file for a specific data type (train or test)
getsubjectfile <- function(datatype)
{
  #check the param
  if(!datatype %in%  folderType)
  {
    stop("datatype can only be equal to : \"train\" or \"test\" ")
  }   
  fopen(paste(datatype,paste0("subject_",datatype,".txt"),sep="\\"))  
}

#get the measures file for a specific data type (train or test)
getmeasurefile <- function(datatype)
{
  #check the param
  if(!datatype %in%  folderType)
  {
    stop("datatype can only be equal to : \"train\" or \"test\" ")
  }   
  fopen(paste(datatype,paste0("X_",datatype,".txt"),sep="\\"),sep="")  
}

############################################################
#Code to read realize the cleaning of the data
############################################################

#get the activities formatted
getactivities <- function(datatype)
{
  #datatype = "train"
  labels<- fopen("activity_labels.txt")  
  colnames(labels) <- c("id","variable")
  data <-getactivityfile(datatype)
  data <- cbind(data,1:dim(data)[1])
  colnames(data) <-c("id","row")
  res<-merge(data,labels,by.x="id",by.y="id",all =T)
  res[with(res,order(res[,"row"])),c("row","variable")]
}

#get the subject cleaned
getsubjects <- function(datatype)
{
  subjects <-getsubjectfile(datatype)
  subjects <- cbind(1:dim(subjects)[1],subjects)
  colnames(subjects) <- c("row","subjectId")
  return(subjects)
}

# Clean the features labels
getCleanFeatureLabels <- function()
{
  pattern <- "-mean[^Freq]|-std()"
  labels<-  getfeaturesfile()
  #clean the headers
  header <- grep(pattern,labels[["feature"]],value=T)
  header <- gsub("_","", header)
  header <- sub("^f","frequency-",header)
  header <- sub("^t","time-",header)
  header <- sub("\\(\\)","",header)
  header <- sub("Acc","-Accelerometer",header)
  header <- sub("Gyro","-Gyroscope",header)
  header <- sub("Mag","-Magnitude",header)
}

#get the measures cleaned
getmeasures <- function(datatype){
  pattern <- "-mean[^Freq]|-std()"  
  header <- getCleanFeatureLabels()    
  #clean features index 
  idx <- grep(pattern,getfeaturesfile()[["feature"]])
  data <-getmeasurefile(datatype)
  #subset of data on the columns that match the pattern
  data<- data[,idx]  
  #add the col names
  colnames(data) <- header  
  data<-cbind(1:dim(data)[1],data)
  colnames(data)[1] = "row"
  return(data)
}

####################################################################################
# this file create an unique dataset for each data type (train or test)
# and provide another function to combine the two dataset
####################################################################################

#Create an unique dataset that contain all the information for one data type (train or test)
getfulldataset <- function(datatype){
  act <- getactivities(datatype)
  subject <- getsubjects(datatype)
  #merge activity and subject using common column 'row'
  res<- merge(act,subject)  
  var <- getmeasures(datatype)
  #merge result with variables using common column 'row'
  merge(res,var)  
}

#Aggregate the two dataset (train and test)
aggregateDataset <- function()
{
  train <- getfulldataset(folderType[["train"]])  
  test  <- getfulldataset(folderType[["test"]])
  rbind(train,test)[,2:dim(test)[2]]
}

############################################################
# Final Results
############################################################

######################################################
# PART I : Merge the Train and Test datasets together
######################################################
datasetOne <- aggregateDataset()
head(datasetOne,n=2)
str(datasetOne)

#######################################################################
#PART II: average of each variable for each activity and each subject
# -----    mean by two factors   -----
#######################################################################

datasetTwo <- as.data.frame(datasetOne)
activities <- unique(datasetTwo$variable)
subjects<-unique(datasetTwo$subjectId)

#calculate the means for features by activity and subject
meanfactors <- function(activity,subject){
  x<-datasetTwo[datasetTwo$variable==activity & datasetTwo$subjectId==subject,]
  colMeans(x[,3:dim(x)[2]])  
}
#Create the header by activity and subject
concat_header<- function(activity,subject){
  paste(activity,paste0("Subject",subject),sep="-")
}

#Generate the final result test
datasetTwo <- mapply(meanfactors,activities,subjects)
colnames(datasetTwo)<-mapply(concat_header,activities,subjects)
datasetTwo