%% CompareLabels
% Compares two sets of labeled data
%
%% Syntax
%  results = compareLabels(EEG, labeledSet1, labeledSet2, timingError, srate)
%  [results errorInfo] = compareLabels(EEG, labeledSet1, labeledSet2, timingError, srate)
%  [results errorInfo timeInfo] = compareLabels(EEG, labeledSet1, labeledSet2, timingError, srate)
%
%% Description
% |results = compareLabeledData(EEG, labeledSet1, labeledSet2,
% timingError, srate)| returns an event structure containing the decision
% types, together with a start and end time, in seconds. The decision
% types can take one of five values:
%
% <html>
% <table>
% <thead><tr><td><strong>Type name</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> Agreement </tt></td>
% <td> The labels of the two label sets are
%                        the same and in type agreement </td></tr>
% <tr>
% <td><tt> TypeError </tt></td>
% <td> The labels from the two label sets are the
%                        same in time but not in type agreement</td></tr>
% <tr>
% <td><tt> FalsePositive </tt></td>
% <td>   A label in label set 2 was not found in
%                        label set 1 at that time</td></tr>
% <tr>
% <td><tt> FalseNegative </tt></td>
% <td>   A label in label set 1 was not found in
%                        label set 2 at that time</td></tr>
% <tr>
% <td><tt> NullAgreement </tt></td>
% <td>   Neither label set was labeled that time</td></tr>
% </table>
% </html> 
%
% |[results, errorInfo] = compareLabeledData(EEG, labeledSet1, labeledSet2,
% timingError, srate)| returns an additional structure |errorInfo| which
% contains information about decisions with |typeError,
% falsePositive| and |falseNegative|.
%
% |[results, errorInfo, timeInfo] = compareLabeledData(EEG, labeledSet1, labeledSet2,
% timingError, srate)| returns a summary of the time, in seconds, in each
% of the five states described above. 
%
% The input arguments are:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> inputData </tt></td>
% <td> Either a 2-D matrix input or an EEGLAB EEG structure
%                  containing 2-D data. Dimensions are (channels x frames) </td></tr>
% <tr>
% <td><tt> labeledSet1</tt></td>
% <td> The output of either <tt>markEvents</tt> or <tt>plotLabeledData</tt> 
% (treated as ground truth)</td></tr>
% <tr>
% <tr>
% <td><tt>labeledSet2 </tt></td>
% <td> The output of either <tt>markEvents</tt> or <tt>plotLabeledData</tt> </td></tr>
% <tr>
% <td><tt> timingError </tt></td>
% <td>   Allowable timing error to still consider two regions as
%                  the same (in seconds) (See examples below for
%                  further details)</td></tr>
% <tr>
% <td><tt> srate </tt></td>
% <td>   Sampling rate of data in Hz</td></tr>
% </table>
% </html> 
%
% The outputs are
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> results </tt></td>
% <td> Cell array with three columns: [agreement type], startTime], [endTime] </td></tr>
% <tr>
% <td><tt> errorInfo </tt></td>
% <td> For events with 'TypeError', 'FalsePositive' or
%                   'FalseNegative', will give the following output: 
%                   [type1], [type2], [startTime], [endTime] (see examples
%                   below)</td></tr>
% <tr>
% <td><tt> timeInfo </tt></td>
% <td>   A structure with output fields <tt>.agreement</tt>, <tt>.typeError</tt>,
% <tt>.falsePositive</tt>, <tt>.falseNegative</tt>, <tt>.totalTime</tt>. Each field represents the
% total time, in seconds, of each state.
% <tr>
% </table>
% </html> 
%

%% Example
% Compare the labelings using two different channel sets to
% train an artifact discrimination model:

     training = pop_loadset('data/training.set');
     load('data/labels.mat');
     
     % build model using all 64 EEG Channels
     model1 = getModel(training, labels, 1:64);
     
     % now build model using only 32 EEG channels
     model2 = getModel(training, labels, 1:32);
     
     % now load testing dataset
     testing = pop_loadset('data/testing.set');

     % Use sliding window of .125s for data sampled at 256hz
     results1 = labelData(testing, model1, 256, .125);
     results2 = labelData(testing, model2, 256, .125);

     % apply a certainty policy to remove false positives

     results1 = thresholdPolicy(results1, 'None', .5);
     results2 = thresholdPolicy(results2, 'None', .5);

     % plot the data and get an event list ignoring the category 'None'

     classes = {'Eye Blink', 'Eye Left Movement', 'Eye Up Movement', 'Eyebrow Movement', 'Jaw Clench', 'Jaw Movement'};
     labelSet1 = plotLabeledData(testing, model1, results1, 'srate', 256, 'includeClasses', classes);
     labelSet2 = plotLabeledData(testing, model2, results2, 'srate', 256, 'includeClasses', classes);

     % compare the labelings, allowing for up to .100s timing error, for
     % data sampled at 256hz. 

     [results, errorInfo, timeInfo] = compareLabels(testing, labelSet1,...
     labelSet2, .1, 256)
%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio
