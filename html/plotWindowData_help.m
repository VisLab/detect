%% plotWindowData  
% plots the decoded windows from labelWindows
%
%% Syntax
%   events = plotWindowData(inputData, model, results)
%   events = plotWindowData(inputData, model, results, 'param1', value1, ...)
%
%% Description
%
% |events = plotWindowData(inputData, model, results)| plots the decoded
% windows (epochs) obtained from |labelWindows| in a scroll plot GUI. The
% inputs |model| and |results| come from |getModel| and |labelWindows|,
% respectively.
%
% |events = plotWindowData(inputData, model, results, 'param1', value1,
% ...)| specifies additional parameters to be used. 
%
% The required input arguments are:
%
% <html>
% <table>
% <thead><tr><td><strong>Arguments</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> inputData </tt></td>
% <td> Data of either a 3D matrix or an EEGLAB EEG structure 
%                     containing 3D (windowed/epoched) data. </td></tr>
% <tr>
% <td><tt> model </tt></td>
% <td>  The SVM model output from getModel. </td></tr>
% <tr>
% <td><tt> results </tt></td>
% <td>  The output from labelWindows </td></tr>
% </table>
% </html>
%
% The optional input arguments are passed as name-value pairs:
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
% <td> An array of structures with a <tt>.type</tt> and <tt>.latency</tt> field. Both fields
% are numeric. The field <tt>.latency</tt> is represented in frames.</td></tr>
% <tr>
% <td><tt> 'chanlocs' </tt></td>
% <td> An array of structures with a <tt>.labels</tt> field which is a string label
% denoting the channel name.  </td></tr>
% <tr>
% <td><tt> 'colors' </tt></td>
% <td> Optional; a nEvents x 3 array of custom-defined colors </td></tr>
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
% <td><tt> events </tt></td>
% <td> a nWindows x 2 cell array with columns [eventtype] and [certainty] </td></tr>
% </table>
% </html>

%% Example
% Build a training model on epoched data and test the model on
% the same epoched data. Plot only epochs containing eye blinks and jaw
% clenches. 

   load training.mat;
   load labels.mat;
   model = getModel(training, labels, 1 : 64);
   results = labelWindows(training, model, labels);
   events = plotWindowData(training, model, results, 'srate', 256, 'includeClasses', {'Eye Blink', 'Jaw Clench'})

%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio