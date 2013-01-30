function [outEEG] = removeEvent(inEEG, events, removeLabels)
%removeEvent        Removes previously marked data. 
%
%  Inputs:
%      inEEG        EEG structure from EEGLAB EEG dataset
%     events        previously highlighted data from markEvent
% removeLabels      cell array of strings to denote which labels you want 
%                   to remove from the data
%
%  Outputs:
%  outEEG           EEG structure with removed data. Boundary events are
%                   inserted where the removed data was located
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

    % Check arguments
    if ~isstruct(inEEG)
        error('Input data must be an EEG structure');
    elseif ndims(inEEG.data) ~= 2 %#ok<ISMAT>
        error('EEG data is not in continuous format');
    end
    
    if nargin == 2
        removeLabels = [];
    end
    
    if ~isempty(removeLabels)
        index = zeros(size(events, 1), 1);
        for i = 1 : length(removeLabels)
            index = index + strcmpi(events(:,1), removeLabels{1});
        end
        times = (cell2mat(events(logical(index), 2:3))*inEEG.srate);
    else
        times = (cell2mat(events(:, 2:3))*inEEG.srate);
    end
    
    outEEG = eeg_eegrej(inEEG, times);
%     outEEG = eeg_checkset(outEEG);
    
    pop_saveset(outEEG);
    

end

