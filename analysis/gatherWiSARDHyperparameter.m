function [results] = gatherWiSARDHyperparameter(configs, hyperparameter)
%%GATHERWISARDHYPERPARAMETER Collect specific hyperparameter from wisard result data
%   Collects the result data and extracts the specified hyperparameter from the WiSARD model from all subjects
%
%   configs        - config structure that must contain: subjects, sessions, system and resultpath
%   hyperparameter - ['nbits', 'nlevels' or 'threshold'] spefifies the hyperparameter to extract



% prepare matrix to receive results
results = nan( length(configs.sessions), configs.NAVGS, length(configs.subjects) );


for s = 1:configs.sessions
    session = configs.sessions(s);

    for avg = 1:configs.NAVGS
   
        for sbj = 1:length(configs.subjects)
            subject = configs.subjects{sbj};

            filename = sprintf('%s/%s_%s_session%d_avg%d.mat', configs.RESULTSPATH, configs.system, subject, session, avg);
            if ~exist( filename )
                continue
            end
            
            % load session results
            load(filename)
            
            if isempty(models)
                continue
            end
           
            % save hyperparameter value to result structure
            results(s,avg,sbj) = models.best_wisard.metrics.(hyperparameter);

        end
    end
end
