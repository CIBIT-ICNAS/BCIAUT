function [ model ] = findBestModel( EEG_train, EEG_validation, alphas, thetas )

step = 0.01;
if nargin < 4
    thetas = [step:step:0.1 0.8+step:step:1];
end
if nargin < 3
    alphas = [step:step:0.1 0.8+step:step:1];
end

bestMetric = 0;
model = struct();

for alpha = alphas
    for theta = thetas
        % perform feature extraction (filters, extract on training, extract on validation)
        [W1, W2] = computeFilters(EEG_train, alpha, theta);
        [EEG_train.features, EEG_train.featureIdxs] = extractFeatures(EEG_train, W1, W2, struct('pvalThreshold', 0.01, 'minFeatures', 40));
        [EEG_validation.features, EEG_validation.featureIdxs] = extractFeatures(EEG_validation, W1, W2, struct('featureIdxs', EEG_train.featureIdxs));

        % train classifer and validate it
        nbc = fitcnb(EEG_train.features, EEG_train.isTarget);
        [labels, predictionProbabilities, ~] = nbc.predict(EEG_validation.features);

        % assess classifer performance
        metrics = assessClassificationPerformance(EEG_validation.isTarget, labels, predictionProbabilities(:,2), EEG_validation.nElements); 
        
        % if better than current best update
        if metrics.accuracy > bestMetric
            bestMetric = metrics.accuracy;
            model.W1 = W1; model.W2 = W2;
            model.featureIdxs = EEG_train.featureIdxs;
            model.alpha = alpha; model.theta = theta;
            model.classifier = nbc;
            model.metrics = metrics;
        end
   end
end



end

