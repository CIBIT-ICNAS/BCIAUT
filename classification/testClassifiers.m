function [ classifiers ] = testClassifiers( EEGtest, classifiers )
%CLASSIFY Summary of this function goes here
%   Detailed explanation goes here
    
    Test = dataset(EEGtest.features, EEGtest.isTarget);
    Test.prior = [(EEGtest.nElements - 1)/EEGtest.nElements  1 / EEGtest.nElements];
    EEGtest.isTarget = double(EEGtest.isTarget);
    
    for classifier = fieldnames(classifiers)'
        if ~startsWith(classifier{1}, 'wisard') && ~strcmp(classifier{1}, 'svm')
            W = classifiers.(classifier{1}).model;
            V = Test * W;
            classifiers.(classifier{1}).testMetrics = assessClassificationPerformance(EEGtest.isTarget, labeld(V), V.data(:,2), EEGtest.nElements);
        end
    end
    
    if isfield(classifiers, 'svm')
        [labels, scores] = classifiers.svm.model.predict(Test.data);
        classifiers.svm.testMetrics = assessClassificationPerformance(EEGtest.isTarget, double(labels), scores(:,2), EEGtest.nElements);
    end
    
    for nlevels = [5 10 15 30 50 100]
       featTest = binarizeFeatures(Test.data, 'thermometer', nlevels);

       for nbits = [2 4 8 16 32]
           model_name = sprintf('wisard_nb%d_nl%d', nbits, nlevels);
           if isfield(classifiers, model_name)
    
                W = classifiers.(model_name).model;
                [labels, scores] = W.predict(featTest);
                scores = scores(:, 2) - scores(:, 1);
                metrics = assessClassificationPerformance(EEGtest.isTarget, cell2mat(labels), scores, EEGtest.nElements);
                classifiers.(model_name).testMetrics = metrics;
           end
       end
       
    end

end

