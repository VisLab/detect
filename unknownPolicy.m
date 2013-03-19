function [results accuracy] = unknownPolicy(results, baseline_class, certainty_threshold)
% unknownPolicy    relabel uncertain non-baseline events as "Unknown" 
%
% Syntax:
%    results = unknownPolicy(results, baseline_class, certainty_threshold)
%    [results accuracy] = unknownPolicy(results, baseline_class, certainty_threshold)
%
% Description:
%   The unknownPolicy is a filter applied after classification to
%   relabel events based on the certainty. In particular, unknownPolicy relabels
%   an event as "Unknown" if the certainty of its most likely event
%   is below the certainty_threshold and neither of the top two most
%   likely event labels is the baseline_class.
%   
% Input:
%               results     Output structure from labelData
%        baseline_class     The getModel label used as the base-line or "no event"
%     certainty_threshold   Value in [0,1] to threshold the certainty. 
%
% Output:
%               results     The same as the input variable, with the labels
%                           of the data adjusted according to the policy.
%
%
% Example:
% Apply unknownPolicy after creating a model
%     load training.mat;
%     load labels.mat;
%     load testing.mat;
%     model = getModel(training, labels);
%     results = labelData(testing, model, 256, 0.25);
%     results = unknownPolicy(results, 'None', 0.05);
%
% This example assumes the 'None' was the label for the baseline data.
%
% Notes:
%   The output of labelData has the following structure:
%
%   results        Structure array with the following fields 
%    - .label      Predicted label
%    - .time       Time in seconds of the predicted label
%    - .certainty  Measure indicating likelihood that prediction is correct
%    - .likelihoods  Cell array of labels ordered from most likely to
%                  least likely for that event.
%
%   A particular entry in this struct array has the following form:
%
%      results(85) = 
% 
%                   label: 'None'
%                    time: [10.6836 10.8047]
%               certainty: 0.9251
%             likelihoods: {7x1 cell}
%
% The unknownPolicy compares the value of the results.certainty 
% entry with the certainty_threshold. If the value is below and one 
% of the top two most likely labels (found in results.likelihoods) 
% is the baseline_class, then unknownPolicy changes the label to 
% be baseline_class. 
%
% unknownPolicy differs from thresholdPolicy in that if certainty is
% low and one of the top two predicted classes is not baseline_class,
% it will relabel the data to be 'Unknown.' This is helpful for
% finding interesting sections of the data that do not belong
% confidently to any of the categories found in the original training
% set. 

%   Copyright (C) 2011-2013  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
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

    % must have at least 3 input arguments
    if nargin < 3
        help unknownPolicy;
        return;
    end

    % The certainty must be between 0 and 1
    if ~(certainty_threshold >= 0 && certainty_threshold <= 1)
        error('unknownPolicy:invalid_certainty_threshold', ...
              'Input certainty_threshold must be between 0 and 1');
    end

    % Extract the certainties and labels
    certainty = [results.certainty];
    labelSet = unique({results.label});

    % The baseline_class must be a part of labelSet.
    if strcmp(labelSet, baseline_class) ~= 1
        error('unknownPolicy:invalid_baseline_class', ...
              'baseline_class not found in original labeling ')
    end

    N = length(certainty);
    for j = 1 : N
        if certainty(j) < certainty_threshold
           % One of top two predicted classes must be from baseline_class
            if strcmp(results(j).likelihoods(1), baseline_class) == 1 || ...
                    strcmp(results(j).likelihoods(2), baseline_class) == 1
                results(j).label = baseline_class;
            else
                results(j).label = 'Unknown';
            end
        end
    end
    
        
    accuracy = [];
    % recalculate the accuracy if the input was from labelWindows
    if isfield(results, 'actualLabel') && ~isempty([results.actualLabel])
       accuracy = sum(strcmpi({results.label}, {results.actualLabel}))/...
           size(results,2);
    end

end % unknownPolicy