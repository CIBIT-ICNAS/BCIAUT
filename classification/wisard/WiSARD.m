classdef WiSARD < handle
    properties
        discriminators
        classes
        nmemories
        nbits
        bits_order
        use_map
        maxcount
        priors
    end
    
    methods
        % Constructor
        function obj = WiSARD(classes, input_size, nbits, bits_order, use_map)
            if nargin < 3
                error('Not enough input arguments');
            end
            if nargin < 4 || isempty(bits_order)
                rng(1); % seed for reproduceability
                bits_order = randperm(input_size);
            end
            if nargin < 5 || isempty(use_map)
                use_map = 2^nbits * (input_size / nbits) * length(classes) > 1E8;
            end
            
            obj.classes = classes;
            obj.nbits = nbits;
            obj.nmemories = ceil(input_size / nbits);
            obj.use_map = use_map;
            
            for c = 1:length(classes)
                if obj.use_map == 1
                    obj.discriminators{c} = cell(1, obj.nmemories);
                    for m = 1:obj.nmemories
                        obj.discriminators{c}{m} = containers.Map('KeyType','uint32','ValueType','double');
                    end
                else
                    obj.discriminators{c} = zeros(obj.nmemories, 2^obj.nbits);
                end
            end
            
            obj.bits_order = bits_order;
            
            obj.priors = ones(1, length(classes));
            obj.maxcount = 0;
        end
        
        
        
        function fit(obj, data, classes)
            data = obj.shuffleData( data );
            obj.priors = hist(cell2mat(classes), length(unique(cell2mat(classes))));
            
            % transform bit streams into memory addresses
            dataAddr = obj.bin2Addr( data );
            
            if obj.use_map == 1
                obj.fitMap(dataAddr, classes);
            else
                obj.fitMatrix(dataAddr, classes);
            end
            
            
            
            
        end
        
        function fitMap(obj, dataAddr, classes)
            for i = 1:size(dataAddr, 1)
                %disc_idx = strcmp(obj.classes, classes{i});
                disc_idx = find([obj.classes{:}] == classes{i});
                for m = 1:obj.nmemories
                    addr = dataAddr(i, m);
                    value = WiSARD.mapGet(obj.discriminators{disc_idx}{m}, addr) + 1/obj.priors(disc_idx);
                    obj.discriminators{disc_idx}{m}(addr) = value;
                    
%                     if value > obj.maxcount
%                         obj.maxcount = value;
%                     end
                end
            end
        end
        
        
        function fitMatrix(obj, dataAddr, classes)
            for i = 1:size(dataAddr, 1)
                %disc_idx = strcmp(obj.classes, classes{i});
                disc_idx = find([obj.classes{:}] == classes{i});
                
                idxs = dataAddr(i, :) * obj.nmemories + [1:obj.nmemories];
                obj.discriminators{disc_idx}(idxs) = obj.discriminators{disc_idx}(idxs) + 1/obj.priors(disc_idx);
            end
            
            %obj.getMaxCount();
        end
        
        
        function cleanZeros(obj)
            for c = 1:length(obj.classes)
                if obj.use_map == 0
                    obj.discriminators{c}(:, 1) = 0;
                else
                    for m = 1:obj.nmemories
                        obj.discriminators{c}{m}(1) = 0;
                    end
                end
            end
            %obj.getMaxCount();
        end
        
        function [y, totals, results] = predict(obj, data, ytarget)
            
            % todo check this!
            dataAddr = obj.bin2Addr( obj.shuffleData( data ) );
            
            if obj.use_map == 1
                results = obj.predictMap(dataAddr);
            else
                results = obj.predictMatrix(dataAddr);
            end
            
            
            confidences = [];
            
            % bleaching
            NTRESHOLDS = 100;
            b = [];            
            b(1,1,1:NTRESHOLDS) = [1:NTRESHOLDS] * .5 ./ NTRESHOLDS;
                        
            indexes = [size(results) 1];
            indexes(1) = [];
            
            b = repmat(b, indexes);
            totals = nan(size(results, 1), size(results, 2));
            
            for i = 1:size(results, 1)
                tmp = repmat(squeeze(results(i, :, :)), 1,1,NTRESHOLDS);
                tmp = tmp > b;
            
                tmptotals = squeeze(sum(tmp, 2));
            
                confidence = squeeze(abs((tmptotals(1, :) - tmptotals(2, :) )) ./ obj.nmemories);
                [~, idxs] = sort(confidence, 'descend');
                totals(i, :) = tmptotals(:,idxs(1));
                
                confidences(i, :) = confidence;
            end
            
            
            % classification
            [~, idxs] = max(totals, [], 2);
            
            y = cell(1, length(idxs));
            for i = 1:length(idxs)
                y{i} = obj.classes{idxs(i)};
            end
        end
        
        
        function [results] = predictMap(obj, dataAddr)
            results = zeros( size(dataAddr, 1), length(obj.classes), obj.nmemories );
            
            for i = 1:size(dataAddr, 1)
                for d = 1:length(obj.classes)
                    discriminator = obj.discriminators{d};
                    for m = 1:obj.nmemories
                        results(i, d, m) = WiSARD.mapGet(discriminator{m}, dataAddr(i, m));
                    end
                end
            end
        end
        
        function [results] = predictMatrix(obj, dataAddr)
            results = zeros( size(dataAddr, 1), length(obj.classes), obj.nmemories );
            
            for i = 1:size(dataAddr, 1)
                for d = 1:length(obj.classes)
                    
                    idxs = dataAddr(i, :) * obj.nmemories + [1:obj.nmemories];
                    results(i, d, :) = obj.discriminators{d}(idxs);
                end
            end
        end
        
        
        
        function [data_shuffled] = shuffleData(obj, data)
            data_shuffled = data;
            for i = 1:size(data, 1)
                data_shuffled(i, obj.bits_order) = data(i, :);
            end
        end
        
        
        function [addrData] = bin2Addr(obj, data)
            addrData = zeros(size(data, 1), obj.nmemories);
            
            k = 1;
            squares = 2.^[obj.nbits-1:-1:0];
            for i = 1:obj.nbits:size(data, 2)-obj.nbits
                addrData(:,k) = double(data(:, i:i+obj.nbits-1)) * squares';
                k = k+1;
            end
            
        end
        
        function bleach(obj, method, threshold)
            if nargin < 2
                method = 'logarithm';
            end
            
            if strcmp(method, 'logarithm')
                for d = 1:length(obj.discriminators)
                    obj.discriminators{d}(:) = log( obj.discriminators{d}(:) + 1 );
                end
            elseif strcmp(method, 'threshold')
                allmemories = obj.getMergedDiscriminators();
                %max(allmemories(:))
                threshold = threshold * max(allmemories(:));
                for d = 1:length(obj.discriminators)
                    obj.discriminators{d}(:) = obj.discriminators{d}(:) > threshold;
                    %vals = vals > threshold = vals( vals > threshold ) - threshold;
                    %obj.discriminators{d}(:) = vals;
                    %obj.discriminators{d}(:) =  obj.discriminators{d}(:) / max(allmemories(:));
                    
                end
            elseif strcmp(method, 'discretize')
                for d = 1:length(obj.discriminators)
                    obj.discriminators{d}(:) = discretize(obj.discriminators{d}(:), 4);
                    %obj.discriminators{d}(:) =  obj.discriminators{d}(:) / max(allmemories(:));
                    
                end
            end
        end
        
        
        function [alldiscriminators] = getMergedDiscriminators(obj)
            alldiscriminators = [];
            for d=1:length(obj.discriminators)
                alldiscriminators = cat(1, alldiscriminators, obj.discriminators{d});
            end
        end
        
        function [] = getMaxCount(obj)
            maxes = zeros(1, length(obj.discriminators));
            
            if obj.use_map
                for d=1:length(obj.discriminators)
                    maxmem = zeros(1, length(obj.discriminators{d}));
                    for m = 1:length(obj.discriminators{d})
                        if isempty(values(obj.discriminators{d}{m}))
                            maxmem(m) = 0;
                        else
                            maxmem(m) = max(cell2mat(values(obj.discriminators{d}{m})));
                        end
                    end
                    maxes(d) = max(maxmem);
                end
            else                
                for d=1:length(obj.discriminators)
                    maxes(d) = max(obj.discriminators{d}(:));
                end
            end
            
            obj.maxcount = max(maxes);
            
        end
        
    end
    methods (Static)
        function [val] = mapGet(map, addr)
            val = 0;
            if map.isKey(addr)
                val = map(addr);
            end
        end
    end
end