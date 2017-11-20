
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
% 
% configs.RESULTSPATH = 'C:\Users\Admin\Dropbox\BCIAUT\results_ok';
% 
% % load a sample model
% load(sprintf('%s/subject17_session1_avg1.mat', configs.RESULTSPATH))
% sample = models;
% 
% % get list of classifiers
% classifiers = fieldnames(sample);
% 
% wisard_stat_data = cell(1, configs.NAVGS);
% accuracies = cell(1, configs.NAVGS);
% for avg = 1:configs.NAVGS
% 
%     validation_accuracy = nan(configs.NSUBJECTS * configs.NSESSIONS, length(classifiers));
%     test_accuracy = nan(configs.NSUBJECTS * configs.NSESSIONS, length(classifiers));
%     
%     % wisard index
%     wi = 1;
%     wisard_data = nan(configs.NSUBJECTS *length(nbits)*length(nlevels)*length(thresholds), 5 + 2 *configs.NSESSIONS);
%     
%     k = 0;
%     for subject = configs.subjects_list
%         for session = 1:configs.NSESSIONS
%             k = k + 1;
%             filename = sprintf('%s/subject%02d_session%d_avg%d.mat', configs.RESULTSPATH, subject, session, avg);
%             if ~exist( filename )
%                 continue
%             end
%             
%             % load session results
%             load(filename)
%             
%             if isempty(models)
%                 continue
%             end
%            
%             for c=1:length(classifiers)
%                 validation_accuracy(k, c) = models.(classifiers{c}).metrics.accuracy;
%                 if isfield(models.(classifiers{c}), 'testMetrics')
%                     test_accuracy(k, c) = models.(classifiers{c}).testMetrics.accuracy;
%                 end
%             end
% 
%             % wisard data
%             for nb = nbits
%                 for nl = nlevels
%                     for t = thresholds
%                         classifier_name = sprintf('wisard_nb_%d_nl_%d_th_%d', nb, nl, t);
%                         
%                         accV = models.(classifier_name).metrics.accuracy;
%                         if isfield(models.(classifier_name), 'testMetrics')
%                             accT = models.(classifier_name).testMetrics.accuracy;
%                         else
%                             accT = nan;
%                         end
%                         
%                         si = find(subject == configs.subjects_list);
%                         wisard_data(wi, :) = [si, session, nb, nl, t, accV, accT];
%                         
%                         wi = wi + 1;
%                         
%                     end
%                 end
%             end
% 
%             
%         end
%     end
% 
%     accuracies{avg} = struct('validation', validation_accuracy, 'test', test_accuracy);
%     wisard_stat_data{avg} = wisard_data;
% end
% 
% configs.RESULTSPATH = 'results';
% 
% % save accuracies
% header = classifiers;
% save(sprintf('%s/all_accuracies.mat', configs.RESULTSPATH), 'accuracies', 'header', 'wisard_stat_data');
% 
% 
% %% compare zero vs non-zero (one-sample ttest)
% load(sprintf('%s/all_accuracies.mat', configs.RESULTSPATH));
% 
% zero_indexes = [];
% nozero_indexes = [];
% for nb = nbits
%     for nl = nlevels
%         for t = thresholds
%             classifier_name = sprintf('wisard_nb_%d_nl_%d_th_%d', nb, nl, t);
%             zero_indexes = [zero_indexes find(endsWith(header, classifier_name))];
%             nozero_indexes = [nozero_indexes find(endsWith(header, [classifier_name '_nozeros']))];
%         end
%     end
% end
% 
% for dataset_type = {'validation' 'test'}
%     for avg=1:configs.NAVGS
% 
%         % get data
%         zero_data = accuracies{avg}.(dataset_type{1})(:, zero_indexes);
%         nozero_data = accuracies{avg}.(dataset_type{1})(:, nozero_indexes);
% 
%         if sum(~isnan(zero_data(:))) == 0
%             continue
%         end
% 
%         [h, p, ci, stats] = ttest(zero_data(:), nozero_data(:));
%         stats_text = {sprintf('t(%d) = %.3f', stats.df, stats.tstat), sprintf('p = %.3f', p)};
% 
%         figure;
%         hold on;
%         title(sprintf('zeros vs no zeros | %s set, avg: %d', dataset_type{1}, avg));
%         boxplot([ zero_data(:), nozero_data(:) ], 'labels', {'zeros' 'no zeros'} );
%         text(0.5, 0.5, stats_text, 'Units','normalized', 'HorizontalAlignment', 'center');
% 
%         saveas(gcf, sprintf('%s/figures/zero_nozero/%s_set_avg_%d.fig', configs.RESULTSPATH, dataset_type{1}, avg));
%         saveas(gcf, sprintf('%s/figures/zero_nozero/%s_set_avg_%d.png', configs.RESULTSPATH, dataset_type{1}, avg));
% 
%         close(gcf);
% 
%     end
% end
% 

% %% rank classifiers
% ranks = struct();
% 
% zero_indexes = [];
% nozero_indexes = [];
% for nb = nbits
%     for nl = nlevels
%         for t = thresholds
%             classifier_name = sprintf('wisard_nb_%d_nl_%d_th_%d', nb, nl, t);
%             zero_indexes = [zero_indexes find(endsWith(header, classifier_name))];
%         end
%     end
% end
% 
% classifiers_to_use = zero_indexes;
% for dataset_type = {'validation' 'test'}
% 
%     dataset_ranks = nan(configs.NAVGS, length(classifiers_to_use));
%     for avg=1:configs.NAVGS
% 
%         % get data
%         all_data = accuracies{avg}.(dataset_type{1})(:,classifiers_to_use);
%         
%         if sum(~isnan(all_data(:))) == 0
%             continue
%         end
% 
%         [p, tbl, stats] = kruskalwallis(all_data, [], 'off');
%         
%         dataset_ranks(avg, :) = stats.meanranks;
% 
% 
%     end
%     
%     ranks.(dataset_type{1}) = dataset_ranks;
% end
% 
% header = header(classifiers_to_use);
% save(sprintf('%s/classifier_ranks.mat', configs.RESULTSPATH), 'ranks', 'header');

%% scatter 3 for wisard
% 
% threshold_colors = [ ...
%     0 0 0 ; ... % 0   - black
%     0 0 1 ; ... % 5   - blue
%     0 1 1 ; ... % 10  - cyan
%     0 1 0 ; ... % 30  - green
%     1 1 0 ; ... % 50  - yellow
%     1 0 1 ; ... % 80  - magenta
%     1 0 0 ];    % 100 - red
%     
% 
% for dataset_type = {'validation' 'test'}
%     
%     for avg=1:configs.NAVGS
%         
%         mean_accuracies = squeeze(nanmean(accuracies{avg}.(dataset_type{1})(:,classifiers_to_use), 1));
%         mean_ranks = ranks.(dataset_type{1})(avg, :);
%         data = nan(length(nbits)*length(nlevels)*length(thresholds), 4);
%         
%         k = 1;
%         for nb = nbits
%             for nl = nlevels
%                 for t = thresholds
%                     classifier_name = sprintf('wisard_nb_%d_nl_%d_th_%d', nb, nl, t);
%                     %data(k, :) = [nb, nl, find(t == thresholds), mean_ranks(find(endsWith(header, classifier_name)))];
%                     data(k, :) = [nb, nl, t, mean_ranks(find(endsWith(header, classifier_name)))];
%                     k = k + 1;
%                 end
%             end
%         end
%         
%         figure;
%         hold on;
%         %scatter3(data(:,1), data(:,2), data(:, 4), [], threshold_colors(data(:,3), :), 'filled');
%         scatter3(data(:,1), data(:,2), data(:, 3), data(:,4)/200, 'filled');
%         view(40,35);
%         
%         title(sprintf('hyperparameters | %s set, avg: %d', dataset_type{1}, avg));
%         xlabel('Number of bits')
%         ylabel('Number of levels')
%         zlabel('Accuracy')
% 
%         saveas(gcf, sprintf('%s/figures/hyperparameters/%s_set_avg_%d.fig', configs.RESULTSPATH, dataset_type{1}, avg));
%         saveas(gcf, sprintf('%s/figures/hyperparameters/%s_set_avg_%d.png', configs.RESULTSPATH, dataset_type{1}, avg));
% 
%         close(gcf);
% 
%     end
% end





%% anova analysis
% 
% load(sprintf('%s/all_accuracies.mat', configs.RESULTSPATH));
% 
% for avg=1:configs.NAVGS
%     data = array2table(wisard_stat_data{avg}(:,1:end-1), 'VariableNames', {'Subject', 'Session', 'Nbits', 'Nlevels', 'Threshold', 'ValidationAccuracy'});
%     new_data = unstack(data, 'ValidationAccuracy', 'Session');
%     
%     rm = fitrm(new_data, 'x1-x7 ~ Nbits*Nlevels*Threshold');
%     %rm = fitrm(new_data, 'x1-x7 ~ Nbits*Nlevels');
%     ranovatbl = ranova(rm);
%     
%     T = ranovatbl; figure; uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
%     'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
%     
%     set(gcf, 'Position', [100, 100, 950, 250])
%     saveas(gcf, sprintf('%s/figures/hyperparameters/ranova_avg_%d.fig', configs.RESULTSPATH, avg));
%     saveas(gcf, sprintf('%s/figures/hyperparameters/ranova_avg_%d.png', configs.RESULTSPATH, avg));
%     close(gcf);
%     
% end


% %% sort hyperparameters by ranks 
% 
% load(sprintf('%s/classifier_ranks.mat', configs.RESULTSPATH))
% 
% header = arrayfun(@(x) cellstr([x{1} '_']), header);
% 
% hyperparameters = {struct('name', 'nbits', 'code', 'nb', 'values', nbits), ...
%     struct('name', 'nlevels', 'code', 'nl', 'values', nlevels), ...
%     struct('name', 'thresholds', 'code', 'th', 'values', thresholds)};
% 
% 
% for hp = 1:length(hyperparameters)
%     hyperparam = hyperparameters{hp};
%     for avg = 1:configs.NAVGS
% 
%         % hyperparam
% 
%         data = nan( fix(length(header)/length(hyperparam.values)), length(hyperparam.values) );
%         for i = 1:length(hyperparam.values)
%             idxs = find(contains(header, sprintf('_%s_%d_', hyperparam.code, hyperparam.values(i))));
%             data(:, i) = ranks.validation(avg, idxs);
%         end
% 
%         [p, tbl, stats] = kruskalwallis(data, [], 'off');
% 
%         stats_text = strjoin( arrayfun(@(rank, value) cellstr(sprintf('%s: %d, r: %.2f |', hyperparam.code, value, rank)), stats.meanranks, hyperparam.values));
% 
%         figure; hold on;
%         boxplot(data, arrayfun(@(x) cellstr(num2str(x)), hyperparam.values))
%         text(0.5, -.1, stats_text, 'Units','normalized', 'HorizontalAlignment', 'center');
%         title(sprintf('Hyperparameter tuning: %s, avg = %d', hyperparam.name, avg));
%         set(gcf, 'Position', [2100, 100, 800, 600])
%         saveas(gcf, sprintf('%s/figures/hyperparameters/%s_avg_%d.fig', configs.RESULTSPATH, hyperparam.name, avg));
%         saveas(gcf, sprintf('%s/figures/hyperparameters/%s_avg_%d.png', configs.RESULTSPATH, hyperparam.name, avg));
%         close(gcf);
%     end
% end


%% compare classifiers

wisard_classifier = 'wisard_nb_8_nl_100_th_30';
classifiers_idxs = [ find(~contains(header, 'wisard'))' find(endsWith(header, wisard_classifier)) ];

classifiers_header = header(classifiers_idxs);
classifiers_header{contains(classifiers_header, 'wisard')} = 'wisard';

for dataset_type = {'validation' 'test'}
    for avg=1:configs.NAVGS
        classifiers_accuracies = accuracies{avg}.(dataset_type{1})(:, classifiers_idxs);
        
        figure; hold on;
        boxplot(classifiers_accuracies, classifiers_header)
        [p, tbl, stats] = kruskalwallis(classifiers_accuracies, [], 'off');

        stats_text = strjoin( arrayfun(@(name, rank) cellstr(sprintf('%s: %.2f |', name{1}, rank)), classifiers_header', stats.meanranks));

        
        text(0.5, -.1, stats_text, 'Units','normalized', 'HorizontalAlignment', 'center');
        title(sprintf('Classifier Comparison: %s set, avg = %d', dataset_type{1}, avg));
        set(gcf, 'Position', [2000, 50, 1800, 900])
        saveas(gcf, sprintf('%s/figures/classifiers_comparison/%s_avg_%d.fig', configs.RESULTSPATH, dataset_type{1}, avg));
        saveas(gcf, sprintf('%s/figures/classifiers_comparison/%s_avg_%d.png', configs.RESULTSPATH, dataset_type{1}, avg));
        close(gcf);
        
    end
end


%% averages used test set

load(sprintf('%s/all_accuracies.mat', configs.RESULTSPATH))

bci_avgs = nan(configs.NSUBJECTS * configs.NSESSIONS, 1);

sess2idx = @(sub,sess)(sub-1)*configs.NSESSIONS+sess;

for avg = 2:configs.NAVGS
    for subject = 1:configs.NSUBJECTS
        for session = 1:configs.NSESSIONS
            
            if isnan(accuracies{avg}.test(sess2idx(subject, session), 1)) && isnan(bci_avgs(sess2idx(subject, session)))
                bci_avgs(sess2idx(subject, session)) = avg-1;
            end
        end
    end
end
   
bci_avgs(isnan(bci_avgs)) = 10;


test_accuracy = nan(size(accuracies{1}.test));

for sess = 1:size(test_accuracy, 1)
    test_accuracy(sess, :) = accuracies{bci_avgs(sess)}.test(sess, :);
end


wisard_classifier = 'wisard_nb_8_nl_100_th_30';
classifiers_idxs = [ find(~contains(header, 'wisard'))' find(endsWith(header, wisard_classifier)) ];

classifiers_header = header(classifiers_idxs);
classifiers_header{contains(classifiers_header, 'wisard')} = 'wisard';

test_accuracy = test_accuracy(:, classifiers_idxs);

figure; hold on;
boxplot(test_accuracy, classifiers_header)
[p, tbl, stats] = kruskalwallis(test_accuracy, [], 'off');

stats_text = strjoin( arrayfun(@(name, rank) cellstr(sprintf('%s: %.2f |', name{1}, rank)), classifiers_header', stats.meanranks));


text(0.5, -.1, stats_text, 'Units','normalized', 'HorizontalAlignment', 'center');
title(sprintf('Classifier Comparison: BCI'));
set(gcf, 'Position', [2000, 50, 1800, 900])
saveas(gcf, sprintf('%s/figures/classifiers_comparison/BCI.fig', configs.RESULTSPATH));
saveas(gcf, sprintf('%s/figures/classifiers_comparison/BCI.png', configs.RESULTSPATH));
close(gcf);
