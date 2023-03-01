% setup path
addpath(genpath('.'));
rmpath(genpath('.git'));

%% load configs
configs = getConfigs();
configs.system = 'Nauti';
configs.BCIAUTPATH = 'D:\\OneDrive - Universidade de Coimbra\\BCIAUT_Data\\';
configs.DATAPATH = configs.BCIAUTPATH;

configs.subject_list = ([1 3:8 10:17]);


% phase I

COMPETITION_LABELS = [];


output_path = 'D:\\MEDICON\\kaggle\\';
mkdir(output_path);
for sbj=1:length(configs.subject_list)
    subject_path = sprintf('%sSBJ%02d\\', output_path, sbj);
    mkdir(subject_path)
    for sess = 1:7
        
        % prepare path
        session_path = sprintf('%sS%02d\\', subject_path, sess);
        train_path = sprintf('%s\\Train\\',session_path);
        test_path = sprintf('%s\\Test\\',session_path);
        
        % create folders
        mkdir(session_path)
        mkdir(train_path);
        mkdir(test_path);
        
        % prepare info
        configs.subject = sprintf('BCI%02d',configs.subject_list(sbj));
        configs.session = sess;
        
        % load data
        EEG_T1 = loadEEGData(configs, 'Train1', -0.2, 1.2);
        EEG_T2 = loadEEGData(configs, 'Train2', -0.2, 1.2);
        
        
        % combine both trains
        trainData = cat(3, EEG_T1.data, EEG_T2.data);
        trainEvents = cat(1, EEG_T1.labels, EEG_T2.labels);
        trainTargets = cat(1, EEG_T1.isTarget, EEG_T2.isTarget);
        trainLabels = cat(1, EEG_T1.labels(EEG_T1.isTarget), EEG_T2.labels(EEG_T2.isTarget));
        trainLabels = trainLabels(1:10:end);
        
        save(sprintf('%strainData.mat', train_path), 'trainData');
        dlmwrite(sprintf('%strainEvents.txt', train_path), trainEvents);
        dlmwrite(sprintf('%strainTargets.txt', train_path), trainTargets); 
        dlmwrite(sprintf('%strainLabels.txt', train_path), trainLabels);
        
        EEG_BCI = loadEEGData(configs, 'BCI', -0.2, 1.2);
        testData = EEG_BCI.data;
        testEvents = EEG_BCI.labels;
        testTargets = EEG_BCI.isTarget;
        
        runs_per_block = EEG_BCI.nTrials;
        
        
        testLabels = EEG_BCI.labels(EEG_BCI.isTarget);
        testLabels = testLabels(1:runs_per_block:end);
        
        
        COMPETITION_LABELS = [COMPETITION_LABELS ; sbj sess testLabels'];
        save(sprintf('%stestData.mat', test_path), 'testData');
        dlmwrite(sprintf('%stestEvents.txt', test_path), testEvents);
        dlmwrite(sprintf('%sruns_per_block.txt', test_path), runs_per_block);
        dlmwrite(sprintf('%stestTargets.txt', test_path), testTargets); 
        dlmwrite(sprintf('%stestLabels.txt', test_path), testLabels);
        
        
    end
end


