function [results] = gatherResultMetric(configs, datasetType, metric, isBinary, classifiers)
%%GATHERRESULTMETRIC Collect specific metric from result data
%   Collects the result data and extracts a specific metric from all subjects
%
%   configs     - config structure that must contain: subjects, sessions, system and resultpath
%   datasetType - ['validation' or 'test'] spefifies the dataset from which collect the metric
%   metric      - metric to extract, usually accuracy
%   isBinary    - [1 or 0(default)] spefifies if is a binary classification (1) or object detection metric (0)
%   classifiers - list of classifier names. if not provided, uses all available classifier


if nargin < 5
    % load a sample model
    load(sprintf('%s/%s_%s_session1_avg1.mat', configs.RESULTSPATH, configs.system, configs.subjects{1}))
    
    % get list of classifiers
    classifiers = fieldnames(models);
end

if nargin < 4
    isBinary = 0;
end

% treat the datasetType
if strcmp(datasetType, 'validation')
    datasetType = 'metrics';
elseif strcmp(datasetType, 'test')
    datasetType = 'testMetrics';
else
    throw(MException('gatherResults:datasetType_error',['The datasetType must be validation or test. datasetType provided: ' datasetType]));    
end

% prepare matrix to receive results
results = nan( length(configs.sessions), configs.NAVGS, length(configs.subjects), length(classifiers) );


for s = 1:configs.sessions
    session = configs.sessions(s);

    for avg = 1:configs.NAVGS
   
        for sbj = 1:length(configs.subjects)
            subject = configs.subjects{sbj};

            filename = sprintf('%s/%s_%s_session%d_avg%d.mat', configs.RESULTSPATH, configs.system, subject, session, avg);
            if ~exist( filename )
                continue
            end
            
            % load session results
            load(filename)
            
            if isempty(models)
                continue
            end
           
            for c=1:length(classifiers)
                if isfield(models.(classifiers{c}), datasetType)
                    base = models.(classifiers{c}).(datasetType);
                    
                    if isBinary % check if binary metric
                        base = base.('binaryMetrics');
                    end

                    % extract metric
                    if isfield(base, metric)
                        results(s,avg,sbj,c) = base.(metric);
                    end
                end
            end
        end
    end
end
