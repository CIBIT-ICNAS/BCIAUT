
addpath('analysis', 'classification', 'core', 'imports', 'metrics', 'utils', 'classification/wisard');

% use configs structure to store configurations needed in the analysis
configs = getConfigs();

% load base models
load(sprintf('%s/base_models.mat', configs.RESULTSPATH));
base_models = models;

for SUBJECT = [1 3:8 10:17]
    for SESSION = 1:configs.NSESSIONS
        fprintf('subject: %d | session: %d\n', SUBJECT , SESSION); 
        session_results = cell(1, configs.NAVGS);
        
        % define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        tic
        
        % load data
        EEG_T1 = normalizeTrials( loadEEGData(configs, 'Train1', 0, 1), 'zscore');
        EEG_T2 = normalizeTrials( loadEEGData(configs, 'Train2', 0, 1), 'zscore');
        EEG_BCI = normalizeTrials( loadEEGData(configs, 'BCI', 0, 1), 'zscore');
        
        % extract features
        model = base_models.(sprintf('s%02d', SUBJECT)){SESSION}{1};
        [EEG_T1.features, ~] = extractFeatures(EEG_T1, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
        [EEG_T2.features, ~] = extractFeatures(EEG_T2, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
        [EEG_BCI.features, ~] = extractFeatures(EEG_BCI, model.W1, model.W2, struct('featureIdxs', model.featureIdxs));
        
        % plot subject data
        figure;
        plotP300(EEG_T1);
        plotP300(EEG_T2);
        plotP300(EEG_BCI);
        
        % plot subject features
        figure;
        plotP300(EEG_T1, 1);
        plotP300(EEG_T2, 1);
        plotP300(EEG_BCI, 1);
        
        pause
        
        classifiers = trainClassifiers(EEG_T1_zscored, EEG_T2_zscored, {'all'});
        
        for classifier = fieldnames(classifiers)'
            fprintf('[%d] %s: %.2f\n', avg, classifier{1}, classifiers.(classifier{1}).metrics.accuracy);
        end
    end
end


