function [session_models] = computeNewModels(configs, base_models, classifiers_list, verbose)
%COMPUTENEWMODELS Run other classifiers in subject data for different average trials
%   Loads EEG data (train, validation and test) and uses base model parameters to train
%   new classifiers.
%
%   Input:
%   configs             - structure containing experimental parametets, including subject 
%                           and session (see getConfigs)
%   base_models         - cell array containing base_models for this subject and session 
%   classifiers_list    - cell array with classifiers name to use or 'all' (default)
%   verbose             - boolean to print or not classifier performance (default 0)
%
%   Output:
%   session_models      - cell array containing new models and their performance 
%                           computed for this subject and session 


if nargin < 4
    verbose = 0;
end
if nargin < 3
    classifiers_list = {'all'};
end

        
% load data
EEG_T1 = loadEEGData(configs, 'Train1', 0, 1);
EEG_T2 = loadEEGData(configs, 'Train2', 0, 1);
EEG_BCI = loadEEGData(configs, 'BCI', 0, 1);

session_models = cell(1, configs.NAVGS);

for avg = 1:configs.NAVGS
    
    model = base_models{avg};

    % average and normalize
    EEG_T1_avg = averageTrials(EEG_T1, avg);
    EEG_T1_zscored = normalizeTrials(EEG_T1_avg, 'zscore');

    EEG_T2_avg = averageTrials(EEG_T2, avg);
    EEG_T2_zscored = normalizeTrials(EEG_T2_avg, 'zscore');
    
    % extract features
    [EEG_T1_zscored.features, ~] = extractFeatures(EEG_T1_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
    [EEG_T2_zscored.features, ~] = extractFeatures(EEG_T2_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
    
    % train classifiers
    classifiers = trainClassifiers(EEG_T1_zscored, EEG_T2_zscored, classifiers_list, configs);
    
    % test classifier in avg trials available
    if avg <= EEG_BCI.nTrials
        EEG_BCI_avg = averageTrials(EEG_BCI, avg);
        EEG_BCI_zscored = normalizeTrials(EEG_BCI_avg, 'zscore');
        [EEG_BCI_zscored.features, ~] = extractFeatures(EEG_BCI_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
        
        classifiers = testClassifiers(EEG_BCI_zscored, classifiers, configs);
    end
    
    if verbose
        fprintf('[%d] subject: %s | session: %d\n', avg, configs.subject , configs.session); 
        printClassifiersPerformance( classifiers );
    end
    session_models{avg} = classifiers;
    
end        


