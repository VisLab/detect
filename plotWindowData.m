function events = plotWindowData(inputData, model, results, varargin)
%plotWindowData   plots the decoded windows from labelWindows
%
% Syntax:
%   events = plotWindowData(inputData, model, results)
%   events = plotWindowData(inputData, model, results, varargin)
%
%   events = plotWindowData(inputData, model, results) 
%   displays a data scroll plot window with the events detected using
%   labelWindows. 
%
%   events = plotLabeledData(inputData, model, results, varargin)
%   supplies additional parameters as name-value pairs.
%
%   Input:
%      inputData      Data of either a 3D matrix or an EEGLAB EEG structure 
%                     containing 3D (windowed/epoched) data.
%          model      The SVM model output from getModel.
%        results      the output from labelWindows
%
%   Optional parameters as name-value pairs:
%        'srate'      Sampling rate of the data, default is from EEG
%                     structure if input data is EEGLAB data, and 256 for 
%                     matrix data
% 'includeClasses'    Cell array of strings denoting the desired plotting
%                     categories or labels (all by default).
%         'event'     A structure array with type and latency fields. If
%                     empty and inputData is a structure with a non-empty
%                     event field, the value of this field is used.
%      'chanlocs'     A structure array with a .labels fields. If
%                     empty and inputData is a structure with a non-empty
%                     chanlocs field, the value of this field is used.
%        'colors'     A nEvents x 3 array of custom-defined colors     
%
%    Output:
%      events        A windows x 2 cell array with columns:
%                     [eventtype]     [certainty]
%
%  Example: Build a training model on epoched data and test the model on
%  the same epoched data. Plot only epochs containing eye blinks and jaw
%  clenches. 
%
%    load data/training
%    load data/labels
%    model = getModel(training, labels, 1 : 64);
%    results = labelWindows(training, model, labels);
%    plotWindowData(training, model, results, 'srate', 256, 'includeClasses', {'Eye Blink', 'Jaw Clench'})

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

    % must have at least 3 input arguments
    if nargin < 3
        help plotWindowData;
        return;
    end

    % use inputParser to evaluate validity of required inputs
    parser = inputParser;
    parser.addRequired('inputData', @(x)  ...
        (isstruct(x) && isfield(x, 'data') && ndims(x.data) == 3) || ...
        (ndims(inputData) == 3 && length(inputData) ~= 1)); 
    parser.addRequired('model', @(x)  ...
        (isstruct(x) && isfield(x, 'SVM') && isfield(x, 'alphaLabelOrder')));
    parser.addRequired('results', @(x) ...
        (isstruct(x) && isfield(x, 'label')));
    
    % use inputParser to evaluate validity of optional inputs
    parser.addParamValue('includeClasses', [], @(x) ~isempty(x) && iscellstr(x));
    parser.addParamValue('srate', 256, @(x) isnumeric(x) && x > 0);
    parser.addParamValue('event', [], @(x) isempty(x) || ...
        isstruct(x) && isfield(x, 'type') && isfield(x, 'latency'));
    parser.addParamValue('chanlocs', [], @(x) isstruct(x));
    parser.addParamValue('colors', [], @(x) isempty(x) || size(x, 2) == 3);
    
    % parse all the inputs
    parser.parse(inputData, model, results, varargin{:});
    
    % further refinement of inputs depending on data input
    srate = parser.Results.srate;
    if isstruct(inputData) && isfield(inputData, 'srate') && ~isempty(inputData.srate)
        srate = inputData.srate;
    end
    
    eventList = parser.Results.event;
    if isempty(eventList) && isstruct(inputData) && ...
            isfield(inputData, 'event') && ~isempty(inputData.event)
        eventList = inputData.event;
    end
    
    chanlocs = parser.Results.chanlocs;
    if isempty(chanlocs) && isstruct(inputData) && ...
            isfield(inputData, 'chanlocs') && ~isempty(inputData.chanlocs)
        chanlocs = inputData.chanlocs;
    end
    
    includeClasses = parser.Results.includeClasses;
    colors = parser.Results.colors;
    predicted = {results.label}';
    categories = unique({results.label})';
    windowLength = model.tframes;
    
    if isempty(colors) || size(colors, 1) < length(categories)
        colors = jet(length(categories));
    end
    
    % extracts data from inputData
    if isstruct(inputData) && isfield(inputData, 'data') && ...
            ndims(inputData.data) == 3 
        data = inputData.data;
    elseif ndims(inputData) == 3 && length(inputData) ~= 1
        data = inputData;
    end
       
    [nChannels, nSamples, nWindows] = size(data); %#ok<ASGLU>
    t = (0 : nWindows) * windowLength; 
    [ignore1, ignore2, colorIndex] = unique(predicted); %#ok<ASGLU>
    
    % event struct = [startTime endTime rgb(1) rgb(2) rgb(3) ch1 ... chM]
    eventMatrix = zeros(nWindows, nChannels + 5);
    eventMatrix(:,1:2) = [t(1:end-1)' t(2:end)'];
    eventMatrix(:,3:5) = colors(colorIndex, :);  
    
%     % add 'Unknown' to includeClasses (unknown's from unknownPolicy)
%     if any(ismember(categories, 'Unknown'))==1
%         includeClasses{end+1} = 'Unknown';
%     end
    
    % if given which classes to use (by includeClasses), will extract out
    if ~isempty(includeClasses)
        index = zeros(nWindows, 1);
        for i = 1 : length(includeClasses)
            index = index + strcmpi(predicted, includeClasses{i});
        end
        index = logical(index); % converts to logical
        eventMatrix = eventMatrix(index, :);
    end
    
    % eegplot2 modified from eegplot to include labels and colors 
    eegplot2(data, categories, colors, 'eloc_file', chanlocs,...
        'srate', srate, 'events', eventList, 'title', ...
        'plotWindowData', 'command', [], 'winrej', eventMatrix);
    
    % pre-allocation to create the events structure output
    events(nWindows).predicted = [];
    events(nWindows).certainty = [];
    for i = 1 : nWindows
        events(i).predicted = results(i).label;
        events(i).certainty = results(i).certainty;
    end
    events = (squeeze(struct2cell(events)))';

end % plotWindowData

