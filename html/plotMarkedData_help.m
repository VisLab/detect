%% plotMarkedData
% Plots the marked data from markEvents
%
%% Syntax
%    [] = plotMarkedData(inputData, regions)
%    [] = plotMarkedData(inputData, regions, 'param1', value1, ...)
%
%% Description
%
% |[] = plotMarkedData(inputData, regions)| plots a GUI of the output of
% either |markEvents| or |plotLabeledData| using the data |inputData|. 
%
% |[] = plotMarkedData(inputData, regions, 'param1', value1, ...)|
% specifies additional parameters to be used.
% 
% The required input arguments are:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> inputData </tt></td>
% <td> Data of either a 3D matrix or an EEGLAB EEG structure 
%                     containing 3D (windowed/epoched) data. </td></tr>
% <tr>
% <td><tt> regions </tt></td>
% <td> Previous output of either <tt>markEvents</tt> or <tt>plotLabeledData</tt> </td></tr>
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
% <td> An array of structures with a <tt>.type</tt> and <tt>.latency</tt> field. Both fields
% are numeric. The field <tt>.latency</tt> is represented in frames.</td></tr>
% <tr>
% <td><tt> 'chanlocs' </tt></td>
% <td> An array of structures with a <tt>.labels</tt> field which is a string label
% denoting the channel name.  </td></tr>
% </table>
% </html>
%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio