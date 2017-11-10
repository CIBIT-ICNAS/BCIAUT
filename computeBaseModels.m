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


%% Compute and validate trainig model and filters

models = struct();
if exist('results/base_models.mat')
    load('results/base_models.mat'); 
end

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
        define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', DATAPATH,SUBJECT, SESSION);
        tic
        
        load data
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
        save('results/base_models.mat', 'models');
        toc
    end
end


%% gist to solve parpool problem:
% distcomp.feature( 'LocalUseMpiexec', false )