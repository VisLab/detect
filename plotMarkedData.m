function [] = plotMarkedData(inputData, regions, varargin)
%plotMarkedData     Plots the Marked data from markEvents
%
% Syntax: 
%   [] = plotMarkedData(inputData, regions)
%   [] = plotMarkedData(inputData, regions, varargin)
% 
%   [] = plotMarkedData(inputData, regions) opens a GUI for showing labeled
%   regions based on the input 'regions'. 'regions' can be from either
%   markEvents or plotLabeledData.
%
%   [] = plotMarkedData(inputData, regions, varargin) supplies additional
%   inputs as name-value pairs.
%
%   Input:
%      inputData      Either an EEG dataset containing 2D data or a 2D 
%                     matrix of size channels x frames.
%      regions        Previous output of markEvent or plotLabeledData
%
%  Optional parameters as name-value pairs:
%        'srate'      Sampling rate of the data, default is from EEG
%                     structure if input data is EEGLAB data, and 256 for 
%                     matrix data
%         'event'     A structure array with type and latency fields. If
%                     empty and inputData is a structure with a non-empty
%                     event field, the value of this field is used.
%      'chanlocs'     A structure array with a .labels fields. If
%                     empty and inputData is a structure with a non-empty
%                     chanlocs field, the value of this field is used.
%        'colors'     A nEvents x 3 array of custom-defined colors   

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

    % must have at least three arguments.
    if nargin < 2
        help plotMarkedData;
        return;
    end
    
    % use inputParser to evaluate validity of required inputs
    parser = inputParser;
    parser.addRequired('inputData', @(x)  ...
        (isstruct(x) && isfield(x, 'data') && ndims(x.data) == 2) || ...
        (ndims(inputData) == 2 && length(inputData) ~= 1));
    parser.addRequired('regions', @(x) ...
        ~isempty(x) && iscellstr(x(:,1)) && size(x, 2) >= 3);
    
    % use inputParser to evaluate validity of optional inputs
    parser.addParamValue('srate', 256, @(x) isnumeric(x) && x > 0);
    parser.addParamValue('event', [], @(x) isempty(x) || ...
        isstruct(x) && isfield(x, 'type') && isfield(x, 'latency'));
    parser.addParamValue('chanlocs', [], @(x) isstruct(x));
    parser.addParamValue('colors', [], @(x) isempty(x) || size(x, 2) == 3);

    % parse all the inputs
    parser.parse(inputData, regions, varargin{:});
    
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

    % Must have 2D data
    if isstruct(inputData) && isfield(inputData, 'data') && ...
            ndims(inputData.data) == 2 %#ok<ISMAT>
        data = inputData.data;
    elseif ndims(inputData) == 2 && ismatrix(inputData) %#ok<ISMAT>
        data = inputData;
    end

    % Check arguments
    categories = unique(regions(:,1));
    
    % Set 4th column to empty if not already present
    if size(regions, 2) ~= 4
        regions{1, 4} = [];
    end
        
    % sets the default when no events are provided
    TMPREJ = zeros(size(regions, 1), size(data, 1) + 5);
    categories = union(unique(regions(:,1)), categories)';
    colors = jet(length(categories));
    
    [categories, ia , ic] = unique(regions(:,1)); %#ok<NASGU,ASGLU>
    % add in channel event labels (if labeling bad channels)
    for j = 1 : length(categories)
        t1 = find(strcmpi(regions(:,1), categories(j))==1);
        if ~isempty(t1)
            TMPREJ(t1, 1:5) = [(cell2mat(regions(t1, 2:3)))*srate+1 repmat(colors(j, :), length(t1), 1)];
        end
        
        for K = 1 : length(t1)
            if ~isempty(cell2mat(regions(t1(K), 4)))
                TMPREJ(t1(K), cell2mat(regions(t1(K), 4)) + 5) = 1;
            end
        end    
    end
        
    command = '';
    % highlight the data 
    eegplot2(data, categories, colors, 'eloc_file', ...
        chanlocs, 'srate', srate, 'events', eventList, 'command', command, ...
        'winrej', TMPREJ, 'title', 'PlotMarkedData');
end

