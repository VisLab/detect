function featureVec = getARfeatures(data, modelOrder, algorithm)
% getARfeatures  estimate autoregressive feature vectors for data
%
% Syntax:
%  featureVec = getARfeatures(data, modelOrder)
%  featureVec = getARfeatures(data, modelOrder, algorithm)
%
% Description:
%  The getARfeatures function calculates the autoregressive model 
%  coefficients of individual time windows for each channel in data 
%  to create feature vectors of length channels*modelOrder. 
%  The function returns an array with feature vectors in the rows for 
%  input into LIBSVM.
%
%  Input:
%         data     3-D matrix of size channels x windowSize x windows
%   modelorder     Order of the autoregressive model to fit
%    algorithm     (optional) Indicator of which AR model algorithm to use
%                  1 - arburg.m (default), 2 - arfit2.m
%
%  Output:
%     featureVec     2-D array of size windows x featureSize 
%                  (featureVec is of size channels * modelOrder)    
%       
% Example:
% Create AR feature vectors using order two AR models for random data 
% with 64 channels:
%   data = random('normal', 0, 1, [64, 1000, 10]);
%   featureVec = getARfeatures(data, 2);
%
%                
%  Note: The arburg.m function is part of the MATLAB signal processing
%  toolbox. If you don't have that toolbox, use arfit2.m, which is part
%  of TSA (Time Series Analysis) toolbox, which is distributed with this
%  package.

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

if nargin < 2
    help getARfeatures;
    return;
elseif nargin == 2 % default algorithm to use is arburg.m
    algorithm = 1;
end

[channels, frames, windows] = size(data); %#ok<ASGLU>
A = zeros(modelOrder, channels, windows); % Preallocate 3D matrix for AR coefficients

switch algorithm
    case 1 % Use arburg - remove mean before fit, ignore intercept temp1 (SP toolbox)
        for i = 1:channels
            for j = 1:windows
                temp1 = arburg(data(i, :, j) - mean(data(i, :, j)), modelOrder);
                A(:, i, j) = temp1(2:end)';
            end
        end
    case 2  % Use arfit2, which removes the mean during the computation (TSA)
        for i = 1:channels
            for j = 1:windows
                [ignore, coeffs] = arfit2(data(i, :, j)', modelOrder, modelOrder); %#ok<ASGLU>
                A(:, i, j) = coeffs';
            end
        end
    otherwise
        error('Detect:getARfeatures', 'Unable to find AR model algorithm');       
end

% Features must be (windows x features) for LibSVM  
featureVec = reshape(A, channels*modelOrder, windows)';
end % getARFeatures

