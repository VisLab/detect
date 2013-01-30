%% markEvents
% Marks data in EEG Dataset and returns structure of eventList
%
%% Syntax
%   labelSet = markEvents(inputData, categories)
%   labelSet = markEvents(inputData, categories, 'param1', value1, ...)
%% Description
% 
% |labelSet = markEvents(inputData, categories)| opens a GUI that
% can be used for manual labeling of inputData using the categories found
% in |categories|.
%
% |labelSet = markEvents(..., 'param1', value1, ...)| specifies additional
% parameters to be used. 
% 
% The required input arguments are:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> inputData </tt></td>
% <td> Either a 2D matrix of dimensions channels x frames or
%                   an EEGLAB EEG data file containing 2-D data. </td></tr>
% <tr>
% <td><tt> categories </tt></td>
% <td> Cell array of strings to label data with </td></tr>
% </table>
% </html>
%
% The optional inputs are passed as name-value pairs:
%
% <html>
% <table>
% <thead><tr><td><strong>Name</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> 'srate' </tt></td>
% <td>  Sampling rate of the data </td></tr>
% <tr>
% <td><tt> 'regions' </tt></td>
% <td> Previous output of markEvents </td></tr>
% <tr>
% <td><tt> 'chanlocs' </tt></td>
% <td>  An array of structures with a .labels field which is a string label
% denoting the channel name </td></tr>
% <tr>
% <td><tt> 'event' </tt></td>
% <td>  An array of structures with a <tt>.type<tt> and <tt>.latency<tt> field. Both fields
% are numeric. The field <tt>.latency<tt> is represented in frames. </td></tr>
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
% <td><tt> labelSet </tt></td>
% <td> A matrix of cells with entries: [category], [startTime], [endTime], 
% [badChnList]. Category is a string, startTime and endTime are numeric
% entries and badChnList is a numeric vector to denote bad channels. </td></tr>
% </table>
% </html>
%% Example
% Example 1 for marking EEG data with blinks, muscles and Other and saves it to
% the output variable regions with a sampling rate of 256Hz.
% 
%     load data/testing;
%     regions = markEvents(testing, {'Blink', 'Muscle', 'Other'}, 'srate', 256);
%
% A sample output is:
%
%   regions = 
% 
%     'Blink'     [1.4542]    [2.7005]    []
%     'Muscle'    [3.6723]    [4.5773]    []
% 
% Click on any of the toolbar buttons to label continuous data. After
% labeling some data, if you want to redo the markings:
%
%     new_regions = markEvents(testing, {'Blink', 'Muscle', 'Other'}, 'srate', 256, 'regions', regions);
%
%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio
