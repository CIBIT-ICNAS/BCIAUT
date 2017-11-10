function [ featureVector, featureIdxs ] = extractFeatures( EEG, W1, W2, featureSelection )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Apply filters to get y and z
filtData = applyFilter(EEG.data, W1);

y = filtData(1, :, :);
z= applyFilter(filtData(2:end,:,:), W2(:,1));

featureVector = squeeze( cat(2, y, z) );

if ~isfield(featureSelection, 'featureIdxs')
    [R,pval] = corr(featureVector',EEG.isTarget);
    [~,I]=sort(R.^2,'descend');
    pval = pval(I);
    pOk = pval <= featureSelection.pvalThreshold;
 
    if sum(pOk) > featureSelection.minFeatures
        featureIdxs = I(pOk);
    else
        featureIdxs = I(1:featureSelection.minFeatures);
    end
else
    featureIdxs = featureSelection.featureIdxs;
end

featureVector = featureVector(featureIdxs,:)';

end