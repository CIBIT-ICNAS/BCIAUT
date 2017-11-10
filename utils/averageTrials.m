function [EEG] = averageTrials(EEG, nTrialsToAvg)
%AVERAGETRIALS Averages EEG epochs by nTrialsAvg
%   EEG must contain all info and data 


    nAveragedTrials = fix( EEG.nTrials / nTrialsToAvg );
    elements = unique(EEG.labels)';

    EEGDataAvg = nan(size(EEG.data, 1), size(EEG.data, 2), nAveragedTrials * EEG.nElements * EEG.nRuns);
    labelsAvg =  nan(nAveragedTrials * EEG.nElements * EEG.nRuns, 1);
    isTargetAvg =  nan(nAveragedTrials * EEG.nElements * EEG.nRuns, 1);

    k = 1;
    for run = 1:EEG.nRuns
        runIdxs = (run-1)*EEG.nElements*EEG.nTrials+1:run*EEG.nElements*EEG.nTrials;
        runData = EEG.data(:,:, runIdxs);
        runLabels = EEG.labels(runIdxs);
        runIsTarget = EEG.isTarget(runIdxs);

        for avgIdx = 1:nAveragedTrials
            for element = elements
                elementIdxs = find(runLabels == element);
                
                EEGDataAvg(:,:,k) = mean(runData(:,:, elementIdxs( (avgIdx-1)*nTrialsToAvg+1 : avgIdx*nTrialsToAvg ) ), 3); 
                labelsAvg(k) = element;
                isTargetAvg(k) = runIsTarget(elementIdxs(1));

                k = k+1;
            end
        end

    end

    EEG.data = EEGDataAvg;
    EEG.labels = labelsAvg;
    EEG.isTarget = logical(isTargetAvg);
    EEG.nTrials = nAveragedTrials;

end