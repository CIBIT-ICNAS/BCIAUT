# BCIAUT
Classification analysis for the BCIAUT clinical trial - a P300-based Brain-Computer Interface for training joint-attention in autism spectrum disorder.

## Libs
Classification is performed with toolbox PRTools (version 4.2.5)

## Usage

Setup configs using 
```matlab
configs = getConfigs();
````

Specify a subject and session
```matlab
configs.subject = X;
configs.session = Y;
````

Compute model used in BCIAUT clinical trial
```matlab
base_models = computeBaseModels(configs);
````


Compute new models using the same filters
```matlab
new_models = computeNewModels(configs, base_models);
````


## Credits

November 2017
Creators Marco Simoes (msimoes@dei.uc.pt) and Carlos Amaral.




