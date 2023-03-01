
function [models] = computeBaseModels(configs)
%COMPUTEBASEMODELS Compute and validate trainig model and filters
%   Computes the model used in the clinical trial, using naive bayes
%   classifier to select the best Max-SNR Beamformer and Fisher's 
%   criterion (FC) Beamformer filters as in Pires et al. (2011) "Statistical 
%   spatial filtering for a P300-based BCI: Tests in able-bodied, and
%   patients with cerebral palsy and amyotrophic lateral sclerosis"
%
%   Input:
%   configs - structure with info about the experiemental conditions (see getCofigs)
%
%   Output:
%   models - structures with

        
models = cell(1, configs.NAVGS);



% load data
EEG_T1 = loadEEGData(configs, 'Train1', -0.2, 1.2);
EEG_T2 = loadEEGData(configs, 'Train2', -0.2, 1.2);


weights = computeSlowFluctuationsWeights(EEG_T1);
EEG_T1_c = correctSlowFluctuations(EEG_T1, weights);


parfor avg = 1:configs.NAVGS
    % average and normalize
    EEG_T1_avg = averageTrials(EEG_T1, avg);
    EEG_T1_zscored = normalizeTrials(EEG_T1_avg, 'zscore');

    % average and normalize
    EEG_T2_avg = averageTrials(EEG_T2, avg);
    EEG_T2_zscored = normalizeTrials(EEG_T2_avg, 'zscore');
    
    % compute best_model
    model = findBestModel(EEG_T1_zscored, EEG_T2_zscored);
    
    fprintf('[%d] accuracy: %.2f\n', avg, model.metrics.accuracy);
    models{avg} = model;
end


end