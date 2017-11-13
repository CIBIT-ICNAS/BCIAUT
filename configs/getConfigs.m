function [configs] = getConfigs()

DATAPATH = 'D:/Dados/BCIAUT_Data/';
RESULTSPATH = 'results/';

% use configs structure to store configurations needed in the analysis
configs = struct();

% define aquisition configs
configs.nChannels = 8;
configs.nElements = 8;
configs.nTrials = 10;
configs.srate = 250;
configs.NSESSIONS = 7;
configs.NAVGS = 10;
configs.DATAPATH = DATAPATH;
configs.RESULTSPATH = RESULTSPATH;

end