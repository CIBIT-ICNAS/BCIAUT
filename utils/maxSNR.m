function [W2] = maxSNR(EEG, alpha)
%[Inputs]%:
%    EEGdata: the input EEG data for training, a 3D array with size [numCh, numT, nTrl]
%
%       numCh is the number of channels
%       numT is the number of samples in each channle
%       nTrl is the number of trails for training
%
%    LABELS: the ground truth class labels for the nTrl trials, size nTrl x 1

numCh = size(EEG.data,1);

classData = { EEG.data( :,:,EEG.isTarget ) EEG.data( :,:,~EEG.isTarget ) };

meanR = cell( length(classData), 1 );
for i=1:length(classData)
    % Sample covariance matrix for the i class
    R=zeros(numCh,numCh,size(classData{i}, 3)); 
    for trial=1:size(classData{i}, 3)
        E=classData{i}(:,:,trial);
        tmpC = (E*E');
        R(:,:,trial) = tmpC/trace(tmpC); % normalization
    end
    meanR{i}=mean(R, 3);
end
meanR{1} = (1-alpha)* meanR{1} + alpha*eye(size(meanR{1}));
sumR = meanR{2} + meanR{1};

% 
%   Find Eigenvalues and Eigenvectors of R
%   Sort eigenvalues in descending order
[EVecsum,EValsum] = eig(sumR);
[EValsum,ind] = sort(diag(EValsum), 'descend');
EVecsum = EVecsum(:,ind);

%   Find Whitening Transformation Matrix - Ramoser Equation (3)
P =   sqrt(inv(diag(EValsum))) * EVecsum';

for k = 1:2
    S{k} = P * meanR{k} * P'; % Whiten Data Using Whiting Transform - Ramoser Equation (4)
end

% Ramoser equation (5)
% [U{1},Psi{1}] = eig(S{1});
% [U{2},Psi{2}] = eig(S{2});
%  Psi{1}+Psi{2}
S = S{1}\S{2};
%generalized eigenvectors/values
[B,~] = eig(S);
% [D,ind]=sort(diag(D),'descend');
% B=B(:,ind);
% Simultanous diagonalization
% Should be equivalent to [B,D]=eig(S{1});

%Resulting Projection Matrix-these are the spatial filter coefficients
W2 = B'*P;


end
