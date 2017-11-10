% This script performs a comparison analysis of several classifiers for
% P300 classification in BCIAUT clinical trial data
%
% November 2017
% Creator Marco Simoes (msimoes@dei.uc.pt)
%
% All rights reverved

% setup path
addpath('utils', 'wisard');

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


%% Compute and validate trainig model and filters

models = struct();
load('base_models.mat');

for SUBJECT = [1 3:8 10:17]
    if ~isfield(models, sprintf('s%02d',SUBJECT))
        models.(sprintf('s%02d',SUBJECT)) = cell(1, configs.NSESSIONS);
    end
    
    for SESSION = 1:configs.NSESSIONS
        fprintf('subject: %d | session: %d\n', SUBJECT , SESSION); 
        
        if ~isempty( models.(sprintf('s%02d',SUBJECT)){SESSION} )
            continue
        end
        
        sessionMetrics = cell(1, configs.NAVGS);
        % define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', DATAPATH,SUBJECT, SESSION);
        tic
        
        % load data
        EEG_T1 = loadEEGData(configs, 'Train1', 0, 1);
        EEG_T2 = loadEEGData(configs, 'Train2', 0, 1);
        parfor avg = 1:configs.NAVGS
            EEG_T1_avg = averageTrials(EEG_T1, avg);
            EEG_T1_zscored = normalizeTrials(EEG_T1_avg, 'zscore');

            EEG_T2_avg = averageTrials(EEG_T2, avg);
            EEG_T2_zscored = normalizeTrials(EEG_T2_avg, 'zscore');
            
            model_zscored = findBestModel(EEG_T1_zscored, EEG_T2_zscored);
            
            fprintf('[%d] raw_zscored: %.2f\n', avg, model_zscored.metrics.accuracy);
            sessionMetrics{avg} = model_zscored;
        end
        models.(sprintf('s%02d',SUBJECT)){SESSION} = sessionMetrics;
        save('base_models.mat', 'models');
        toc
    end
end


%% run other classifiers
% 
% % load trained models
% load('base_models.mat');
% base_models = models;
% 
% for SUBJECT = [1 3:8 10:17]
%     for SESSION = 1:configs.NSESSIONS
%         fprintf('subject: %d | session: %d\n', SUBJECT , SESSION); 
%         sessionMetrics = cell(1, configs.NAVGS);
% 
%         % define subject configs
%         configs.subject = SUBJECT;
%         configs.session = SESSION;
%         configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', DATAPATH,SUBJECT, SESSION);
%         tic
%         
%         % load data
%         EEG_T1 = loadEEGData(configs, 'Train1', 0, 1);
%         EEG_T2 = loadEEGData(configs, 'Train2', 0, 1);
%         session_models = base_models.(sprintf('s%02d', SUBJECT)){SESSION};
%         parfor avg = 1:configs.NAVGS
%             
%             model = session_models{avg};
%             
%             EEG_T1_avg = averageTrials(EEG_T1, avg);
%             EEG_T1_zscored = normalizeTrials(EEG_T1_avg, 'zscore');
% 
%             EEG_T2_avg = averageTrials(EEG_T2, avg);
%             EEG_T2_zscored = normalizeTrials(EEG_T2_avg, 'zscore');
%             
%             [EEG_T1_zscored.features, ~] = extractFeatures(EEG_T1_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
%             [EEG_T2_zscored.features, ~] = extractFeatures(EEG_T2_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
%             classifiers = trainClassifiers(EEG_T1_zscored, EEG_T1_zscored, {'all'});
%             for classifier = fieldnames(classifiers)'
%                 fprintf('[%d] %s: %.2f\n', avg, classifier{1}, classifiers.(classifier{1}).metrics.accuracy);
%             end
%             sessionMetrics{avg} = classifiers;
%         end
%         for avg=1:configs.NAVGS
%             models = sessionMetrics{avg};
%             save(sprintf('results/subject%02d_session%d_avg%d.mat', SUBJECT, SESSION, avg), 'models');
%         end
%         toc
%     end
% end
% 
% 

%% Test all classifiers
% 
% % load trained models
% load('base_models.mat');
% base_models = models;
% 
% 
% metrics = struct();
% for SUBJECT = [1 3:8 10:17]
%     metrics.(sprintf('s%02d',SUBJECT)) = cell(1, configs.NSESSIONS);
%     for SESSION = 1:configs.NSESSIONS
%         fprintf('subject: %d | session: %d\n', SUBJECT , SESSION); 
%         % define subject configs
%         configs.subject = SUBJECT;
%         configs.session = SESSION;
%         configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', DATAPATH,SUBJECT, SESSION);
%         
%         tic
%         
%         % load data
%         EEG_BCI = loadEEGData(configs, 'BCI', 0, 1);
%         sessionMetrics = cell(1, EEG_BCI.nTrials);        
%         
%         for avg = 1:EEG_BCI.nTrials
%             
%             % get base model
%             model = base_models.(sprintf('s%02d', SUBJECT)){SESSION}{avg};
%             
%             EEG_BCI_avg = averageTrials(EEG_BCI, avg);
%             EEG_BCI_zscored = normalizeTrials(EEG_BCI_avg, 'zscore');
% 
%             [EEG_BCI_zscored.features, ~] = extractFeatures(EEG_BCI_zscored, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
%             
%             % 1st test base model
% %             [labels, predictionProbabilities, ~] = model.classifier.predict(EEG_BCI_zscored.features);
% %             metrics = assessClassificationPerformance(EEG_BCI_zscored.isTarget, labels, predictionProbabilities(:,2), EEG_BCI_zscored.nElements);
%           
%             load(sprintf('results/subject%02d_session%d_avg%d.mat', SUBJECT, SESSION, avg));
%             
%             % 2nd test all classifiers
%             results = testClassifiers(EEG_BCI_zscored, models);
% %             results.base = struct('model', model, 'metrics', metrics);
%             for classifier = fieldnames(results)'
%                 fprintf('[%d] %s: %.2f\n', avg, classifier{1}, results.(classifier{1}).metrics.accuracy);
%             end
%             sessionMetrics{avg} = results;
%         end
%         metrics.(sprintf('s%02d',SUBJECT)){SESSION} = sessionMetrics;
%         save('results/test_all_classifiers.mat', 'metrics');
%         toc
%     end
% end


%% to solve parpool problem:
% distcomp.feature( 'LocalUseMpiexec', false )
