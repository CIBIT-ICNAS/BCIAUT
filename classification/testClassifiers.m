function [ classifiers ] = testClassifiers( EEGtest, classifiers, configs )
%TESTCLASSIFIERS Runs the EEG test through the classifiers
%   For each classifier provided, computes the accuracy metrics for the
%   EEGtest dataset
%
%   Inputs:
%   EEGtest     - EEG structure to classify
%   classifiers - Structure with classifier models computed with trainClassifiers
%   configs     - Additional configurations for classifiers, if needed
    
    Test = prdataset(EEGtest.features, EEGtest.isTarget);
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
    
    for nlevels = configs.WISARD.nlevels
       featTest = WiSARD.binarizeData(Test.data, 'thermometer', nlevels);

       for nbits = configs.WISARD.nbits
           model_name = sprintf('wisard_nb_%d_nl_%d_th_0', nbits, nlevels);
           if isfield(classifiers, model_name)
    
                W = classifiers.(model_name).model;
                [~, ~, counts] = W.predict(featTest);
               
               for threshold = configs.WISARD.thresholds
                   model_name = sprintf('wisard_nb_%d_nl_%d_th_%d', nbits, nlevels, floor(threshold * 100));
                   [labels, scores] = W.bleach(counts, threshold);
                   scores = scores(:, 2) - scores(:, 1);
                   metrics = assessClassificationPerformance(EEGtest.isTarget, cell2mat(labels), scores, EEGtest.nElements);
                   classifiers.(model_name).testMetrics = metrics;
               end
                
                
           end
           
           % no zeros
           model_name = sprintf('wisard_nb_%d_nl_%d_th_0_nozeros', nbits, nlevels);
           if isfield(classifiers, model_name)
    
                W = classifiers.(model_name).model;
                [~, ~, counts] = W.predict(featTest);
               
               for threshold = configs.WISARD.thresholds
                   model_name = sprintf('wisard_nb_%d_nl_%d_th_%d_nozeros', nbits, nlevels, floor(threshold * 100));
                   [labels, scores] = W.bleach(counts, threshold);
                   scores = scores(:, 2) - scores(:, 1);
                   metrics = assessClassificationPerformance(EEGtest.isTarget, cell2mat(labels), scores, EEGtest.nElements);
                   classifiers.(model_name).testMetrics = metrics;
               end
                
                
           end
       end
       
    end

end

