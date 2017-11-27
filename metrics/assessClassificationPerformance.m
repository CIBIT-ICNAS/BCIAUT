function results = assessClassificationPerformance(labels, predictedLabels, predictionValues, nElements)

    results = struct();
    
    % binary performance
    cm = confusionmat(labels, predictedLabels);
    results.binaryMetrics = getBinaryClassificationMetrics(cm);
    
    
    if nargin > 2 % run performance
        correctPredictions = nan(fix(length(labels) / nElements), 1);
        for k=1:length(correctPredictions)
            runIdxs = (k-1)*nElements+1 : k*nElements;
            [~, prediction] = max( predictionValues( runIdxs ) );
            correctPredictions(k) = prediction == find( labels( runIdxs ) == 1 );
        end

        % gather run results
        results.accuracy = sum(correctPredictions) / length(correctPredictions) + rand()*1E-6;
        results.error = 1-results.accuracy;
    end
end
