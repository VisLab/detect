function [dataWindows, labels] = getLabels(inputData, categories, windowLength, varargin)
%getLabels   creates a windowed dataset from highlighted data segments
%
% Syntax:
%   [dataWindows, labels] = getLabels(inputData, categories, windowLength)
%   [dataWindows, labels] = getLabels(inputData, categories, windowLength, varargin)
%
%   [dataWindows, labels] = getLabels(inputData, categories, windowLength) 
%   returns a windowed dataset and a new labels vector that can be used
%   with getModel to train a model for continuous decoding of events.
%
%   [dataWindows, labels] = getLabels(..., varargin) supplies additional
%   parameters as name-value pairs.
%   
%
% Input:
%   inputData      Either a 2D data array of size (channels x frames) or
%                  a structure with a .data field containing 2D data.
%  categories      A cell array of strings specifying the categories used 
%                  to tag the data. Each category value will have its
%                  own button on the toolbar for easy highlighting of 
%                  events.
% windowLength     The length of a window in seconds for training
%                  (see notes). 
%
% Optional parameters as name-value pairs:
%    
%      'srate'     Sampling rate of the data in Hz. If omitted and
%                  inputData is a structure with a non-empty srate field,
%                  that value is used. Otherwise a default value of
%                  256 Hz is used.
%      'event'     A structure array with type and latency fields. If
%                  empty and inputData is a structure with a non-empty
%                  event field, the value of this field is used.
%   'chanlocs'     A structure array with xxx fields. If
%                  empty and inputData is a structure with a non-empty
%                  chanlocs field, the value of this field is used.
%     'colors'     An n x 3 array of colors. If n is less than the
%                  length of categories, the jet color map is used.
%
% Output:
%   dataWindows    Either a structure with windowed data, or a 3D
%                  matrix. If the original input data was a structure,
%                  the output will be a copy of the structure with the
%                  .data field replaced. If the input data
%                  is a 2D matrix, a 3D matrix of size (channels x
%                  windowSize x windows) is returned. 
%                  The length of a window is defined by windowLength.
%      labels      A cell array of strings containing the label identifier
%                  for each trial. 
%
% Notes:
%
%    While getLabels allows you to highlight regions of any size,
%    it will re-align the highlighted sections so that they are exactly the
%    size of windowLength from the user input. The features that we are
%    extracting all assume that the length of data is the same for every
%    condition.
%
%    The EEGLAB EEG structure may be passed as inputData.
%
% Example: Extract 1/2 second training epochs labeled 'None' and 'Blink'
% using an EEGLAB EEG dataset. 
%    
%   EEG = pop_loadset('data/testing.set');
%   [dataWindows, labels] = getLabels(EEG, {'None', 'Blink'}, 0.5, 'srate', 256)
%
% In this example, we assume that we have continuous data already loaded
% into EEGLAB. We are only tagging data that has blinks or no blinks
% (labeled as 'None'). We want epochs to be of length 500 ms (.5
% seconds). The function only has 3 inputs, so it will pull in the 
% sampling rate (srate), the event info (eventList) and the channel 
% locations (chanlocs) from the EEG structure. 

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
 
    if nargin < 3
        help getLabels;
        return;
    end
    
    % use inputParser to evaluate validity of required inputs
    parser = inputParser;
    parser.addRequired('inputData', @(x)  ...
        (isstruct(x) && isfield(x, 'data') && ndims(x.data) == 2) || ...
        (ndims(inputData) == 2 && length(inputData) ~= 1)); %#ok<ISMAT>
    parser.addRequired('categories', @(x) ~isempty(x) && iscellstr(x));
    parser.addRequired('windowLength', @(x) isnumeric(x) && x > 0); 
    
    % use inputParser to evaluate validity of optional inputs
    parser.addParamValue('srate', 256, @(x) isnumeric(x) && x > 0);
    parser.addParamValue('event', [], @(x) isempty(x) || ...
        isstruct(x) && isfield(x, 'type') && isfield(x, 'latency'));
    parser.addParamValue('chanlocs', [], @(x) isstruct(x));
    parser.addParamValue('colors', [], @(x) isempty(x) || size(x, 2) == 3);
    
    % parse all the inputs
    parser.parse(inputData, categories, windowLength, varargin{:});
    
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
    
   colors = parser.Results.colors;
   if isempty(colors) || size(colors, 1) < length(categories)
        colors = jet(length(categories));
   end
   
   % categories must be a column vector
   if size(categories, 1) == 1
       categories = categories';
   end
   
     % gets data type.
    if (isstruct(inputData) && isfield(inputData, 'data') && ndims(inputData.data) == 2) %#ok<ISMAT>
        fileType = 1;
        data = inputData.data; clear temp1;
    else
        fileType = 2;
        data = inputData;
    end
    
   % Bring up the GUI
    clc;
    command = 'fprintf(''\n'');';
    eegplot2(data, categories, colors, 'eloc_file', ...
        chanlocs, 'events', eventList, 'srate', srate, 'title', ...
        'getLabels - Highlight Event Information', 'command', command, 'butlabel', 'Continue');

    h = gcf;
    % Wait for figure to close before continuing
    waitfor(h);
    
    % Grab EEGLAB's TMPREJ from global base space and use it to adjust epochs.
    temp1 = evalin('base', 'TMPREJ');
    temp1(:, 2) = temp1(:, 1) + floor(windowLength*srate);

    clc;
    % second round verifies that sections are sufficient
    fprintf('\n');
    fprintf('Adjusting event timings for the desired event length of %4.3f seconds \n', windowLength);
    eegplot2(data, categories, colors, 'srate', srate, 'events', eventList,...
        'eloc_file', chanlocs, 'title', ...
        'getLabels - Highlight Event Information', ...
        'butlabel','CLOSE', 'command', [], ...
        'winrej', temp1);
    fprintf('\n');
    user_entry = input('\nDo you want to: \n  1. save this labeling(s), \n  2. continue labeling(c), or \n  3. quit without saving(q)? [s/c/q]: ','s');

    % this exits the function (Change in a later version)
    if user_entry == 'q'
        evalin('caller', ('clear TMPREJ'));
        error('Quitting function...')
    end
    
    while user_entry == 'c';
        h = gcf; close(h); clc;
        eegplot2(data, categories, colors, 'eloc_file', ...
            chanlocs, 'events', eventList, 'srate', srate, 'title', ...
            'getLabels - Highlight Event Information',...
            'command', command, 'butlabel', 'Continue', 'winrej', temp1);
        fprintf('\n');
        fprintf('Add in new events using the highlighting function in eegplot\n');
        fprintf('Press "Continue" when finished.\n');
        fprintf('\n');
        h = gcf;
        % pauses the code while the figure is open, allows for highlighting
        waitfor(h);

        temp1 = evalin('base', 'TMPREJ');
        temp1(:, 2) = temp1(:, 1) + windowLength*srate;  
        
        clc;
        eegplot2(data, categories, colors, 'eloc_file', chanlocs,...
            'srate', srate, 'events', eventList,'title', ...
            'getLabels - Highlight Event Information', 'command', [], ...
            'winrej',temp1);
        fprintf('Adjusting event timings for the desired event length of %4.3f seconds \n', windowLength);
        user_entry = input('\nDo you want to: \n  1. save this labeling(s), \n  2. continue labeling(c), or \n  3. quit without saving(q)? [s/c/q]: ','s');
        if user_entry == 'q'
            error('Quitting function...');
        end
    end;
    % First 5 columns are [start end rgb(1) rgb(2) rgb(3)]
    events = temp1(:, 1:5); 

    % fileType is 2D data, fill in empty EEG structure with fields to epoch
    if fileType == 2
        dataWindows = eeg_emptyset;
        dataWindows.data = data;
        dataWindows.srate = srate;
        dataWindows.nbchan = size(inputData, 1);
        eCount = 1; % event counter
        for i = 1:size(categories,1)
            % Find the indices that have the same color
            temp2 = find(ismember(events(:, 3:5), colors(i, :), 'rows'));
            [numEvents ignore1] = size(temp2); %#ok<NASGU>
            if ~isempty(temp2)
                for K = 1 : numEvents
                    dataWindows.event(eCount).type = categories{i};
                    dataWindows.event(eCount).latency = events(temp2(K), 1);
                    eCount = eCount + 1;
                end
            end
        end  
    % filetype is EEG, so set events empty and create new events field
    elseif fileType == 1
        dataWindows = inputData;
        dataWindows.event = [];
        dataWindows.urevent = [];
        eCount = 1; % event counter
        for i = 1:size(categories,1)
            % Find the indices that have the same color
            temp2 = find(ismember(events(:, 3:5), colors(i, :), 'rows'));
            [numEvents ignore1] = size(temp2); %#ok<NASGU>
            if ~isempty(temp2)
                for K = 1 : numEvents
                    dataWindows.event(eCount).type = categories{i};
                    dataWindows.event(eCount).latency = events(temp2(K), 1);
                    eCount = eCount + 1;
                end
            end
        end
    end
    
    % Epoch new EEG structure around new events before resetting events to original
    dataWindows = pop_epoch(dataWindows, categories, [0 windowLength], 'newname', ...
                     'BDF file epochs', 'epochinfo', 'yes');

    % Epochs may contain more than one event -- extract the first event
    labels = firstElement(dataWindows);

    % convert data back to original input type before outputting
    if fileType == 2
        dataWindows = dataWindows.data;
    elseif fileType ==1
        dataWindows.urevent = inputData.urevent;
    end
    % remove TMPREJ from global space before exiting function
    evalin('caller', ('clear TMPREJ'));

end %end getLabels

function result = firstElement(EEG)
% Extract first element of a cell array of strings from EEG.epoch.eventtype
    data = {EEG.epoch.eventtype};
    if isvector(data) && size(data, 1) == 1 %#ok<ISROW> %Make sure is a column
        data = data';
    end

    a = size(data, 1);
    result = cell(a, 1);
    for i = 1:a
        result{i} = (data{i});
    end
    result = cellfun(@char, result, 'UniformOutput', 0); % Convert to char
end % firstElement
