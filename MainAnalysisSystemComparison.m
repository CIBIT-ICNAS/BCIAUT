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
configs.NSESSIONS = 1;
configs.DATAPATH = configs.SYSTEMCOMPARISONPATH;

configs.subject_list = shuffle({'AnaOliveira' 'CarlosAmaral' 'CarlosDiogo' 'DanielaMarcelino' 'FilipaRodrigues' 'JoaoAndrade' ...
    'JoaoMarques' 'JoaoPereira' 'LuanaVelho' 'MariaJoao' 'PedroCaetano' 'RicardoBarata' 'XiaoZhu'});

%% compute base models
%base_models = struct();
% for systemName = {'Xpress'} %'Nauti', 'Mobi', 
%     models = struct();
% 
%     configs.system = systemName{1};
% 
%     for SUBJECT = configs.subject_list
%         subject_name = SUBJECT{1};
% 
%         models.(subject_name) = cell(1, configs.NSESSIONS);
%         
%         for SESSION = 1:configs.NSESSIONS
%             fprintf('subject: %s | session: %d\n', subject_name , SESSION); 
%             
%             define subject configs
%             configs.subject = subject_name;
%             configs.session = SESSION;
%             
%             compute model for this session        
%             models.(subject_name){SESSION} = computeBaseModels(configs);
%             
%             save temporary result
%             save(sprintf('%s/tmp_models.mat', configs.RESULTSPATH), 'models');
%         end
%     end
%     base_models.(configs.system) = models;
% 
%     save temporary result
%     save(sprintf('%s/base_models.mat', configs.RESULTSPATH), 'base_models');
% end



%% compute new models
load(sprintf('%s/base_models.mat', configs.RESULTSPATH));
all_models = base_models;

for systemName = {'Xpress', 'Nauti', 'Mobi'} 
    configs.system = systemName{1};

    base_models = all_models.(configs.system);
    for SUBJECT = configs.subject_list
        subject_name = SUBJECT{1};
        for SESSION = 1:configs.NSESSIONS
            
            fprintf('system: %s | subject: %s | session: %d\n', configs.system, subject_name, SESSION);
            if exist(sprintf('%s/%s_%s_session%d_avg%d.mat', configs.RESULTSPATH, configs.system, subject_name, SESSION, 1))
                continue
            end
            
            models = [];
            save(sprintf('%s/%s_%s_session%d_avg%d.mat', configs.RESULTSPATH, configs.system, subject_name, SESSION, 1), 'models');
            
            % define subject configs
            configs.subject = subject_name;
            configs.session = SESSION;
            
            % compute new models for this session
            new_models = computeNewModels(configs, base_models.(subject_name){SESSION}, {'svmp' 'svm' 'nbc' 'naiveb' 'fisher' 'wisard'}, 1);

            for avg=1:configs.NAVGS
                models = new_models{avg};
                save(sprintf('%s/%s_%s_session%d_avg%d.mat', 'results', configs.system, subject_name, SESSION, avg), 'models', '-v7.3');
                for name =fieldnames(models)'
                    models.(name{1}).model = [];
                end
                save(sprintf('%s/%s_%s_session%d_avg%d.mat', configs.RESULTSPATH, configs.system, subject_name, SESSION, avg), 'models', '-v7.3');
            end
        end
    end
end


%% gist to solve parpool problem:
% distcomp.feature( 'LocalUseMpiexec', false )