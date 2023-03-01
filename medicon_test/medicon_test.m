function medicon_test(configs)

EEG_T2 = loadEEGData(configs, 'Train2', -0.2, 1.2);

for i=1:10
    
    blockIdx = (i-1)*80+1:i*80;
    
    theLables = EEG_T2.labels(blockIdx);
    isTarget = EEG_T2.isTarget(blockIdx);
    
    theTarget = theLables(isTarget);
    theTarget = theTarget(1);
    
    data = EEG_T2.data(:,:,blockIdx);
    
    figure; hold on;
    for label = 1:8
        mT = mean(data(3,:,EEG_T2.labels(blockIdx) == label), 3);
        mNT = mean(data(3,:,EEG_T2.labels(blockIdx) ~= label), 3);
       
        subplot(2,4,label)
        hold on
        plot(squeeze(mNT))
        plot(squeeze(mT))
        
        title(sprintf('%d = %d',label, theTarget))
    end
    
    saveas(gcf, sprintf('medicon_test/%s_%d_%d.png',configs.subject, configs.session, i), 'png');
    
    close(gcf);
end

end