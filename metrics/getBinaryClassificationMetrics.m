function [ r ] = getBinaryClassificationMetrics( CM, name, verbose )
%GETCLASSIFICATIONMETRICS Creates a result structure based on the confusion matrix
%   Receives the confusion matrix, a name and a verbose flag. Returns a
%   struct with several metrics:
%   'TP'    True Positives
%   'TN'    True Negatives
%   'FP'    False Positives
%   'FN'    False Negatives
%   'SN'    Sensitivity TP/(TP+FN)
%   'SP'    Specificity TN/(TN+FP)
%   'TPR'   True Positive Rate == Sensitivity
%   'TNR'   True Negative Rate == Specificity
%   'FPR'   False Positive Rate FP/(FP+TN)
%   'PPV'   Positive Predictive Value TP/(TP+FP)
%   'FDR'   False Discovery Rate FP/(FP+TP)
%   'RC'    Recall == Sensitivity
%   'ACC'   Accuracy (TP+TN)/(TP+TN+FP+FN)
%   'E'     Error 1-ACC

    if nargin < 3
        verbose = 0;
    end
    if nargin < 2
        name = '- Not Provided -';
    end
    
    P = 2; N = 1;
    
    r = struct();
    r.NAME = name;
    
    r.TP = CM(P,P); r.TN = CM(N,N); r.FP = CM(N,P); r.FN = CM(P,N);
    
    r.SN = r.TP/(r.TP+r.FN);
    r.TPR = r.SN;
    r.RC = r.SN;
    
    r.SP = r.TN/(r.TN+r.FP);    
    r.TNR = r.SP;
    
    r.FPR = r.FP/(r.FP+r.TN);
    r.PPV = r.TP/(r.TP+r.FP);
    r.FDR = r.FP/(r.FP+r.TP);
    
    r.ACC = (r.TP+r.TN)/(r.TP+r.TN+r.FP+r.FN);
    r.E = 1-r.ACC;
    r.BACC = (r.SP + r.SN)/2;
    
    if verbose
        fprintf('Classifier: %s\n - BAcc: %f\n - Acc: %f\n - SN: %f\n - SP: %f\n', r.NAME, r.BACC, r.ACC, r.SN, r.SP);
    end

end