




%% load configs
configs = getConfigs();
configs.subjects = shuffle({'AnaOliveira' 'CarlosAmaral' 'CarlosDiogo' 'DanielaMarcelino' 'FilipaRodrigues' 'JoaoAndrade' ...
    'JoaoMarques' 'JoaoPereira' 'LuanaVelho' 'MariaJoao' 'PedroCaetano' 'RicardoBarata' 'XiaoZhu'});
configs.sessions = 1;

configs.DATAPATH = configs.SYSTEMCOMPARISONPATH;
configs.RESULTSPATH = sprintf('%s/results/saved/', configs.DATAPATH);

classifiers = {'fisher', 'nbc', 'svm', 'best_wisard'};
classifiers_legend = classifiers;
classifiers_legend{length(classifiers)} = 'wisard';
classifiers_legend{length(classifiers)+1} = 'chance rate';

%% object detection accuracy

for sys = {'Nauti', 'Mobi', 'Xpress'}
    configs.system = sys{1};

    for datasetType = {'validation', 'test'}
    
        results = gatherResultMetric(configs, datasetType{1}, 'accuracy', 0, classifiers);

        stds = squeeze(nanstd(results, [], 3)) / sqrt(length(configs.subjects));
        means = squeeze(nanmean(results, 3));

        figure;
        errorbar(means, stds);
        ylim([0, 1.3]);
        
        h = refline([0 1/8]);
        h.Color = 'r';
        h.LineStyle = '--';
        xlabel('Number of Trials Averaged');
        ylabel('Object Detection Accuracy');
        legend(classifiers_legend, 'Location', 'northwest');
        title(sprintf('%s %s set - object detection accuracy', configs.system, datasetType{1}));
        
        saveas( gcf, sprintf('results/syscompare/object_detection/%s_%s', configs.system, datasetType{1}), 'fig' );
        saveas( gcf, sprintf('results/syscompare/object_detection/%s_%s', configs.system, datasetType{1}), 'png' );
    end
end



%% P300 balanced accuracy

for sys = {'Nauti', 'Mobi', 'Xpress'}
    configs.system = sys{1};

    for datasetType = {'validation', 'test'}
    
        results = gatherResultMetric(configs, datasetType{1}, 'BACC', 1, classifiers);

        stds = squeeze(nanstd(results, [], 3)) / sqrt(length(configs.subjects));
        means = squeeze(nanmean(results, 3));

        figure;
        errorbar(means, stds);
        ylim([0, 1.3]);
        
        h = refline([0 0.5]);
        h.Color = 'r';
        h.LineStyle = '--';
        xlabel('Number of Trials Averaged');
        ylabel('Object Detection Accuracy');
        legend(classifiers_legend, 'Location', 'northwest');
        title(sprintf('%s %s set - P300 balanced accuracy', configs.system, datasetType{1}));
        
        saveas( gcf, sprintf('results/syscompare/p300/%s_%s', configs.system, datasetType{1}), 'fig' );
        saveas( gcf, sprintf('results/syscompare/p300/%s_%s', configs.system, datasetType{1}), 'png' );
        
    end
end

