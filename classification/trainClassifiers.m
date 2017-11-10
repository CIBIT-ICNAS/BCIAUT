function [ r ] = trainClassifiers( EEGtrain, EEGvalidation, classifiers )
%CLASSIFY Summary of this function goes here
%   Detailed explanation goes here
    
    Train = dataset(EEGtrain.features, EEGtrain.isTarget);
    Test = dataset(EEGvalidation.features, EEGvalidation.isTarget);
    Train.prior = [(EEGtrain.nElements - 1)/EEGtrain.nElements  1 / EEGtrain.nElements];
    Test.prior = [(EEGvalidation.nElements - 1)/EEGvalidation.nElements  1 / EEGvalidation.nElements];
    
    
    EEGtrain.isTarget = double(EEGtrain.isTarget);
    EEGvalidation.isTarget = double(EEGvalidation.isTarget);
    
    r = struct();
    if cell2mat(intersect([{'svmp'} {'all'}], classifiers)) > 0
       W =  svc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.svmp = struct('model', W, 'metrics', metrics);
    end
    
    
    
    if cell2mat(intersect([{'svm'} {'all'}], classifiers)) > 0
        svm = fitcsvm(Train.data, Train.labels);
        [labels, scores] = svm.predict(Test.data);
        
        metrics = assessClassificationPerformance(EEGvalidation.isTarget, double(labels), scores(:,2), EEGvalidation.nElements);
        r.svm = struct('model', svm, 'metrics', metrics);
    end
    
    
    if cell2mat(intersect([{'svmh'} {'all'}], classifiers)) > 0
       W = svc(Train, 'h');
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.svmh = struct('model', W, 'metrics', metrics);
    end
    
    
    
    if cell2mat(intersect([{'fisher'} {'all'}], classifiers)) > 0
       W =  fisherc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.fisher = struct('model', W, 'metrics', metrics);       
    end
    
    if cell2mat(intersect([{'klld'} {'all'}], classifiers)) > 0
       W =  klldc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.klld = struct('model', W, 'metrics', metrics);
    end
    
    if cell2mat(intersect([{'pcld'} {'nall'}], classifiers)) > 0
       W =  pcldc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.pcld = struct('model', W, 'metrics', metrics);
       
    end
    
    if cell2mat(intersect([{'logl'} {'all'}], classifiers)) > 0
       W =  loglc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.loglc = struct('model', W, 'metrics', metrics);
       
    end

    if cell2mat(intersect([{'nm'} {'all'}], classifiers)) > 0
       W =  nmc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.nm = struct('model', W, 'metrics', metrics);       
    end

    if cell2mat(intersect([{'nms'} {'all'}], classifiers)) > 0
       W =  nmsc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.nms = struct('model', W, 'metrics', metrics);       
    end

    if cell2mat(intersect([{'perl'} {'all'}], classifiers)) > 0
       W =  perlc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.perl = struct('model', W, 'metrics', metrics);
       
    end
    
    if cell2mat(intersect([{'quadr'} {'all'}], classifiers)) > 0
       W =  quadrc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.quadr = struct('model', W, 'metrics', metrics);
       
    end

    
    if cell2mat(intersect([{'ld'} {'all'}], classifiers)) > 0
       W =  ldc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.ld = struct('model', W, 'metrics', metrics);
       
    end
    
    if cell2mat(intersect([{'qd'} {'all'}], classifiers)) > 0
       W =  qdc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.qd = struct('model', W, 'metrics', metrics);
       
    end
    
    if cell2mat(intersect([{'ud'} {'all'}], classifiers)) > 0
       W =  udc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.ud = struct('model', W, 'metrics', metrics);
       
    end
    
    
    if cell2mat(intersect([{'naiveb'} {'all'}], classifiers)) > 0
       W = naivebc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.naiveb = struct('model', W, 'metrics', metrics);
       
    end
    
    if cell2mat(intersect([{'parzen'} {'all'}], classifiers)) > 0
       W = parzenc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.parzen = struct('model', W, 'metrics', metrics);
       
    end
    
    if cell2mat(intersect([{'parzend'} {'all'}], classifiers)) > 0
       W = parzendc(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.parzend = struct('model', W, 'metrics', metrics);
       
    end
    
    
    if cell2mat(intersect([{'tree'} {'all'}], classifiers)) > 0
      try
       W = treec(Train);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.tree = struct('model', W, 'metrics', metrics);
       
      catch
          r.tree = struct('model', nan, 'metrics', nan);
      end
    end
    
    if cell2mat(intersect([{'knn'} {'all'}], classifiers)) > 0
       W =  knnc(Train, 5);
       V = Test * W;
       
       metrics = assessClassificationPerformance(EEGvalidation.isTarget, labeld(V), V.data(:,2), EEGvalidation.nElements);
       r.knn = struct('model', W, 'metrics', metrics);
       
    end
    
    
%     if cell2mat(intersect([{'neur'} {'all'}], classifiers)) > 0
%        W = neurc(Train);
%        V = Test * W;
%        
%        cm = confmat(getlabels(Test), labeld(V));
%        
%        cfm = zeros(2);
%        cfm(cm~=0) = cm(cm~=0);
%        
%        r.neur = getResults(cfm, 'neur', 1);       
%        
%     end
%     
    
%     if cell2mat(intersect([{'bpxn'} {'all'}], classifiers)) > 0
%        W = bpxnc(Train);
%        V = Test * W;
%        
%        cm = confmat(getlabels(Test), labeld(V));
%        
%        cfm = zeros(2);
%        cfm(cm~=0) = cm(cm~=0);
%        
%        r.bpxn = getResults(cfm, 'bpxn', 1);       
%        
%     end
    
%     if cell2mat(intersect([{'rnn'} {'all'}], classifiers)) > 0
%        W = rnnc(Train);
%        V = Test * W;
%        
%        cm = confmat(getlabels(Test), labeld(V));
%        
%        cfm = zeros(2);
%        cfm(cm~=0) = cm(cm~=0);
%        
%        r.rnn = getResults(cfm, 'rnn', 1);       
%        
%     end
    

    if cell2mat(intersect([{'wisard'} {'all'}], classifiers)) > 0
       for nlevels = [5 10 15 30 50 100]
           featTrain = binarizeFeatures(Train.data, 'thermometer', nlevels);
           featTest = binarizeFeatures(Test.data, 'thermometer', nlevels);
           
           for nbits = [2 4 8 16 32]
                
                W = WiSARD(num2cell([0 1]), size(featTrain, 2), nbits);
                W.fit(featTrain, num2cell(Train.labels));
                [labels, scores] = W.predict(featTest);
                scores = scores(:, 2) - scores(:, 1);
                metrics = assessClassificationPerformance(EEGvalidation.isTarget, cell2mat(labels), scores, EEGvalidation.nElements);
                r.(sprintf('wisard_nb%d_nl%d', nbits, nlevels)) = struct('model', W, 'metrics', metrics);
           end
       end
       
       
       
    end



end

