%% labelData  
% Create a structure containing labels with certainy measure for data
%
%% Syntax:
%   results = labelData(inputData, model)
%   results = labelData(inputData, model, srate)
%   results = labelData(inputData, model, srate, slideWidth)
%
%% Description
%
% |results = labelData(inputData, model)| returns a structure containing 
% the classification results for |inputData| using model (as computed from |getModel|). 
% A default sampling rate of 256 Hz and a default window slide width of
% 0.01 seconds are used.
%
% |results = labelData(..., srate)| uses a sampling rate of |srate| Hz
% for the calculation.
%
% |results = labelData(..., slideWidth)| uses a window slide width of
% |slideWidth| seconds in performing the labeling.
%
 
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
% <td>Predicted label</td>
% <td><tt>'None'</tt></td></tr>
% <tr>
% <td><tt>.time</tt></td>
% <td>Time in seconds of the predicted label</td>
% <td><tt>[10.6836 10.8047]</tt></td></tr>
% <tr>
% <td><tt>.certainty</tt></td>
% <td>Measure indicating likelihood that prediction is correct</td>
% <td><tt>0.925</tt></td></tr>
% <tr>
% <td><tt>.likelihoods</tt></td>
% <td>Cell array of labels ordered from most likely to
%                  least likely for that event</td>
% <td><tt>{7x1 cell}</tt></td></tr>
% </table>
% </html>
%
%% Example
% Create a model from the training data and label continuous data using a
% sampling rate of 256 Hz and a sliding window of 250 ms.
   load training.mat;
   load labels.mat;
   load testing.mat;
   model = getModel(training, labels);
   results = labelData(testing, model, 256, 0.25)
   
%% Extended Notes
% The certainty is calculated by using |'-b 1'| option in |LibSVM| to
% return the probabilities of the possible labels for each window.
% The |labelData| function calculates the |certainty| as 
% (P(1)-P(2))/P(1), where P(1) is the probability of the most
% probable label and P(2) is the probability of the second most
% probable label.
%% 
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio