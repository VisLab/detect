function model = getModel(training, labels, sChannels, numCVs, featureFunction, varargin)
% getModel calculate an SVM model for classification
%
% Syntax:
%   model = getModel(training, labels)
%   model = getModel(training, labels, sChannels)
%   model = getModel(training, labels, sChannels, numCVs)
%   model = getModel(training, labels, sChannels, numCVs, featureFunction, varargin)
%
% model = getModel(training, labels, sChannels, numCVs, featureFunction, varargin) 
% returns a model structure containing the fitted model for classifying 
% the input "data" into the classes of "labels". By default, getModel
% uses all of the channels and 4 cross validations. The default feature
% function uses the autoregressive coefficients of model order 2, computed for
% each channel and concatenated across all the channels.
%
% Input:
%     training        A channels x windowSize x windows array of training data (or 
%                     An EEG structure with epoched data)
%     labels          A windows x 1 cell array of strings giving trial labels 
%     sChannels       Vector of channel indices used in analysis (default is 1:channels)            
%     numCVs          cross-validations in model building (default is 4)
%     featureFunction Function to transform training data to features
%                     (coefficients of AR model of order two used by default)
%     varargin        Arguments needed for featureFunction. 
%
% Output:
%     model       A LibSVM model structure with some additional fields
%       - .SVM                Structure returned from LibSVM
%       - .CV                 The cross-validation accuracy
%       - .bestc              Optimal cost parameter for the RBF kernel 
%       - .bestg              Optimal variance for the RBF kernel
%       - .alphaLabelOrder    Alphabetical order of string labels
%       - .SVMLabelOrder      Original order of label appearance in data
%       - .tframes            Width in frames of training windows (epochs)
%       - .sChannels          Channels used in the model training
%       - .ffunc              Function handle to feature function
%       - .ffunc_inputs       Parameters of feature 
%
% Example: The following call generates a classifier based on the
% training data included with the toolbox using channels 1:64 and
% 2 autoregressive features computed by the getARfeatures function. 
% Training is performed using 4-fold cross validation.
%
%      model = getModel(training, labels, 1 : 64, 4, @getARfeatures, 2)
%
% Extended Notes 1:
%
% The trainSVM function uses a rectangular grid search on radial
% basis functions (RBFs) in a log-base 2 scale. C and G are the two
% parameters, where C is the cost term in the RBF and G is the variance
% term in the RBF Kernel. Depending on the features, you may need to
% change the bounds of the grid search to get a better SVM fit.
%
% The default search range is -5 : 0.5 : 5 for both C and G in log2
% scale. 2^(range) gets the unscaled version.
%
% Extended Notes 2:
%
% If the default getARFeatures function is used for the feature function,
% the code checks to see if the arburg function is in the path. This
% function is part of the MATLAB Signal Processing Toolbox. This code will use
% that function. If arburg is not present, it will use the arfit2 function
% from the Time Series Analysis Toolbox (bundled with this toolbox).
%
% Copyright (C) 2012  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
%                       Kay Robbins, UTSA, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    
    if nargin < 1
        help getModel;
        return;
    end

    % Training data can be an array or in a structure with a .data field
    if isstruct(training) && isfield(training, 'data') 
        data = training.data;  % Assume in EEG structure
    else
        data = training;
    end
    if ndims(data) ~= 3
        error('Training is not a structure or array containing 3D data');
    end
    
    % Check that labels has the right number of elements
    [channels, frames, windows] = size(data); 
    if ~iscellstr(labels) || length(labels) ~= windows 
        error('Labels is not a cell array of strings of correct length');
    end

    % Process the arguments
    if nargin == 2
        sChannels = 1 : channels;
        numCVs = 4;
        featureFunction = @getARfeatures;
        varargin{1} = 2;
    elseif nargin == 3
        numCVs = 4;
        featureFunction = @getARfeatures;
        varargin{1} = 2;
    elseif nargin == 4
        featureFunction = @getARfeatures;
        varargin{1} = 2;
    end
  
    % If using AR features, use signal processing toolbox if available 
    if isequal(featureFunction, @getARfeatures)
        if exist('arburg.m', 'file') == 2
            caseLabel = 1;
        elseif exist('arfit2.m', 'file') == 2
            caseLabel = 2;
        else
            error('No autoregressive feature extraction algorithm found.');
        end
        inputArgs = [varargin {caseLabel}];
    else
        inputArgs = varargin;
    end
    
    % Compute the features
    data = double(data(sChannels, :, :)); 
    features = featureFunction(data, inputArgs{:});
    if size(features, 1) ~= windows % must be windows x featureSize
        error(['Output of featureFunction is not of correct dimension. ' ...
               'The dimension should be of size (windows) x (features)']);
    end

    % Train the model using libSVM
    model = trainSVM(features, labels, numCVs); 
    model.tframes = frames;
    model.sChannels = sChannels;
    model.ffunc = featureFunction;
    model.ffunc_inputs = inputArgs;
end % getModel

function model = trainSVM(features, labels, numCVs)
% Train SVM using specified features, labels and cross validations
    [categories, ia, index] = unique(labels);  %#ok<ASGLU>

    % Grid search to optimize RBF parameters C (cost) and G (variance).
    bestcv = 0;
    for log2c = -5 : 0.5 : 5,
        for log2g = -5 : 0.5 : 5,
            cmd = [' -v ', num2str(numCVs), ' -c ', num2str(2^log2c), ...
                ' -g ', num2str(2^log2g) ' -q '];
            cv = svmtrain_DETECT(index, features, cmd);
            if (cv >= bestcv)
                bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
            end
        end
    end

    cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) ' -b 1 -q '];
    model.SVM = svmtrain_DETECT(index, features, cmd);
    model.CV  = bestcv;
    model.bestc = bestc;
    model.bestg = bestg;
    model.alphaLabelOrder = categories;
    % this gets the original order of the epochs in the original dataset.
    model.SVMLabelOrder = categories(model.SVM.Label);
end  % trainSVM

