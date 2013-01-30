%% getModel 
% calculate an SVM model for classification
%
%% Syntax
%   model = getModel(training, labels)
%   model = getModel(training, labels, sChannels)
%   model = getModel(training, labels, sChannels, numCVs)
%   model = getModel(training, labels, sChannels, numCVs, featureFunction, varargin)
%
%% Description
%
% |model = getModel(training, labels)| returns a model structure containing
% the fitted model for classifying the input |training| into the classes 
% of |labels|. By default, |getModel| uses all the channels in the data 
% and 4 cross validations. The default feature function uses the 
% autoregressive coefficients of model order two, computed for each channel 
% and concatenated across all the channels.
%
% |model = getModel(training, labels, sChannels)| builds the classification
% model using a channel index specified by |sChannels|. |sChannels| is a
% numeric vector of channel indices (for example, |sChannels = 1:32|
% specifies the first 32 channels in the data will be used).
%
% |model = getModel(training, labels, sChannels, numCVs)| will change the
% number of cross-validations to use.
%
% |model = getModel(training, labels, sChannels, numCVs, featureFunction,
% varargin)| builds the classification model using the feature extraction
% function |featureFunction|, together with its required inputs |varargin|.
%
%% Notes
% The input arguments to |getModel| are:
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> training </tt></td>
% <td> Either a 3D matrix of size channels x windowSize x windows,
%      or an EEGLAB EEG data structure containing epoched data. </td></tr>
% <tr>
% <td><tt> labels </tt></td>
% <td> A cell array of strings of length windows to denote a class label
%      for each window</td></tr>
% <tr>
% <td><tt> sChannels </tt></td>
% <td>  A numeric vector of channels to use in the model building. Default
%       is to use all available channels</td></tr>
% <tr>
% <td><tt> numCVs </tt></td>
% <td> A numeric value to denote the number of cross validations to use </td></tr>
% <tr>
% <td><tt> featureFunction, varargin </tt></td>
% <td> The feature function to use in the model training. The inputs needed
%      for the feature function are passed by varargin. See getARfeatures.m
%      for an example of a feature extraction function.</td></tr>
% </table>
% </html>
%
% The output arguments are:
%
%
% <html>
% <table>
% <thead><tr><td><strong>Argument</strong></td>
% <td><strong>Description<strong></td></tr>
% <tr>
% <td><tt> .SVM </tt></td>
% <td> The SVM model structure obtained from LibSVM </td></tr>
% <tr>
% <td><tt> .CV </tt></td>
% <td> Cross-validation accuracy </td></tr>
% <tr>
% <td><tt> .bestc, .bestg </tt></td>
% <td>  Optimal parameters for the SVM based on using a grid-search </td></tr>
% <tr>
% <td><tt> .alphaLabelOrder </tt></td>
% <td> The alphabetical order of the labels </td></tr>
% <tr>
% <td><tt> .SVMLabelOrder </tt></td>
% <td>  Original order of label appearance in data </td></tr>
% <tr>
% <td><tt> .tframes </tt></td>
% <td>  Size of the training windows, in frames </td></tr>
% <td><tt> .sChannels </tt></td>
% <td>  Channel index used for training </td></tr>
% <tr>
% <td><tt> .ffunc, .ffunc_inputs </tt></td>
% <td>  Feature function used together with the inputs </td></tr>
% </table>
% </html>

%% Example
% Build a classification model using only the first 32 channels in the
% dataset, using an order 5 autogressive model as features. Use 2 cross
% validations as well. Use the sample training dataset provided with the 
% toolbox for illustration.

    load data/training.mat;
    load data/labels.mat;
    model = getModel(training, labels, 1:32, 2, @getARfeatures, 5)

%% See also
% <getARfeatures_help.html |getARfeatures|>
%
%% 
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio