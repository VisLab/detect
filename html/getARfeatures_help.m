%% getARfeatures
% Estimate autoregressive feature vectors for data
%
%% Syntax
%  featureVec = getARfeatures(data, modelOrder)
%  featureVec = getARfeatures(data, modelOrder, algorithm)
%
%% Description
% |featureVec = getARfeatures(data, modelOrder)| calculates the 
% autoregressive model coefficients of individual time windows for 
% each channel in |data|. If |data| is of size channels x windowSize x windows,
% the function computes windows features each of size channels times |modelOrder|.  
% The function returns an array with feature vectors in the rows for 
% input into LIBSVM.
%
% |featureVec = getARfeatures(..., algorithm)| specifies which algorithm
% to use for calculating the AR features. When |algorithm| is 1 (the
% default), the |getARfeatures| function uses the |arburg| function 
% which is part of the MATLAB signal processing toolbox. If |algorithm|
% is 2, |getARfeatures| uses |arfit2| which is part of the TSA toolbox
% included with this toolbox.
%
%% Example
% Create AR feature vectors using order two AR models for random data 
% with 64 channels:
   data = random('normal', 0, 1, [64, 1000, 10]);
   featureVec = getARfeatures(data, 2);

  
%%  Notes 
% The |arburg.m| function is part of the MATLAB signal processing
% toolbox. If you don't have that toolbox, use |arfit2.m|, which is part
% of TSA (Time Series Analysis) toolbox, which is distributed with this
% package.
%
%% 
% Copyright 2011-2013 Vernon Lawhern and Kay A. Robbins, University of Texas at San Antonio