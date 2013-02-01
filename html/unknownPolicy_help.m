%% unknownPolicy
% Relabel uncertain non-baseline events as "Unknown" 
%
%% Syntax
%    results = unknownPolicy(results, baseline_class, certainty_threshold)
%    [results accuracy] = unknownPolicy(results, baseline_class, certainty_threshold)
%
%% Description
% |results = unknownPolicy(results, baseline_class, certainty_threshold)|
% applies a filter to event labels based on the certainty. after classification to
% relabel events based on the certainty. In particular, |unknownPolicy| relabels
% an event as |"Unknown"| if the certainty of its most likely event
% is below the |certainty_threshold| and neither of the top two most
% likely event labels is the |baseline_class|. The output |results|
% structure is the same as the input |results| structure except that its
% label fields are adjusted to reflect the certainty policy.
%
% |[results accuracy] = unknownPolicy(results, baseline_class,
% certainty_threshold)| recalculates the classification accuracy if the
% input was from |labelWindows|. 
%
%% Example
% Create a model from the training data and relabel uncertain events
   load('training.mat');
   load('labels.mat');
   load('testing.mat');
   model = getModel(training, labels);
   results = labelData(testing, model, 256, 0.25);
   results = unknownPolicy(results, 'None', 0.5);

%% Notes
% The output is an array of structures the following fields:
%
% <html>
% <table>
% <thead><tr><td><strong>Field</strong></td>
% <td><strong>Description<strong></td>
% <td><strong>Sample value</strong></td></tr>
% <tr>
% <td><tt>.label</tt></td>
% <td>Predicted label, given as a cell array of strings</td>
% <td><tt>'None'</tt></td></tr>
% <tr>
% <td><tt>.time</tt></td>
% <td>Time in seconds of the predicted label
%     given as [start end] in seconds </td>
% <td><tt>[10.6836 10.8047]</tt></td></tr>
% <tr>
% <td><tt>.certainty</tt></td>
% <td>Measure indicating likelihood that prediction is correct</td>
% <td><tt>0.925</tt></td></tr>
% <tr>
% <td><tt>.likelihoods  </tt></td>
% <td>Cell array of labels ordered from most likely to
%                  least likely for that event</td>
% <td><tt>{7x1 cell}</tt></td></tr>
% </table>
% </html>
%
% The |unknownPolicy| compares the value of the |results.certainty| 
% entry with the |certainty_threshold|. If this value is below the 
% threshold and one of the top two most likely labels (found in the first
% two entries of |results.likelihoods|) is the |baseline_class|, 
% then |unknownPolicy| changes the label to be |baseline_class|. 
%
% The |unknownPolicy| differs from |thresholdPolicy| in that if the certainty is
% low and one of the top two predicted classes is not |baseline_class|,
% it will relabel the data to be |'Unknown'|. This is helpful for
% finding interesting sections of the data that do not belong
% confidently to any of the categories found in the original training
% set. 

%% 
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio