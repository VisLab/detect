%% thresholdPolicy
% Relabel uncertain events as baseline under certain conditions
%
%% Syntax
%    results = thresholdPolicy(results, baseline_class, certainty_threshold)
%    [results accuracy] = thresholdPolicy(results, baseline_class, certainty_policy)
%
%% Description
% |results = thresholdPolicyPolicy(results, baseline_class, certainty_threshold)|
% applies a filter based on the certainty to event labels contained in the 
% |label| field of the |results| structure. In particular, |thresholdPolicy| relabels
% an event as the |baseline_class| if the certainty of its most likely
% label is below the |certainty_threshold| and one of the top two most
% likely event labels is the |baseline_class|. The |baseline_class|
% should be a string that is one of original labels used in the model 
% building step.
%
% |[results accuracy] = thresholdPolicy(results, baseline_class,
% certainty_threshold)| recalculates the classification accuracy if the
% input was from |labelWindows|. 


%% Example
% Create a model from the training data and relabel uncertain events
   load training.mat;
   load labels.mat;
   load testing.mat;
   model = getModel(training, labels);
   results = labelData(testing, model, 256, 0.25);
   results = thresholdPolicy(results, 'None', 0.50);

%% Notes
% The output structure |results| has the following fields:
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
% The |thresholdPolicy| compares the value of the |results.certainty| 
% entry with the |certainty_threshold|. If this value is below the 
% threshold and one of the top two most likely labels (found in the first
% two entries of |results.likelihoods|) is the |baseline_class|, 
% then |thresholdPolicy| changes the label to be |baseline_class|. 
%
% This is a conservative policy because if there is any
% possibility that the data could be the |baseline_class|, the class is
% relabeled to be the |baseline_class|.  
%% 
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio