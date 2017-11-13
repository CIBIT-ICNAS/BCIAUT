function [ EEG ] = loadEEGData( configs, runType, trialStart, trialEnd )
%LOADEEGDATA Load raw data from BCIAUT
%   configs must contain subjectPath and other acquisition configuratios 
%   runType must be 'Train1', 'Train2' or 'BCI'
%   trialStart and trialEnd are in seconds time from the trigger to chop the epochs (default: -0.1 and 1, respectively)

    if nargin < 4
        trialEnd = 1;
    end
    if nargin < 3
        trialStart = 0;
    end
    epochSize = fix((trialEnd - trialStart) * configs.srate);

    % load raw data
    if strcmp(runType, 'Train1') || strcmp(runType, 'Train2')
        runData = load( sprintf('%s/Training/Nauti_%d_BCI%02d_%s_EEG.mat', configs.subjectPath, configs.nTrials * configs.nElements, configs.subject, runType) );
    elseif strcmp(runType, 'BCI')
        lastModel = load( sprintf('%s/ClassifierModel/Nauti_BCI%02d_Session%d_classifierLastModel.mat', configs.subjectPath, configs.subject, configs.session) );
        configs.nTrials = lastModel.avgToUse;
        runData = load( sprintf('%s/BCI/Nauti_%d_BCI%02d_%sEEG.mat', configs.subjectPath, configs.nTrials * configs.nElements, configs.subject, runType) );
    else
        throw(MException('loadEEGData:runType_error',['The runType must be Train1, Train2 or BCI. runType provided: ' runType]));
    end

    rawData = runData.y;
    targets = runData.runTargets(runData.runTargets > 0);

    % last channel of rawData contains event markers
    eventLatencies = find(rawData(end,:)>=1  & rawData(end,:)<=41);
    labels = rawData(end, eventLatencies);
    labels = labels(:);

    % get targets
    targets = repmat(targets, [1 configs.nElements * configs.nTrials])'; 
    targets = targets(:);

    % isTarget is 1 if target epoch or 0 if non-target epoch
    isTarget = (targets == labels);

    % chop data into epochs (channels to use: 2 - 9)
    EEGData = nan(configs.nChannels, epochSize, length(labels));
    for i = 1:length(eventLatencies)
        EEGData(:,:,i) = rawData(2:end-1, eventLatencies(i)+fix(trialStart * configs.srate): eventLatencies(i) +fix(trialEnd * configs.srate) -1);
    end

    EEG = struct('data', EEGData, 'xmin', trialStart, 'xmax', trialEnd, 'srate', configs.srate, 'nElements', configs.nElements, ...
        'nTrials', configs.nTrials, 'nRuns', fix(size(EEGData, 3) / (configs.nElements * configs.nTrials)), 'labels', labels, ...
        'isTarget', isTarget, 'times', trialStart:1/configs.srate:trialEnd-1/configs.srate);
end

