% This script performs a comparison analysis of several classifiers for
% P300 classification in BCIAUT clinical trial data
%
% November 2017
% Creator Marco Simoes (msimoes@dei.uc.pt) and Carlos Amaral.
%
% All rights reverved

% setup path
addpath(genpath('.'));
rmpath(genpath('.git'));

%% load configs
configs = getConfigs();
configs.subject_list = [1 3:8 10:17];

% %% compute base models
% models = struct();
% 
% for SUBJECT = configs.subject_list
%     models.(sprintf('s%02d',SUBJECT)) = cell(1, configs.NSESSIONS);
%     
%     for SESSION = 1:configs.NSESSIONS
%         fprintf('subject: %d | session: %d\n', SUBJECT , SESSION); 
%         
%         % define subject configs
%         configs.subject = SUBJECT;
%         configs.session = SESSION;
% 
%         % compute model for this session        
%         models.(sprintf('s%02d',SUBJECT)){SESSION} = computeBaseModels(configs);
%         
%         % save temporary result
%         save(sprintf('%s/base_models.mat', configs.RESULTSPATH), 'models');
%     end
% end

%% compute new models
load(sprintf('%s/base_models.mat', configs.RESULTSPATH));
base_models = models;

%configs.RESULTSPATH = 'C:\\Users\\Admin\\Dropbox\\BCIAUT\\results_ok';
for SUBJECT = configs.subject_list
    for SESSION = 1:configs.NSESSIONS
        fprintf('subject: %d | session: %d\n', SUBJECT, SESSION);
        if exist(sprintf('%s/subject%02d_session%d_avg%d.mat', configs.RESULTSPATH, SUBJECT, SESSION, 1))
            continue
        end
        
        models = [];
        save(sprintf('%s/subject%02d_session%d_avg%d.mat', configs.RESULTSPATH, SUBJECT, SESSION, 1), 'models');
        
        % define subject configs
        configs.subject = SUBJECT;
        configs.session = SESSION;
        
        % compute new models for this session
        new_models = computeNewModels(configs, base_models.(sprintf('s%02d',SUBJECT)){SESSION}, {'svmp' 'nbc' 'fisher' 'wisard'}, 1);

        for avg=1:configs.NAVGS
            models = new_models{avg};
            save(sprintf('%s/subject%02d_session%d_avg%d.mat', 'results', SUBJECT, SESSION, avg), 'models', '-v7.3');
            continue
            for name =fieldnames(models)'
                models.(name{1}).model = [];
            end
            save(sprintf('%s/subject%02d_session%d_avg%d.mat', configs.RESULTSPATH, SUBJECT, SESSION, avg), 'models', '-v7.3');
        end
    end
end



%% gist to solve parpool problem:
% distcomp.feature( 'LocalUseMpiexec', false )