function [configs] = getConfigs()

[~, hostname] = system('hostname');

if contains(hostname, 'disbeatmac')
    BASEPATH = '/Volumes/Dropbox';
elseif contains(hostname, 'czc02841b4')
    BASEPATH = 'C:/Users/Admin/Dropbox/';
else
    BASEPATH = 'D:/Dropbox/';
end

% use configs structure to store configurations needed in the analysis
configs = struct();

% define aquisition configs
configs.nChannels = 8;
configs.nElements = 8;
configs.nTrials = 10;
configs.srate = 250;
configs.NSESSIONS = 7;
configs.NAVGS = 10;


configs.WISARD = struct( ...
  'nbits',      [2 4 8 16 24], ...
  'nlevels',    [5 10 15 30 50 100], ...
  'thresholds', [1E-7 0.05 0.1 0.3 0.5 0.8 1] ...
);

configs.BCIAUTPATH = sprintf('%s/BCIAUT_data/',BASEPATH);
configs.SYSTEMCOMPARISONPATH = sprintf('%s/BCIAUT_SystemComparison/',BASEPATH);
configs.PILOTSPATH = sprintf('%s/BCIAUT_Pilots/',BASEPATH);


configs.DATAPATH = configs.SYSTEMCOMPARISONPATH;
configs.RESULTSPATH = sprintf('%s/results/', configs.DATAPATH);

end