
%% load configs
configs = getConfigs();
configs.subjects = {'AnaOliveira' 'CarlosAmaral' 'CarlosDiogo' 'DanielaMarcelino' 'FilipaRodrigues' 'JoaoAndrade' ...
    'JoaoMarques' 'JoaoPereira' 'LuanaVelho' 'MariaJoao' 'PedroCaetano' 'RicardoBarata' 'XiaoZhu'};
configs.sessions = 1;

configs.DATAPATH = configs.SYSTEMCOMPARISONPATH;
configs.RESULTSPATH = sprintf('%s/results/T1_split_50_fixo_100nl/', configs.DATAPATH);

classifiers = {'fisher', 'nbc', 'svm', 'best_wisard'};
classifiers_legend = classifiers;
classifiers_legend{length(classifiers)} = 'wisard';
classifiers_legend{length(classifiers)+1} = 'chance rate';

%% object detection accuracy

mkdir('results/figures/syscompare/object_detection/');

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
        
        saveas( gcf, sprintf('results/figures/syscompare/object_detection/%s_%s', configs.system, datasetType{1}), 'fig' );
        saveas( gcf, sprintf('results/figures/syscompare/object_detection/%s_%s', configs.system, datasetType{1}), 'png' );
    end
end



%% P300 balanced accuracy

mkdir('results/figures/syscompare/p300/');

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
        
        saveas( gcf, sprintf('results/figures/syscompare/p300/%s_%s', configs.system, datasetType{1}), 'fig' );
        saveas( gcf, sprintf('results/figures/syscompare/p300/%s_%s', configs.system, datasetType{1}), 'png' );
        
    end
end


%% wisard hyperparameters

%configs.RESULTSPATH = 'results/';

mkdir('results/figures/syscompare/wisard/')

for sys = {'Nauti', 'Mobi', 'Xpress'}
    configs.system = sys{1};

    nbits = gatherWiSARDHyperparameter(configs, 'nbits');

    hist_avgs = nan(configs.NAVGS, length(configs.WISARD.nbits));
    for avg = 1:configs.NAVGS
        hist_avgs(avg, :) = histc(squeeze(nbits(1,avg, :)), configs.WISARD.nbits);
    end
    
    
    figure;
    bar(1:configs.NAVGS, hist_avgs, 'stacked');
    xlabel('Signal-to-Noise Ratio');
    ylabel('Count');
    title( sprintf('%s Memory Size', configs.system) );
    legend(arrayfun(@(x) cellstr(num2str(x)), configs.WISARD.nbits));

    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_nbits', configs.system), 'fig');
    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_nbits', configs.system), 'png');
    
    
    
    nlevels = gatherWiSARDHyperparameter(configs, 'nlevels');
    hist_avgs = nan(configs.NAVGS, length(configs.WISARD.nlevels));
    for avg = 1:configs.NAVGS
        hist_avgs(avg, :) = histc(squeeze(nlevels(1,avg, :)), configs.WISARD.nlevels);
    end
    
    
    figure;
    bar(1:configs.NAVGS, hist_avgs, 'stacked');
    xlabel('Signal-to-Noise Ratio');
    ylabel('Count');
    title( sprintf('%s NBits per Feature', configs.system) );
    legend(arrayfun(@(x) cellstr(num2str(x)), configs.WISARD.nlevels));

    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_nlevels', configs.system), 'fig');
    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_nlevels', configs.system), 'png');
    
    
    thresholds = gatherWiSARDHyperparameter(configs, 'threshold');
    hist_avgs = nan(configs.NAVGS, length(configs.WISARD.thresholds));
    for avg = 1:configs.NAVGS
        hist_avgs(avg, :) = histc(squeeze(thresholds(1,avg, :)), configs.WISARD.thresholds);
    end
    
    
    figure;
    bar(1:configs.NAVGS, hist_avgs, 'stacked');
    xlabel('Signal-to-Noise Ratio');
    ylabel('Count');
    title( sprintf('%s Bleaching Percentage to Look', configs.system) );
    legend(arrayfun(@(x) cellstr(sprintf('%.2f', x)), configs.WISARD.thresholds));
    
    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_threshold', configs.system), 'fig');
    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_threshold', configs.system), 'png');
    
    
    levelspermemory = nlevels ./ nbits;
    hist_avgs = nan(configs.NAVGS, length(unique(levelspermemory)));
    for avg = 1:configs.NAVGS
        hist_avgs(avg, :) = histc(squeeze(levelspermemory(1,avg, :)), sort(unique(levelspermemory)));
    end
    
    
    figure;
    bar(1:configs.NAVGS, hist_avgs, 'stacked');
    xlabel('Signal-to-Noise Ratio');
    ylabel('Count');
    title( sprintf('%s NBits per Feature', configs.system) );
    legend(arrayfun(@(x) cellstr(num2str(x)), sort(unique(levelspermemory))));

    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_levelspermemory', configs.system), 'fig');
    saveas(gcf, sprintf('results/figures/syscompare/wisard/%s_levelspermemory', configs.system), 'png');
    
    
end
