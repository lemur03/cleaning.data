
## How the different functions are related to each others

### The different parts

This R script is divided in 4 part, each part could be in a different file but for the purpose of this exercise everything is contain inside the run_analysis.R script.
the different part are the following
 - Read files
 - Clean and Transform data
 - Merge Data
 - Generate result and final request
 
**Read files**

There is a main function to read file  ***fopen(path)*** that will return the content of a file. the others functions used to read files realize specific transformation:
 - *getfeaturesfile* : get the content from the file of features label
 - *getactivityfile* : get the content from the file of activities, based on the data-set type (Training or Test)
 - *getsubjectfile*  : get the content from the file of subject, based on the data-set type (Training or Test)
 - *getmeasurefile*  : get the content from the file of measurements, based on the data-set type (Training or Test)

**Clean and Transform data**

the functions contained in this part realize the cleaning of data (like: Extracts only the measurements on the mean and standard deviation for each measurement, Uses descriptive activity names to name the activities in the data set or Appropriately labels the data set with descriptive activity names).
the different functions are the following
 - *getactivities*: will return descriptive activity based on the data-set type (Training or Test)
 - *getsubjects*: will return the subjects and include a column row (Index),based on the data-set type (Training or Test)
 - *getCleanFeatureLabels*: will return appropriate labels for the features measurements
 - *getmeasures*:  will return a clean data-set of measure,based on the data-set type (Training or Test)

**Merge Data**

The objective of this part is to create an unique data-set for each data-set type (train or test) and provide another function to combine the two data-sets

**Generate result and final request**

this is the main part that will use the functions describe below to create a tidy data set with the average of each variable for each activity and each subject.

