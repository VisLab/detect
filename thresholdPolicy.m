function [results accuracy] = thresholdPolicy(results, baseline_class, certainty_threshold)
% thresholdPolicy  relabel uncertain events as baseline under certain conditions
%
% Syntax:
%    results = thresholdPolicy(results, baseline_class, certainty_threshold)
%    [results accuracy] = thresholdPolicy(results, baseline_class, certainty_threshold)
%
% Description:
%   The thresholdPolicy applies a filter based on the certainty 
%   to event labels contained in the label field of the results structure. 
%   In particular, thresholdPolicy relabels an event as the baseline_class 
%   if the certainty of its most likely label is below the 
%   certainty_threshold and one of the top two most
%   likely event labels is the baseline_class. The baseline_class
%   should be a string that is one of original labels used in the model 
%   building step.
%   
%   Inputs
%                 results   Output of labelData or labelWindows
%          baseline_class   The getModel label used as the base-line or "no event"
%     certainty_threshold   Value from [0,1] to threshold the certainty. 
%
%   Output:
%                 results   The same as the input variable, with the labels
%                           of the data adjusted according to the policy.
%                accuracy   Optional output if the input was from
%                           labelWindows. Recalculates the classification 
%                           accuracy if actualLabels was given in
%                           labelWindows.
% Example:
% Create a model from the training data and relabel uncertain events
%   load training.mat;
%   load labels.mat;
%   load testing.mat;
%   model = getModel(training, labels);
%   results = labelData(testing, model, 256, 0.25);
%   results = thresholdPolicy(results, 'None', 0.05);
%
% This example assumes the 'None' was the label for the baseline data.
%
%  The thresholdPolicy compares the value of the results.certainty 
%  entry with the certainty_threshold. If the value is below and one 
%  of the top two most likely labels (found in results.likelihoods) 
%  is the baseline_class, then thresholdPolicy changes the label to 
%  be baseline_class. 
%
%  This is a conservative policy because if there is any
%  possibility that the data could be the baseline_class, the class is
%  relabeled to be the baseline_class.  
%

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

    % must have at least three arguments
    if nargin < 3
        help thresholdPolicy;
        return;
    end

    % The certainty must be between 0 and 1
    if ~(certainty_threshold >= 0 && certainty_threshold <= 1)
        error('thresholdPolicy:invalid_certainty_threshold', ...
              'Input certainty_threshold must be between 0 and 1');
    end

    % Extract the certainties and labels
    certainty = [results.certainty];
    labelSet = unique({results.label});

    % baseline_class must be a part of labelSet.
    if strcmp(labelSet, baseline_class) ~= 1
        error('thresholdPolicy:invalid_baseline_class', ...
              'baseline_class not found in original labeling ')
    end

    N = length(certainty);
    for j = 1 : N
        if certainty(j) < certainty_threshold
            % One of top two predicted classes must be from baseline_class
            if strcmp(results(j).likelihoods(1), baseline_class) == 1 || ...
                    strcmp(results(j).likelihoods(2), baseline_class) == 1
                results(j).label = baseline_class;
            end
        end
    end
    
    accuracy = [];
    % recalculate the accuracy if the input was from labelWindows
    if isfield(results, 'actualLabel') && ~isempty([results.actualLabel])
       accuracy = 100*(sum(strcmpi({results.label}, {results.actualLabel}))/...
           size(results,2));
    end
    
end  % thresholdPolicy