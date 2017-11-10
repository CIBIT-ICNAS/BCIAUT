% use configs structure to store configurations needed in the analysis
configs = struct();

% define aquisition configs
configs.nChannels = 8;
configs.nElements = 8;
configs.nTrials = 10;
configs.srate = 250;
configs.NSESSIONS = 7;
configs.NAVGS = 10;

subjects_list = [1 3:8 10:17];
load( 'results/subject01_session1_avg1.mat' );
classifiers_list = fieldnames(models)';

validation_accuracies = nan(length(subjects_list) * configs.NSESSIONS, length(classifiers_list), configs.NAVGS);
test_accuracies = nan(length(subjects_list) * configs.NSESSIONS, length(classifiers_list), configs.NAVGS);

for si = 1:length(subjects_list)
    subject = subjects_list(si);
    for session = 1:configs.NSESSIONS
        for avg = 1:configs.NAVGS
            results_filename = sprintf('results/subject%02d_session%d_avg%d.mat', subject, session, avg) ;
            if exist( results_filename ) == 0
                continue
            end
            load( results_filename );

            for ci = 1:length(classifiers_list)
                validation_accuracies((si-1)*configs.NSESSIONS+session, ci, avg) = models.(classifiers_list{ci}).metrics.accuracy;
                if isfield(models.(classifiers_list{ci}), 'testMetrics')
                    test_accuracies((si-1)*configs.NSESSIONS+session, ci, avg) = models.(classifiers_list{ci}).testMetrics.accuracy;
                end
            end
        end
    end
end


for avg = 1:10
    figure;
    subplot(2, 1, 1);
    boxplot(squeeze(validation_accuracies(:,classifiers_indexes,avg)), classifiers_list(classifiers_indexes));
    ylim([0 1.1])
    
    subplot(2, 1, 2);
    boxplot(squeeze(test_accuracies(:,classifiers_indexes,avg)), classifiers_list(classifiers_indexes));
    ylim([0 1.1])
end