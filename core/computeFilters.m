function [ W1, W2] = computeFilters( EEG, alpha, theta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% 1st step: Fisher Criteria
W1 = FC( EEG, theta );
EEG.data = applyFilter(EEG.data, W1);    
EEG.data(1, :, :) = [];

% 2nd step: Max SNR
W2 = maxSNR(EEG, alpha);

end