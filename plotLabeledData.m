function labelSet = plotLabeledData(inputData, model, results, varargin)
%plotLabeledData   plots the labeled data from labelData
%
% Syntax:
%   events = plotLabeledData(inputData, model, results)
%   events = plotLabeledData(inputData, model, results, varargin)
%
%   events = plotLabeledData(inputData, model, results, srate) 
%   displays a data scroll plot window with the events detected using
%   labelData. 
%
%   events = plotLabeledData(inputData, model, results, varargin)
%   supplies additional parameters as name-value pairs.
%
% Input:
%      inputData      Data of either a 2-D matrix or an EEGLAB EEG data
%                     structure containing 2-D data.
%          model      The SVM model output from getModel.
%        results      The output from labelData
%
% Optional parameters as name-value pairs:
%
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
%       'colors'      A nEvents x 3 array of custom-defined colors             
%
%   Output:
%     event        A cell array with columns
%                  [eventtype     startTime     endTime]
%
% Example: Build the artifact classification model from the sample data
% included in the toolbox, and display only eye blinks and jaw clenches:
% 
%    load data/training
%    load data/labels
%    model = getModel(training, labels, 1 : 64);
%    load data/testing;
%    results = labelData(testing, model, 256, 32);
%    plotLabeledData(testing, model, results, 'srate', 256, 'includeClasses', {'Eye Blink', 'Jaw Clench'})
%
%   Copyright (C) 2012  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
%                       Kay Robbins, UTSA, krobbins@cs.utsa.edu

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

    if nargin < 3
        help plotLabeledData;
        return;
    end

    % Use inputParser to evaluate validity of required inputs
    parser = inputParser;
    parser.addRequired('inputData', @(x)  ...
        (isstruct(x) && isfield(x, 'data') && ndims(x.data) == 2) || ...
        (ndims(inputData) == 2 && length(inputData) ~= 1)); %#ok<ISMAT>
    parser.addRequired('model', @(x)  ...
        (isstruct(x) && isfield(x, 'SVM') && isfield(x, 'alphaLabelOrder')));
    parser.addRequired('results', @(x) ...
        (isstruct(x) && isfield(x, 'label') && isfield(x, 'time')));
    
    % use inputParser to evaluate validity of optional inputs
    parser.addParamValue('includeClasses', [], @(x) ~isempty(x) && iscellstr(x));
    parser.addParamValue('srate', 256, @(x) isnumeric(x) && x > 0);
    parser.addParamValue('event', [], @(x) isempty(x) || ...
        isstruct(x) && isfield(x, 'type') && isfield(x, 'latency'));
    parser.addParamValue('chanlocs', [], @(x) isstruct(x));
    parser.addParamValue('colors', [], @(x) isempty(x) || size(x, 2) == 3);
    
    % Parse all the inputs
    parser.parse(inputData, model, results, varargin{:});
    
    % Further refinement of inputs depending on data input
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
    categories = model.alphaLabelOrder;
    if isempty(colors) || size(colors, 1) < length(categories)
        colors = jet(length(categories));
    end
    
    % Extract data from inputData
    if isstruct(inputData) && isfield(inputData, 'data') && ...
            ndims(inputData.data) == 2  %#ok<ISMAT>
        data = inputData.data;
    elseif ndims(inputData) == 2 && length(inputData) ~= 1 %#ok<ISMAT>
        data = inputData;
    end
    
    labels = model.alphaLabelOrder;    
    predicted = {results(:).label};

    % Extract the labeled windows as events
    id = predicted(1);
    eCount = 1;  % Running count of events (the event counter)
    labelSet(eCount) = struct;
    labelSet(eCount).label = char(id);
    labelSet(eCount).startTime = results(1).time(1);
    eventcodes{eCount} = char(id);
    N = length(predicted);
    for i = 2 : N
        if ~strcmp(id,predicted(i))
            labelSet(eCount).endTime = results(i-1).time(2);
            eCount = eCount + 1;
            labelSet(eCount).label = char(predicted(i));
            labelSet(eCount).startTime = results(i).time(1);
            id = predicted(i);
            eventcodes{eCount} = char(predicted(i));
        end
    end
    % Add in half the training window size back to the last event time
    labelSet(eCount).endTime = results(N).time(2);

    % If given which classes to use (by includeClasses), will extract out
    if ~isempty(includeClasses)
        index = zeros(length(labelSet), 1);
        for i = 1 : length(includeClasses)
            index = index + strcmpi({labelSet.label}', includeClasses{i});
        end 
        index = logical(index); % converts to logical
        labelSet = labelSet(index);
    end
    
    % Event struct = [startTime endTime rgb(1) rgb(2) rgb(3) ch1 ... chM]
    eventMatrix = zeros(length(labelSet), size(data,1) + 5);
    for i = 1 : length(labelSet)
        eventMatrix(i, 1:2) = [srate*labelSet(i).startTime, srate*labelSet(i).endTime];
        for j = 1 : size(labels,1)
            if strcmpi(labelSet(i).label, labels(j))
                eventMatrix(i, 3:5) = colors(j,:);
            end
        end
    end
    
    % eegplot2 modified from eegplot to include labels and colors
    eegplot2(data, labels, colors, 'eloc_file', chanlocs,...
       'srate', srate, 'events', eventList, 'title', ...
       'plotLabeledData', 'command', [], 'winrej', eventMatrix);
    labelSet = (squeeze(struct2cell(labelSet)))';
end

