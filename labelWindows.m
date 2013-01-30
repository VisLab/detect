function [results accuracy] = labelWindows(inputData, model, actualLabels)
% labelWindows     classify data windows using an SVM model and compare to labels
%
% Syntax:
%    results = labelWindows(inputData, model)
%    results = labelWindows(inputData, model, actualLabels)
%
% results = labelWindows(inputData, model, actualLabels) returns a results
% structure with the results of using model to classify the testing data.
% If actualLabels is included, the results structure also contains the accuracy.
%
% Input:
%     inputData     Either channels x windowSize x windows array of testing 
%                   data or an EEGLAB EEG dataset containing epoched data.
%         model     Model structure calculated from getModel.
%  actualLabels     A windows x 1 cell array containing the true string 
%                   labels. (If empty or not included, the
%                   results structure will not contain accuracy of prediction.)
%
%   Output:
%     results   An array of structures with fields:
%      - .label           Atring label with the classified class
%      - .actualLabel     The original label for the window, empty if the
%                         input actualLabels was omitted.
%      - .certainty       The certainty of the prediction
%      - .likelihoods     The order of the categories, from most likely to
%                         least likely. The first entry of .likelihoods is
%                         the same as .label.
%      - .prob_estimates  The estimated probability distribution of all the
%                         classes, obtained from LibSVM.

%   Copyright (C) 2012  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
%                       Kay Robbins, UTSA, krobbins@cs.utsa.edu
%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    
    if nargin < 2   % must have at least two inputs
        help labelWindows;
        return;
    end
    % Training data must be 3 dimensional
    if isstruct(inputData) && isfield(inputData, 'data') && ndims(inputData.data) == 3
        testing = inputData.data;
    elseif ndims(inputData) == 3
        testing = inputData;
    else
        error('labelWindows:DataNot3D','Input data is not in the correct format')
    end
    
   % Check the arguments
    data = double(testing(model.sChannels, :, :)); % Extract channels
    [nChannels, nFrames, nWindows] = size(data); %#ok<ASGLU>
    if nargin < 3
        actualLabels = [];
    elseif ~isempty(actualLabels) && (~iscellstr(actualLabels) || ...
            length(actualLabels) ~= nWindows)
        error('labelWindows:LabelLengthNotEqual','Labels is not a cellstr array of strings of right length');
    elseif ndims(data) ~= 3
        error('labelWindows:DataNot3D','Testing data is not in epoched form (a 3-D array)');
    end

    % Use the same feature function used in the model training
    features = model.ffunc(data, model.ffunc_inputs{:});
    if size(features, 1) ~= nWindows % must be  nWindows x nFeatures
        error('labelWindows:IncorrectFeatureSize',['Output size of model featureFunction is not right size. ' ...
               'The dimension should be of size windows x features']);
    end
    [output accuracy] = testModel(features, model, actualLabels);

    % Pre-allocation
    results(nWindows).label = [];
    results(nWindows).actualLabel = [];
    results(nWindows).certainty = [];
    results(nWindows).likelihoods = [];
    results(nWindows).prob_estimates = [];
    
    if nargin == 3
        for i = 1 : nWindows
            results(i).label = char(output.predicted(i));
            results(i).actualLabel = char(output.actualLabels(i));
            results(i).certainty = output.certainty(i);
            results(i).prob_estimates = output.prob_estimates(i,:);
            results(i).likelihoods = output.likelihoods{i};
            results(i).labelOrder = model.SVMLabelOrder;
        end    
    else
        for i = 1 : nWindows
            results(i).label = char(output.predicted(i));
            results(i).certainty = output.certainty(i);
            results(i).prob_estimates = output.prob_estimates(i,:);
            results(i).likelihoods = output.likelihoods{i};
            results(i).labelOrder = model.SVMLabelOrder;
        end
    end
end % labelWindows

function [results prediction_accuracy] = testModel(features, model, actualLabels)
    % Use model's SVM to classify features
    [nWindows, nFeatures] = size(features); %#ok<NASGU>
    prediction_accuracy = [];
    if ~isempty(actualLabels)
        % Convert labels to numeric values for use in SVM
        [categories, ia, index] = unique(actualLabels); %#ok<ASGLU>
        [predicted_label, accuracy, prob_estimates] = ...
            svmpredict_DETECT(index, features, model.SVM, '-b 1');
        results.predicted = categories(predicted_label);
        prediction_accuracy = accuracy(1);
        results.actualLabels = actualLabels;
    else
        % Use NaN as numeric labels for SVM, can't give accuracy here
        [predicted_label, ignore, prob_estimates] = ...
            svmpredict_DETECT(NaN * ones(nWindows, 1), features, model.SVM, '-b 1'); %#ok<ASGLU>
        results.predicted = model.alphaLabelOrder(predicted_label);
    end
    
    certainty = zeros(size(prob_estimates, 1), 1);
    likelihoods = cell(size(prob_estimates, 1), length(model.SVMLabelOrder));
    for i = 1 : size(prob_estimates, 1)
        [sorted_probs, b] = sort(prob_estimates(i,:), 'descend');
        certainty(i) = (sorted_probs(1) - sorted_probs(2))/...
            sorted_probs(1);
        likelihoods{i} = model.SVMLabelOrder(b);
    end
    results.certainty = certainty;
    results.prob_estimates = prob_estimates;
    results.SVMLabelOrder = model.SVMLabelOrder;
    results.likelihoods = likelihoods;
end % testModel


