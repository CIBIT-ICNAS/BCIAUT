function  printClassifiersPerformance( classifiers )
%PRINTCLASSIFIERSPERFORMANCE Summary of this function goes here
%   Detailed explanation goes here
    for classifier = fieldnames(classifiers)'
        fprintf('%s: %.2f |', classifier{1}, classifiers.(classifier{1}).metrics.accuracy);
        if isfield(classifiers.(classifier{1}), 'testMetrics')
            fprintf(' %.2f', classifiers.(classifier{1}).testMetrics.accuracy);
        end
        fprintf('\n');
    end

end

