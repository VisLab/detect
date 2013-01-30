%% labelWindows     
% Classify data windows using an SVM model and compare to original labels
%
%% Syntax:
%    results = labelWindows(inputData, model)
%    [results accuracy] = labelWindows(inputData, model, actualLabels)
%
%% Description
%
% |results = labelWindows(inputData, model)| returns an array of structures
% containing the classification results of |inputData| based on |model|.
% 
% |[results, accuracy] = labelWindows(inputData, model, actualLabels)| 
% returns the classification accuracy in the field |accuracy|. The 
% |actualLabels| must be passed in order to compute the accuracy.
%
% The input arguments are:
%
% <html>
% <table>
% <thead>
% <tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% </thead>
% <tr>
% <td><tt> inputData </tt></td>
% <td> Either a 3-dimensional matrix of size channels x windowSize x windows,
%      or an EEGLAB EEG data structure containing epoched data. </td></tr>
% <tr>
% <td><tt> model </tt></td>
% <td> The output model structure from getModel. </td></tr>
% <tr>
% <td><tt> actualLabels </tt></td>
% <td>  (Optional) A cell array of strings denoting the true class labels
%       for <tt>inputData</tt>. Must be of length windows. </td></tr>
% </table>
% </html>
%
% The output argument is an array of structures with the following fields:
%
% <html>
% <table>
% <thead><tr><td><strong>Field</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> .label </tt></td>
% <td> String label with the classified class </td></tr>
% <tr>
% <td><tt> .actualLabel </tt></td>
% <td>  The original label for the window. This will be empty if the
%                         input actualLabels was omitted. </td></tr>
% <tr>
% <td><tt> .certainty </tt></td>
% <td>  The certainty of the prediction </td></tr>
% <tr>
% <td><tt> .likelihoods </tt></td>
% <td> The order of the categories, from most likely to
%                         least likely. The first entry of <tt>.likelihoods</tt> is
%                         the same as <tt>.label</tt>. </td></tr>
% <tr>
% <td><tt> .prob_estimates </tt></td>
% <td>  The estimated probability distribution of each category </td></tr>
% </table>
% </html>
%
%% Example
%
% Build a classification model using only the first 32 channels in the
% dataset, using an order 5 autogressive model as features. Use 2 cross
% validations as well. Use the sample training dataset provided with the 
% toolbox for illustration. Use the output to classify the same data.

    load data/training.mat;
    load data/labels.mat;
    model = getModel(training, labels, 1:32, 2, @getARfeatures, 5)
    [results accuracy] = labelWindows(training, model, labels)
    results(10)

%%
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio