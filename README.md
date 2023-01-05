# NestedCVML_matlab
Machine Learning methods implementing nested cross validation in Matlab

This code can be used and changed by third-parties. However, at least one of those two papers (or both) must be cited as this code was partly developed for:

Pujadas, E.R., Raisi-Estabragh, Z., Szabo, L. et al. Atrial fibrillation prediction by combining ECG markers and CMR radiomics. 
Sci Rep 12, 18876 (2022). https://doi.org/10.1038/s41598-022-21663-w

Pujadas ER, Raisi-Estabragh Z, Szabo L, McCracken C, Morcillo CI, Campello VM, Martín-Isla C, Atehortua AM, Vago H, Merkely B, 
Maurovich-Horvat P, Harvey NC, Neubauer S, Petersen SE, Lekadir K. Prediction of incident cardiovascular events using machine learning 
and CMR radiomics. Eur Radiol. 2022 Dec 13. doi: 10.1007/s00330-022-09323-z. Epub ahead of print. PMID: 36512045.



Minimum requirements:
Matlab 2021a (without fairness)
Matlab 2022a (with fairness)

Dependencies (only if you need additional features)
-for kappa and f1_score)
https://es.mathworks.com/matlabcentral/fileexchange/60900-multi-class-confusion-matrix
- for smote 
https://es.mathworks.com/matlabcentral/fileexchange/70315-smote-over-sampling?s_tid=srchtitle

The use of this code is very simple. An example is the following:

[feat_reduced_all, Measurements_test_all, classifier_best_AFA_all,TableScores_all,TableFairnessbySex,TableFairnessbyAge] = TrainingFeatureTableNested(TableFeatures,method_feature_selection,num_feats,iscor_removed,ismote);

Parameters:
-method_feature_selection: 
  "chi": Chi-Squared test
  "bs": Backward-feature selection
  "scmrmr":  minimum redundancy maximum relevance (MRMR)
  other: forward feature selection
-num_feats: number of features to select in the feature selection
-iscor_removed: if the correlated variables must be removed
-ismote: if you want to incorporate upsampling in the minority class (check dependencies if you want to use it)

Output:
- feat_reduced_all: feature selection result
- Measurements_test_all: It contains all the performance measurements
- classifier_best_AFA_all: the best classifier
- TableScores_all: used only for chi-squared test to obtain the scores of each feature
- TableFairnessbySex,TableFairnessbyAge: only used if the fairness is available



