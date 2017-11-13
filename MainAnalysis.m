% This script performs a comparison analysis of several classifiers for
% P300 classification in BCIAUT clinical trial data
%
% November 2017
% Creator Marco Simoes (msimoes@dei.uc.pt) and Carlos Amaral.
%
% All rights reverved

% setup path
addpath('analysis', 'classification', 'configs', 'core', 'data_import', 'metrics', 'utils', 'classification/wisard', 'reporting');


%% load configs
configs = getConfigs();
configs.subject_list = [1 3:8 10:17];

%% compute base models
models = struct();

for SUBJECT = configs.subject_list
    models.(sprintf('s%02d',SUBJECT)) = cell(1, configs.NSESSIONS);
    
    for SESSION = 1:configs.NSESSIONS
        fprintf('subject: %d | session: %d\n', SUBJECT , SESSION); 
        
        % define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', configs.DATAPATH, SUBJECT, SESSION);

        % compute model for this session        
        models.(sprintf('s%02d',SUBJECT)){SESSION} = computeBaseModels(configs);
        
        % save temporary result
        save(sprintf('%s/base_models.mat', configs.RESULTSPATH), 'models');
    end
end
base_models = models;

%% compute new models
for SUBJECT = configs.subject_list
    for SESSION = 1:configs.NSESSIONS
        
        % define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        configs.subjectPath = sprintf('%s/Nauti_BCI%02d/Session%d/', configs.DATAPATH, SUBJECT, SESSION);
        
        % compute new models for this session
        models = computeNewModels(configs, base_models.(sprintf('s%02d',SUBJECT)){SESSION}, {'all'}, 1);

        save(sprintf('%s/subject%02d_session%d_avg%d.mat', configs.RESULTSPATH, SUBJECT, SESSION, avg), 'models');
    end
end



%% gist to solve parpool problem:
% distcomp.feature( 'LocalUseMpiexec', false )