% This script performs a comparison analysis of several classifiers for
% P300 classification in BCIAUT clinical trial data
%
% November 2017
% Creator Marco Simoes (msimoes@dei.uc.pt) & Carlos Amaral
%
% All rights reverved

% setup path
addpath('analysis', 'classification', 'core', 'imports', 'metrics', 'utils', 'classification/wisard');

DATAPATH = '../../BCIAUT_Data/';

% use configs structure to store configurations needed in the analysis
configs = struct();

% define aquisition configs
configs.nChannels = 8;
configs.nElements = 8;
configs.nTrials = 10;
configs.srate = 250;
configs.NSESSIONS = 7;
configs.NAVGS = 10;

%% run other classifiers

% load trained models
load('results/base_models.mat');
base_models = models;

subject_list = shuffle([1 3:8 10:17]);

for SUBJECT = subject_list
    for SESSION = 1:configs.NSESSIONS
        
        % define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', DATAPATH,SUBJECT, SESSION);
        tic
        
        % load data
        EEG_T1 = loadEEGData(configs, 'Train1', 0, 1);
        EEG_T2 = loadEEGData(configs, 'Train2', 0, 1);
        EEG_BCI = loadEEGData(configs, 'BCI', 0, 1);
        session_models = base_models.(sprintf('s%02d', SUBJECT)){SESSION};
        for avg = 1:configs.NAVGS
            fprintf('[%d] subject: %d | session: %d\n', avg, SUBJECT , SESSION); 
            
            if exist(sprintf('results/subject%02d_session%d_avg%d.mat', SUBJECT, SESSION, avg))
                continue
            end
            
            model = session_models{avg};
            
            EEG_T1_avg = averageTrials(EEG_T1, avg);
            EEG_T1_zscored = normalizeTrials(EEG_T1_avg, 'zscore');

            EEG_T2_avg = averageTrials(EEG_T2, avg);
            EEG_T2_zscored = normalizeTrials(EEG_T2_avg, 'zscore');
            
            [EEG_T1_zscored.features, ~] = extractFeatures(EEG_T1_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
            [EEG_T2_zscored.features, ~] = extractFeatures(EEG_T2_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
            classifiers = trainClassifiers(EEG_T1_zscored, EEG_T2_zscored, {'all'});
            
            % test classifier in avg trials available
            if avg <= EEG_BCI.nTrials
                EEG_BCI_avg = averageTrials(EEG_BCI, avg);
                EEG_BCI_zscored = normalizeTrials(EEG_BCI_avg, 'zscore');
                [EEG_BCI_zscored.features, ~] = extractFeatures(EEG_BCI_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
                
                classifiers = testClassifiers(EEG_BCI_zscored, classifiers);
            end
            
            printClassifiersPerformance( classifiers );
            models = classifiers;
            save(sprintf('results/subject%02d_session%d_avg%d.mat', SUBJECT, SESSION, avg), 'models');
        end        
        toc
    end
end


