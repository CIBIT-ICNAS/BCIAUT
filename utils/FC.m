function [ W1 ] = FC( EEG, theta )
%FC Calculates the FC filter for the given teta.
%   Detailed explanation goes here

nclass = 2; numCh = size(EEG.data, 1);
classData = {EEG.data(:,:,EEG.isTarget) EEG.data(:,:,~EEG.isTarget)};
classMean = {mean(classData{1},3) mean(classData{2},3)};
allMean = mean(EEG.data, 3);
classP = {sum(EEG.isTarget)/length(EEG.isTarget) sum(~EEG.isTarget)/length(EEG.isTarget)};

Sb = zeros(numCh, numCh);
Sw = zeros(numCh, numCh);
for i = 1:nclass
    Sb = Sb + classP{i}*(classMean{i}-allMean)*(classMean{i}-allMean)'; %  spatial between-class scatter matrix
    for k = 1:size(classData{i}, 3)
        Sw = Sw + (classData{i}(:,:,k)-classMean{i})*(classData{i}(:,:,k)-classMean{i})'; % spatial within-class scatter matrix
    end
end


Sw = (1-theta)*Sw + theta*eye(size(Sw)); % Regularization

sumR = Sw + Sb;

%   Find Eigenvalues and Eigenvectors of R
%   Sort eigenvalues in descending order
[EVecsum,EValsum] = eig(sumR);
[EValsum,ind] = sort(diag(EValsum),'descend');
EVecsum = EVecsum(:,ind);

%   Find Whitening Transformation Matrix - Ramoser Equation (3)
P = sqrt(inv(diag(EValsum))) * EVecsum';


Sw = P * Sw * P'; % Whiten Data
Sb = P * Sb * P'; % Whiten Data


S = Sw\Sb;

[B,~] = eig(S);
% [D,ind]=sort(diag(D),'descend');
% B=B(:,ind);

W1 = B'*P;

end

