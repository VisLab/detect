% DETECT Toolbox 
% Version RC5 2-December-2012
%
% Requires EEGLAB if plotting functions are used
%
% General functions
%   getARfeatures   - estimate autoregressive coefficients (get feature vectors)
%   getModel	    - create a model or classifier based on labeled training data 
%   labelData	    - label data in sliding time windows, reporting certainty of each label
%   labelWindows	- label windowed data based on a classifier
%   compareLabels	- compare two sets of labeled data
%
% EEG related functions (depend on EEGLAB)
%   getLabels       - extract data from continuous dataset for model training
%   plotLabeledData - plots the results from labelData
%   plotMarkedData  - plots the manually marked data from markEvents.
%   plotWindowData  - plots the results from labelData when testing on windowed data
%   markEvents      - GUI for manual labeling of events in data
%
% Certainty threshold policies
%   thresholdPolicy 
%   unknownPolicy
%
% Vernon Lawhern, Kay A. Robbins
% Copyright 2011-2013 The University of Texas at San Antonio