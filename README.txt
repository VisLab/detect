DETECT is a MATLAB toolbox for detecting and labeling events in 
epoched and continuous time series. To use DETECT, you must have 
examples of labeled data to create a classifier or model. Once you have 
created a model, you can apply it to label either epoched or continuous data. 
DETECT provides some utility functions specifically for manually labeling 
EEG data in an efficient way. This process is useful for producing 
labeled data to train a model for artifacts and other features. 

DETECT uses autoregressive features by default, but you are free to 
provide your own feature functions.  The toolbox includes several 
functions for building models of events as well as sample datasets 
for detecting artifact segments in EEG data. 


Requirements:
DETECT requires the following
-	MATLAB™ version R2011A or higher. Other versions of MATLAB™ may work; 
    version R2011A and later are officially supported 
-	EEGLAB version 10 or higher, if you wish to use the DETECT plotting functions.

Installation:

1.	Download the toolbox and extract the .zip file. 
2.	Add the extracted folder to the MATLAB Path (File ? Set Path). 
    Use the “Add with Subfolders” option.
3.	Add EEGLAB and its subfolders to the  MATLAB Path if you wish to 
    use the DETECT plotting functions.

Installation notes:

1.	There are two versions of the toolbox available for download, 
    depending on your installation. Currently we have versions for 64-bit 
    Windows Vista/7 and 64-bit Linux platforms. You will need to compile 
    LibSVM for any other installation. To recompile the toolbox, navigate 
    to LIBSVM_DETECT/matlab and run the make.m file.
2.	If you plan to use DETECT frequently, you may want to put commands 
    to automatically add the DETECT folder and its subdirectories in 
    your startup.m file located in your MATLAB startup folder.
