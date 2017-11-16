
%% initial configs
configs = getConfigs();
configs.subjects_list = [1 3:8 10:17];
configs.NSUBJECTS = length(configs.subjects_list);

nbits = configs.WISARD.nbits;
nlevels = configs.WISARD.nlevels;
thresholds = configs.WISARD.thresholds;
for ti=1:length(thresholds)
    thresholds(ti) = floor(thresholds(ti)*100);
end

%% get accuracies of all models

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

% save accuracies
header = classifiers;
save(sprintf('%s/all_accuracies.mat', configs.RESULTSPATH), 'accuracies', 'header');


%% compare zero vs non-zero (one-sample ttest)
load(sprintf('%s/all_accuracies.mat', configs.RESULTSPATH));

zero_indexes = [];
nozero_indexes = [];
for nb = nbits
    for nl = nlevels
        for t = thresholds
            classifier_name = sprintf('wisard_nb_%d_nl_%d_th_%d', nb, nl, t);
            zero_indexes = [zero_indexes find(endsWith(header, classifier_name))];
            nozero_indexes = [nozero_indexes find(endsWith(header, [classifier_name '_nozeros']))];
        end
    end
end

for dataset_type = {'validation' 'test'}
    for avg=1:configs.NAVGS

        % get data
        zero_data = accuracies{avg}.(dataset_type{1})(:, zero_indexes);
        nozero_data = accuracies{avg}.(dataset_type{1})(:, nozero_indexes);

        if sum(~isnan(zero_data(:))) == 0
            continue
        end

        [h, p, ci, stats] = ttest(zero_data(:), nozero_data(:));
        stats_text = {sprintf('t(%d) = %.3f', stats.df, stats.tstat), sprintf('p = %.3f', p)};

        figure;
        hold on;
        title(sprintf('zeros vs no zeros | %s set, avg: %d', dataset_type{1}, avg));
        boxplot([ zero_data(:), nozero_data(:) ], 'labels', {'zeros' 'no zeros'} );
        text(0.5, 0.5, stats_text, 'Units','normalized', 'HorizontalAlignment', 'center');

        saveas(gcf, sprintf('%s/figures/zero_nozero/%s_set_avg_%d.fig', configs.RESULTSPATH, dataset_type{1}, avg));
        saveas(gcf, sprintf('%s/figures/zero_nozero/%s_set_avg_%d.png', configs.RESULTSPATH, dataset_type{1}, avg));

        close(gcf);

    end
end


%% rank classifiers

classifiers_to_use = 1:length(header);
for dataset_type = {'validation' 'test'}

    dataset_ranks = nan(configs.NAVGS, length(header));
    for avg=1:configs.NAVGS

        % get data
        all_data = accuracies{avg}.(dataset_type{1})(:,classifiers_to_use);
        
        if sum(~isnan(all_data(:))) == 0
            continue
        end

        [p, tbl, stats] = kruskalwallis(all_data, [], off);
        
        dataset_ranks(avg, :) = stats.meanranks;


        stats_text = {sprintf('t(%d) = %.3f', stats.df, stats.tstat), sprintf('p = %.3f', p)};

        figure;
        hold on;
        title(sprintf('zeros vs no zeros | %s set, avg: %d', dataset_type{1}, avg));
        boxplot([ zero_data(:), nozero_data(:) ], 'labels', {'zeros' 'no zeros'} );
        text(0.5, 0.5, stats_text, 'Units','normalized', 'HorizontalAlignment', 'center');

        saveas(gcf, sprintf('%s/figures/zero_nonzero/%s_set_avg_%d.fig', configs.RESULTSPATH, dataset_type{1}, avg));
        saveas(gcf, sprintf('%s/figures/zero_nonzero/%s_set_avg_%d.png', configs.RESULTSPATH, dataset_type{1}, avg));

        close(gcf);

    end
end

