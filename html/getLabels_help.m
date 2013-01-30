%% getLabels 
% creates a windowed dataset from highlighted data segments
%
%% Syntax
%   [dataWindows, labels] = getLabels(inputData, categories, windowLength)
%   [dataWindows, labels] = getLabels(inputData, categories, windowLength, 'param1', value1, ...)
%% Description
%
% |[dataWindows, labels] = getLabels(inputData, categories, windowLength)| 
% opens a GUI that allows the user to select regions of the dataset with 
% the events found in |categories|, and returns a windowed (epoched) 
% dataset and a labels vector that can be used with getModel to train a 
% classification model.
%
% |[dataWindows, labels] = getLabels(..., 'param1', value1,...)| specifies
% additional parameters to be used. 
%
% The required input arguments are:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> inputData </tt></td>
% <td> An EEGLAB EEG structure containing continuous 2D EEG data
%                  or a 2D matrix array of size (channels x frames) </td></tr>
% <tr>
% <td><tt> categories </tt></td>
% <td> A cell array of strings specifying the categories used 
%                  to tag the data. Each category value will have its
%                  own button on the toolbar for easy highlighting of 
%                  events. </td></tr>
% <tr>
% <td><tt> windowLength </tt></td>
% <td>  The length of a window in seconds for training
%                  (see notes). </td></tr>
% </table>
% </html>
%
% The optional inputs are passed in as name-value pairs:
%
% <html>
% <table>
% <thead><tr><td><strong>Name</strong></td>
% <td><strong>Description<strong></td></tr>
% <td><tt> 'srate' </tt></td>
% <td> Sampling rate of the data. </td></tr>
% <tr>
% <td><tt> 'events' </tt></td>
% <td> An array of structures with a .type and .latency field. Both fields
% are numeric. The field .latency is represented in frames.  </td></tr>
% <tr>
% <td><tt> 'chanlocs' </tt></td>
% <td> An array of structures with a .labels field which is a string label
% denoting the channel name </td></tr>
% <tr>
% <td><tt> 'colors' </tt></td>
% <td> A color matrix of size (categories x 3) used to set the category 
% buttons to specific colors. </td></tr>
% </table>
% </html>
%
% The output arguments are:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> dataWindows </tt></td>
% <td> Either an EEG structure with windowed data, or a 3D
%                  matrix. If the original input data was an EEG structure,
%                  the output will be an EEG structure. If the input data
%                  is a 2D matrix, a 3D matrix of size (channels x
%                  windowSize x windows) is returned. 
%                  The length of a window is windowLength * srate. </td></tr>
% <tr>
% <td><tt> labels </tt></td>
% <td> A cell array of strings containing the label identifier
%                  for each trial. </td></tr>
% </table>
% </html>
%
%
%% Notes
%
% While |getLabels| allows you to highlight regions of any size,
% it will re-align the highlighted sections so that they are exactly the
% size of windowLength from the user input. The features that we are
% extracting all assume that the length of data is the same for every
% condition.
%
% The EEGLAB EEG structure may be passed as |inputData|.
%
%% Example
%
% Extract 1/2 second training epochs labeled 'None' and 'Blink'
% using an EEGLAB EEG dataset. 
%    
%   EEG = pop_loadset('data/testing.set');
%   [dataWindows, labels] = getLabels(EEG, {'None', 'Blink'}, 0.5, 'srate', 256)
%
% This example works the same with a 2-D matrix as input:
%
%   EEG = load('data/testing.mat');
%   [dataWindows, labels] = getLabels(testing, {'None', 'Blink'}, .5, 'srate',  256)
%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio