library(plyr)
library(dplyr)
### create a character vector containing the activity labels in words
activity_desc <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
## read in the activity labels in numbers
my_test_labels <- read.table("test/y_test.txt")
## convert from data frame to vector
my_test_labels <- my_test_labels$V1
## switch the activity labels from numbers to descriptive words
my_test_labels <- mapvalues(my_test_labels, 1:6, activity_desc)

## read in the activity labels in numbers for the training data
my_train_labels <- read.table("train/y_train.txt")

## convert from data frame to vector
my_train_labels <- my_train_labels$V1

## switch the activity labels from numbers to descriptive words
my_train_labels <- mapvalues(my_train_labels, 1:6, activity_desc)

## read in the test and training data sets
my_test_data <- read.table("test/X_test.txt")
my_train_data <- read.table("train/X_train.txt")
## read in the names of the features
my_column_names <- read.table("features.txt", stringsAsFactors = FALSE)

## since some of the feature names are not unique, we will append the feature number
my_column_names <- mutate(my_column_names, joined = paste(V1, V2, sep="_" ))
my_column_names <- my_column_names$joined

## apply the feature names as the column names of both data sets
names(my_test_data) <- my_column_names
names(my_train_data) <- my_column_names

## read in the subjects data and convert to vector for both data sets
my_test_subjects <- read.table("test/subject_test.txt")
my_test_subjects <- my_test_subjects$V1
my_train_subjects <- read.table("train/subject_train.txt")
my_train_subjects <- my_train_subjects$V1

## add the subject ids and the activity labels as new columns to both data sets
my_train_data <- cbind(my_train_subjects, my_train_labels, my_train_data)
my_test_data <- cbind(my_test_subjects, my_test_labels, my_test_data)

## convert the data frames to dplyr tables 
my_train_data_tbl <- tbl_df(my_train_data)
my_test_data_tbl <- tbl_df(my_test_data)

## rename the subject_id and the activity columns to more descriptive nameas
my_train_data_tbl <- dplyr::rename(my_train_data_tbl, subject_id = my_train_subjects, activity = my_train_labels )
my_test_data_tbl <- dplyr::rename(my_test_data_tbl, subject_id = my_test_subjects, activity = my_test_labels )

## combine both data sets into one common data set
joined_data  <- full_join(my_train_data_tbl, my_test_data_tbl)

## remove any column where the variable name does not contain mean() or std().
## obviously excludes subject_id and activity 
joined_data <- select(joined_data, matches(".*mean\\().*|.*std\\().*|subject_id|activity"))

## group the data so that we can create the new tidy data set from it
joined_data <- group_by(joined_data, subject_id, activity)

## create new tidy data set with the average of each column grouped by subject and activity
summary_data <- dplyr::summarize_each(joined_data, funs(mean))
