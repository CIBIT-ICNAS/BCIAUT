function [weights] = computeSlowFluctuationsWeights(EEG)
%computeSlowFluctuationsWeights Computes the beta values of slow fluctuations 
%impact on the EEG trials
%   As reported by Ribeiro and Castelo-Branco (2022)
%   https://elifesciences.org/articles/75722 slow fluctuations of EEG data
%   can conceal the ERP. A correction is proposed on the article that uses
%   instantaneous phase and amplitude at the baseline as a regressor to
%   remove its impact on the signal. This functions computes those weights
%   as a regression of the form 
%   EEG.data(ch,time,trial) = weights(ch,time,0) 
%   + bsl_amp(ch,trial)*cos(bsl_phase(ch,trial))*weights(ch,time,1)
%   + bsl_amp(ch,trial)*sin(bsl_phase(ch,trial))*weights(ch,time,2)
%   + error(ch, time, trial)


% get slow fluctuations by conducting a lowpass filter at 3Hz
EEG_sf = pop_eegfiltnew(EEG, 'hicutoff',3,'plotfreqz',0);
[chans, nsamples, trials] = size(EEG.data);


% get amplityde and phase for all channels and trials at time=0
bsl_idx = 50; %0.200s*250hz
bsl_amp = nan(chans, trials);
bsl_phase = nan(chans, trials);

for ch=1:chans
    for trial=1:trials
        y = hilbert(squeeze(EEG_sf.data(ch,:,trial)));
        bsl_amp(ch, trial) = abs(y(bsl_idx));
        bsl_phase(ch, trial) = angle(y(bsl_idx));
    end
end


% compute the weights
weights = nan(ch,nsamples, 3);
for ch=1:chans
    for t=1:nsamples
        weights(ch,t,:) = regress(squeeze(EEG.data(ch,t,:)), [ones(trials,1), ...
            squeeze(bsl_amp(ch,:).*cos(bsl_phase(ch,:)))', ...
            squeeze(bsl_amp(ch,:).*sin(bsl_phase(ch,:)))']);
    end
end