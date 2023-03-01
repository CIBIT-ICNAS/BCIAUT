load classification_times.mat

avg = 1;
[val, wisardIdx] = min(mean(train_times(:, 6:end, avg)));

classifiers_indexes = [(wisardIdx+5) 2 3 4];
classifiers_names = {'wisard' 'svm' 'fisher' 'nbc'};

% only single trials
train_times = squeeze( train_times(:,classifiers_indexes, 4) );
test_times = squeeze( test_times(:,classifiers_indexes, 4) );

figure; boxplot(train_times, classifiers_names);


% check normality
non_parametric = 0;
for i=1:length(classifiers_names)
    [h, p, ksstat] = kstest( ( train_times(:, i) - mean(train_times(:, i)) ) / std(train_times(:, i)) );
    if p < 0.05
        non_parametric = 1;
    end
    fprintf('%s: p: %.2f\n', classifiers_names{i}, p);
end


if non_parametric
    fprintf('\n\nNon-Parametric Tests!\n\n');

    % run non-parametric test
    [p,tbl,stats] = friedman(train_times, 1, 'off');
    fprintf('Friedman Test: p: %.4f\n', p);
    if p <= 0.05
        fprintf('Post-Hoc:\n');
        c = multcompare(stats, 'display', 'off');
        groups = [];
        significant_stats = [];
        for i = 1:size(c, 1)
            [p h] = ranksum(train_times(:, fix(c(i,1))), train_times(:, fix(c(i,2))));
            if p*size(c,1) <= 0.05
                groups = [ groups {[ fix(c(i,1)) fix(c(i,2)) ]} ];
                significant_stats = [significant_stats p*size(c, 1)];
            end
             fprintf('%s - %s: p=%.6f\n', classifiers_names{fix(c(i,1))}, classifiers_names{fix(c(i,2))}, p * size(c, 1));
        end
        sigstar(groups, significant_stats);
    end
else
    fprintf('\n\nParametric Tests!\n\n');
    [p,tbl,stats] = anova1(train_times, classifiers_names, 'off');
    fprintf('1-way Anova Test: p: %.2f\n', p);
    if p < 0.05
        fprintf('Post-Hoc:\n');
        c = multcompare(stats, 'display', 'off');
        groups = [];
        significant_stats = [];
        for i = 1:size(c, 1)
            if c(i, end) <= 0.05
                groups = [ groups {[ fix(c(i,1)) fix(c(i,2)) ]} ];
                significant_stats = [significant_stats c(i, end)];
            end
            fprintf('%s - %s: p=%.4f\n', classifiers_names{fix(c(i,1))}, classifiers_names{fix(c(i,2))}, c(i,end));
        end
        sigstar(groups, significant_stats);
    end
end



2.021	3.410	1.222
1.624	0.511	1.778
2.852	0.420	1.383
1.054	8.761	0.528
1.419	3.799	-1.542
2.912	5.263	4.041
0.135	3.108	0.850
4.712	3.361	3.684
3.167	0.292	2.516
-0.460	3.513	2.426
