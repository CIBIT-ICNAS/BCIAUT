function [pFeatures] = binarizeFeatures(features, method, nLevels)
    
    if nargin < 2
        method = 'thermometer';
    end
    if nargin < 3
        nLevels = 5;
    end
    
    [nsamples, nfeats] = size(features);
    
    pFeatures = zeros(nsamples, nfeats * nLevels);

    for f = 1:nfeats
        if strcmpi(method, 'thermometer')
            featData = thermometerize(squeeze(features(:, f)), nLevels);
            pFeatures(:, (f-1)*nLevels+1: f*nLevels) = featData;
        end
    end
    

end