function plotP300(EEG, plotFeatures)
    
    %figure;
    if nargin < 2 || ~plotFeatures
        T = squeeze(mean(EEG.data(:, :, EEG.isTarget), 3));
        NT = squeeze(mean(EEG.data(:,:, ~EEG.isTarget), 3));
        
        for ch=1:size(T, 1)
            subplot( 2, 4, ch);        
            hold on;
            plot(EEG.times, NT(ch, :));
            plot(EEG.times, T(ch, :));
            xlim([EEG.xmin EEG.xmax]);
            ylim([-.5 1]);
        end
    else
        T = squeeze(mean(EEG.features(EEG.isTarget, :), 1));
        NT = squeeze(mean(EEG.features(~EEG.isTarget, :), 1));
        
        hold on;
        plot(NT);
        plot(T);
        
    end
end