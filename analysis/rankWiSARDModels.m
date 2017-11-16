configs = getConfigs();
configs.subjects_list = [1 3:8 10:17];
configs.NSUBJECTS = length(configs.subjects_list);

nbits = configs.WISARD.nbits;
nlevels = configs.WISARD.nlevels;
thresholds = configs.WISARD.thresholds;

% load a sample model
load(sprintf('%s/subject17_session1_avg1.mat', configs.RESULTSPATH))
sample = models;

% get list of classifiers
classifiers = fieldnames(sample);

accuracies = cell(1, configs.NAVGS);
for avg = 1:configs.NAVGS

    validation_accuracy = nan(configs.NSUBJECTS * configs.NSESSIONS, length(classifiers));
    test_accuracy = nan(configs.NSUBJECTS * configs.NSESSIONS, length(classifiers));
    k = 0;
    for subject = configs.subjects_list
        for session = 1:configs.NSESSIONS
            k = k + 1;
            
            filename = sprintf('%s/subject%02d_session%d_avg%d.mat', configs.RESULTSPATH, subject, session, avg);
            if ~exist( filename )
                continue
            end
            
            % load session results
            load(filename)
            
            if isempty(models)
                continue
            end
            
            for c=1:length(classifiers)
                validation_accuracy(k, c) = models.(classifiers{c}).metrics.accuracy;
                if isfield(models.(classifiers{c}), 'testMetrics')
                    test_accuracy(k, c) = models.(classifiers{c}).testMetrics.accuracy;
                end
            end

        end
    end

    accuracies{avg} = struct('validation', validation_accuracy, 'test', test_accuracy);

end