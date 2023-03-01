function [EEG_corrected] = correctSlowFluctuations(EEG, weights)
%correctSlowFluctuations Removes the impact of slow fluctuations on the EEG
%trials
%   As reported by Ribeiro and Castelo-Branco (2022)
%   https://elifesciences.org/articles/75722 slow fluctuations of EEG data
%   can conceal the ERP. A correction is proposed on the article that uses
%   instantaneous phase and amplitude at the baseline as a regressor to
%   remove its impact on the signal. This functions applies those weights
%   (pre-computed) to the EEG trials in the form: 
%   EEG_corrected.data(ch,time,trial) = EEG.data(ch,time,trial) - weights(ch,time,0) 
%   - bsl_amp(ch,trial)*cos(bsl_phase(ch,trial))*weights(ch,time,1)
%   - bsl_amp(ch,trial)*sin(bsl_phase(ch,trial))*weights(ch,time,2)


EEG_corrected = EEG;

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



for ch=1:chans
    for t=1:nsamples
        for trial=1:trials
            EEG_corrected.data(ch,t,trial) = EEG.data(ch,t,trial) - weights(ch,t,1) ...
                - bsl_amp(ch,trial)*cos(bsl_phase(ch,trial))*weights(ch,t,2) ...
                - bsl_amp(ch,trial)*sin(bsl_phase(ch,trial))*weights(ch,t,3);
        end
    end
end