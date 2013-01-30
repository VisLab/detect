function labelSet = markEvents(inputData, categories, varargin)
%markEvents         Marks data in EEG Dataset and returns structure of
%                   eventList
%
% Syntax:
%   labelSet = markEvents(inputData, categories)
%   labelSet = markEvents(inputData, categories, varargin)
%
%   labelSet = markEvents(inputData, categories) opens a GUI for manually 
%             labeling the data with the categories found in categories.
%
%   labelSet = markEvents(inputData, categories, varargin) supplies additional
%   parameters as name-value pairs.
%
% Inputs:
%   inputData       Either a 2-D matrix of dimensions channels x frames or
%                   an EEGLAB EEG data file containing 2-D data .
%   categories      Cell array of strings to label data with
%     srate         Sampling rate of the data
%
% Optional parameters as name-value pairs:
%
%      'srate'     Sampling rate of the data in Hz. If omitted and
%                  inputData is a structure with a non-empty srate field,
%                  that value is used. Otherwise a default value of
%                  256 Hz is used.
%     'regions'    Previous output of markEvents or plotLabeledData. This
%                  is a (nEvents x 3) cell array.  
%      'event'     A structure array with type and latency fields. If
%                  empty and inputData is a structure with a non-empty
%                  event field, the value of this field is used.
%   'chanlocs'     A structure array with xxx fields. If
%                  empty and inputData is a structure with a non-empty
%                  chanlocs field, the value of this field is used.
%     'colors'     An n x 3 array of colors. If n is less than the
%                  length of categories, the jet color map is used.
%
%
%  Outputs:
%  labelSet        Event structure with
%                   [category] [startTime] [endTime] [badChnList]
%
%                   category - one of the strings provided in the input
%                             'categories'
%
%                   startTime/endTime - This is in seconds
%
%                   badChnList - a vector of channel numbers to indicate of
%                                the channel is bad. In the data scroll 
%                                plot this will show up as a red channel.
%
%  Example 1: 
%       load data/testing;
%       regions = markEvents(testing, {'Blink', 'Muscle', 'Other'}, 256)
%
%  for marking EEG data with blinks, muscles and Other and saves it to
%  the output variable regions.
%
%  Example 2:
%
%  After using the above command, if you want to redo the markings
%
%      new_regions = markEvents(testing, {'Blink', 'Muscle', 'Other'}, 256, regions)

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

    if nargin < 2
        help markEvents;
        return;
    end
    
    % use inputParser to evaluate validity of required inputs
    parser = inputParser;
    parser.addRequired('inputData', @(x)  ...
        (isstruct(x) && isfield(x, 'data') && ndims(x.data) == 2) || ...
        (ndims(inputData) == 2 && length(inputData) ~= 1)); %#ok<ISMAT>
    parser.addRequired('categories', @(x) ~isempty(x) && iscellstr(x));
    
    % use inputParser to evaluate validity of optional inputs
    parser.addParamValue('srate', 256, @(x) isnumeric(x) && x > 0);
    parser.addParamValue('event', [], @(x) isempty(x) || ...
        isstruct(x) && isfield(x, 'type') && isfield(x, 'latency'));
    parser.addParamValue('chanlocs', [], @(x) isstruct(x));
    parser.addParamValue('colors', [], @(x) isempty(x) || size(x, 2) == 3);
    parser.addParamValue('regions', [], @(x) iscellstr(x(:,1)) && size(x, 2) >= 3);

    % parse all the inputs
    parser.parse(inputData, categories, varargin{:});
    
    % further refinement of inputs depending on data input
    srate = parser.Results.srate;
    if isstruct(inputData) && isfield(inputData, 'srate') && ~isempty(inputData.srate)
        srate = inputData.srate;
    end
    
    events = parser.Results.event;
    if isempty(events) && isstruct(inputData) && ...
            isfield(inputData, 'event') && ~isempty(inputData.event)
        events = inputData.event;
    end
    
    chanlocs = parser.Results.chanlocs;
    if isempty(chanlocs) && isstruct(inputData) && ...
            isfield(inputData, 'chanlocs') && ~isempty(inputData.chanlocs)
        chanlocs = inputData.chanlocs;
    end

   
    % extracts data from inputData
    if isstruct(inputData) && isfield(inputData, 'data') && ...
            ndims(inputData.data) == 2 %#ok<ISMAT>
        data = inputData.data;
    elseif ndims(inputData) == 2 && ismatrix(inputData) %#ok<ISMAT>
        data = inputData;
    end

    % categories must be column
    if size(categories, 1) == 1 %#o%#ok<MSNU> k<ISROW>
        categories = categories';
    end
    
    regions = parser.Results.regions;
    colors = parser.Results.colors;
    if isempty(colors) || size(colors, 1) < length(categories)
       colors = jet(length(categories));
    end
    
    if isempty(regions)
        TMPREJ = [];        
    else % recreate new category list and new color list

        % If badChnList input not present, set the 4th column to empty.
        if size(regions, 2) ~= 4
            regions{1, 4} = [];
        end

        TMPREJ = zeros(size(regions, 1), size(data, 1) + 5);
        
        % new category set from union of previous and new categories
        categories = union(unique(regions(:,1)), categories)';
        colors = jet(length(categories));
        
        % re-check if color matrix size is less than new category list
        if size(colors, 1) < length(categories)
           colors = jet(length(categories));
        end

        [ignore1, ia , ic] = unique(regions(:,1)); %#ok<NASGU,ASGLU>
        % add in channel event labels (if labeling bad channels)
        for j = 1 : length(categories)
            t1 = find(strcmpi(regions(:,1), categories(j))==1);
            if ~isempty(t1)
                TMPREJ(t1, 1:5) = [cell2mat(regions(t1, 2:3))*srate repmat(colors(j, :), length(t1), 1)];
                if ~isempty(cell2mat(regions(t1, 4)))
                    TMPREJ(t1, cell2mat(regions(t1, 4)) + 5) = 1;
                end
            end
        end
    end

    % highlight the data
    command = '1';
    eegplot2(data, categories, colors, 'eloc_file', ...
        chanlocs, 'srate', srate, 'events', events, 'command', command, ...
        'winrej', TMPREJ, 'title', 'MarkEvents - GUI for Manual Marking');
    h = gcf; waitfor(h);

    % Grab EEGLAB's TMPREJ from global base space
    regions = evalin('base','TMPREJ');

    k = size(regions, 1);
    labelSet(k).type = [];
    labelSet(k).startTime = [];
    labelSet(k).endTime = [];

    for j = 1 : size(regions, 1)
        [c, ia, ib] = intersect(regions(j, 3:5), colors, 'rows'); %#ok<ASGLU>
        labelSet(j).type = char(categories(ib));
        labelSet(j).startTime = regions(j,1)/srate;
        labelSet(j).endTime  = regions(j,2)/srate;
        badChnList = find(regions(j,6 : end) == 1);
        if ~isempty(badChnList)
            labelSet(j).badChnList = badChnList;
        else
            labelSet(j).badChnList = [];
        end
    end

    labelSet = (squeeze(struct2cell(labelSet)))';
    [a,b] = sort(cell2mat(labelSet(:,2))); %#ok<ASGLU>
    labelSet = labelSet(b, :);
    evalin('caller', ['clear TMPREJ ans']);

    end

