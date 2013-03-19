function featureVec = getKurtosis(data)
% getKurtosis  calculates kurtosis feature vector for data
%
% Syntax:
%  featureVec = getKurtosis(data)
%
%  Input:
%          data      3-D matrix of size channels x windowSize x windows or
%                    a 2-D matrix of size channels x windowSize 
%
%  Output:
%     featureVec     2-D matrix of size windows x featureSize 
%                    (featureVec is of size channels)    
%
%  Example:
%
%     simulate data with 64 channels, 1000 time points and 10 windows
%     the output will be size 10 x 64 (64 kurtosis values for each window.
%     data = randn(64, 1000, 10); 
%     featureVec = getKurtosis(data);

%   Copyright (C) 2013  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
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

featureVec = (squeeze(kurtosis(data, [], 2)))';

end % getARFeatures

