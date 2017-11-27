function [EEG1, EEG2] = splitDataset(EEG, percent)

if nargin < 2
    percent = 0.5;
end

nRuns = fix(EEG.nRuns * percent);

idxs = 1:(nRuns * EEG.nTrials * EEG.nElements);

EEG1 = EEG;
EEG1.nRuns = nRuns;
EEG1.data = EEG1.data(:,:, idxs);
EEG1.labels = EEG1.labels(idxs);
EEG1.isTarget = EEG1.isTarget(idxs);

EEG2 = EEG;
EEG2.nRuns = EEG.nRuns - nRuns;
EEG2.data(:,:,idxs) = [];
EEG2.labels(idxs) = [];
EEG2.isTarget(idxs) = [];


end
