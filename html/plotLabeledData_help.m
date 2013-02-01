%% plotLabeledData 
% plots the labeled data from labelData
%
%% Syntax
%   labelSet = plotLabeledData(inputData, model, results)
%   labelSet = plotLabeledData(inputData, model, results, 'param1', value1, ...)
%
%% Description
%
% |labelSet = plotLabeledData(inputData, model, results)|
% displays a data scroll plot window with the event information taken
% from |labelData|. 
%
% |labelSet = plotLabeledData(..., 'param1', value1, ...)| specifies 
% additional parameters to be used. 
%
% The required input arguments are are:
%
% <html>
% <table>
% <thead><tr><td><strong>Arguments</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> inputData </tt></td>
% <td> An EEGLAB EEG structure containing continuous 2D EEG data
%                  or a 2D matrix array of size (channels x frames) </td></tr>
% <tr>
% <td><tt> model </tt></td>
% <td> The SVM model output from <tt>getModel</tt>. </td></tr>
% <tr>
% <td><tt> results </tt></td>
% <td>  The output from <tt>labelData</tt> </td></tr>
% </table>
% </html>
%
% The optional inputs are passed in as name-value pairs:
%
% <html>
% <table>
% <thead><tr><td><strong>Name</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> 'srate' </tt></td>
% <td> Sampling rate of the data </td></tr>
% <tr>
% <td><tt> 'includeClasses' </tt></td>
% <td> Cell array of strings denoting the desired plotting
%                     categories or labels (all by default) </td></tr>
% <tr>
% <td><tt> 'eventList' </tt></td>
% <td> An array of structures with a .type and .latency field. Both fields
% are numeric. The field .latency is represented in frames.</td></tr>
% <tr>
% <td><tt> 'chanlocs' </tt></td>
% <td> An array of structures with a <tt>.labels</tt> field which is a string label
% denoting the channel name.  </td></tr>
% </table>
% </html>
%
% The output argument is:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> labelSet </tt></td>
% <td> A cell array with columns [eventtype], [startTime] and [endTime] </td></tr>
% </table>
% </html>
%
%% Example
% Build the artifact classification model from the sample data
% included in the toolbox, and display only eye blinks and jaw clenches:

   load training;
   load labels;
   model = getModel(training, labels, 1 : 64);
   load testing;
   results = labelData(testing, model, 256, .125);
   labelSet = plotLabeledData(testing, model, results, 'srate', 256, 'includeClasses', {'Eye Blink', 'Jaw Clench'})

%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio