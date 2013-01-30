function results = labelData(inputData, model, srate, slideWidth)
% labelData  return a structure containing labels with certainy measures for data
%
% Syntax:
%   results = labelData(inputData, model)
%   results = labelData(inputData, model, srate)
%   results = labelData(inputData, model, srate, slideWidth)
%
% The labelData function returns a structure containing the classification 
% results for inputData using model (as computed from getModel). 
% If srate is omitted, the default is 256 Hz. If slideWidth is omitted,
% the default is 0.01 seconds.
%
%
% Input:
%    inputData         EEG structure containing 2D non-epoched
%                      data or channels x frames data to be labeled
%    model             Classifier for labeling (output from getModel)
%    srate             Sampling rate in Hz of data (256 by default)               
%    slideWidth        Label interval (in seconds) (0.01 by default)
%
% Output:
%   results        Structure array with the following fields 
%    - .label      Predicted label
%    - .time       Time in seconds of the predicted label
%    - .certainty  Measure indicating likelihood that prediction is correct
%    - .likelihoods  Cell array of labels ordered from most likely to
%                  least likely for that event.
%
% Extended Notes:
%    The certainty is calculated by using '-b 1' option in LibSVM to
%    return the probabilities of the possible labels for each window.
%    The labelData function calculates the certainty as 
%    (P(1)-P(2))/P(1), where P(1) is the probability of the most
%    probable label and P(2) is the probability of the second most
%    probable label.
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
   
   if nargin < 2 % must have at least two inputs
       help labelData;
       return;
   end
   
   % Check for input data type.
   if isstruct(inputData) && isfield(inputData, 'data') && ndims(inputData.data) == 2 %#ok<ISMAT>
        data = inputData.data;
        fileType = 1; % input is an EEGLAB EEG structure
    elseif ndims(inputData) == 2 && length(inputData) ~= 1 %#ok<ISMAT>
        data = inputData;
        fileType = 0; % input is a 2-D matrix
    else
        error('labelData:DataNot2D', ...
            'InputData must be 2D or inputData.data must be 2D');
   end
   data = double(data(model.sChannels, :));
   
   % Set defaults
   if nargin == 2
       if fileType == 1
           srate = inputData.srate;
       else
           srate = 256;
       end
        slideWidth = 0.01;
   elseif nargin == 3
        slideWidth = 0.01;
   end
   
   % Convert slideWidth in seconds to frames, use floor to round down.
   slideWidth = floor(slideWidth * srate);
   
   % Make sure the slideWidth is valid
   windowLength = model.tframes; 
   if slideWidth <= 0 
       error('labelData:InvalidSlide', 'Slide width must be positive')
   elseif slideWidth > windowLength
       error('labelData:SlideTooBig', ...
             'Slide width cannot be larger than training window size');
   end
    
    % Calculate number of slides (round down the estimated slide number)
    N = floor((size(data, 2))/slideWidth - windowLength/slideWidth + 1);

    % Calculate time in frames of computed labels
    t = (floor(windowLength/2) : slideWidth : size(data, 2)) - 1;
    
    % Pre-allocate the array of structures
    results(N).label = [];
    results(N).time = [];
    results(N).certainty = [];
    results(N).likelihoods = [];
    
    loweredge = 1;
    upperedge = windowLength;
    for j = 1 : N
        data1 = data(:, loweredge:upperedge);
        features = model.ffunc(data1, model.ffunc_inputs{:});

        % svmpredict requires numeric input labels so use NaN as a placeholder
        [predicted_label, ignore1, prob_estimates] = ...
            svmpredict_DETECT(NaN, features, model.SVM, '-b 1'); %#ok<ASGLU>

        [a, b] = sort(prob_estimates, 'descend'); %#ok<ASGLU>
        certainty = (prob_estimates(b(1)) - prob_estimates(b(2)))/...
                      prob_estimates(b(1));
        upperedge = upperedge + slideWidth;
        loweredge = loweredge + slideWidth;

        results(j).label = char(model.alphaLabelOrder(predicted_label));
        % Divide by srate to get time.
        results(j).time = [t(j) - ceil(slideWidth/2) t(j) + floor(slideWidth/2) - 1] / srate;
        results(j).certainty = certainty;
        results(j).likelihoods = model.SVMLabelOrder(b);
    end
    
end % labelData