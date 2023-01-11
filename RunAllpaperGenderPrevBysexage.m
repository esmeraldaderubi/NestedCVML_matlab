% cd 'paper3_byageandsex\general'
%load('mats_new_controls/TableECGOnly.mat');
load('mats_new_controls/TableRadiomicsFeatures.mat');
%load('mats_new_controls/TableElectroRadiomicsFeatures.mat');
TableExposome = readtable('mats_new_controls/exposome_20_mf_final.csv');
TableBlood = readtable('mats_new_controls/blood_20_mf_final.csv');
Table12ECGFeatsByCardiologist = readtable('mats_new_controls/ECGMeasurementsFromXmlTable_Marina.csv');

iscor_removed = false;
is_smote = false;

cd 'C:\Users\esmeralda.ruiz\Desktop\UB Project\Disease Models\Task3_Train and classify\\paper4_prevalent\'

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Radiomics model          %
%%%%%%%%%%%%%%%%%%%%%%%%%%% 

TableRadiomicsWithAtrial_AFsameN = RemoveUnwantedFeaturesRadiomics(TableRadiomicsFeatures);
[feat_reduced_AFA_RadsAtrial_all, Measurements_test_AFA_RadsAtrial_all, classifier_best_AFA_RadsAtrial_all,TableScores_AFA_RadsAtrial_all,TableFairnessbySex_RadsAtrial,TableFairnessbyAge_RadsAtrial,TableFairnessbySexAge_RadsAtrial] = TrainingFeatureTableNested(TableRadiomicsWithAtrial_AFsameN,'chi',30,iscor_removed,is_smote);


OutcomeIds = table(TableRadiomicsWithAtrial_AFsameN.f_eid,TableRadiomicsWithAtrial_AFsameN.Eval);
OutcomeIds.Properties.VariableNames = {'f_eid','Eval'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ECG features obtained by radiologists %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Table12ECGFeatsByCardiologist = removevars(Table12ECGFeatsByCardiologist, "years");
Table12LeadsECG = innerjoin(OutcomeIds,Table12ECGFeatsByCardiologist, 'Keys','f_eid');
namesECGs = Table12LeadsECG.Properties.VariableNames;
Table12LeadsECG = table2array(Table12LeadsECG);
Table12LeadsECG(Table12LeadsECG == -1000) = NaN;
Table12LeadsECG = knnimpute(Table12LeadsECG);
Table12LeadsECG = array2table(Table12LeadsECG);
Table12LeadsECG.Properties.VariableNames = namesECGs;
[feat_reduced_AFA_12LeadsECG_all, Measurements_test_AFA_12LeadsECG_all,classifier_best_AFA_12LeadsECG_all,TableScores_AFA_12LeadsECG_all,TableFairnessbySex_12LeadsECG,TableFairnessbyAge_12LeadsECG,TableFairnessbySexAge_12LeadsECG] = TrainingFeatureTableNested(Table12LeadsECG,'chi',17,iscor_removed,is_smote);
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ElectroRadiomics model   %
%%%%%%%%%%%%%%%%%%%%%%%%%%% 
TablelectroRad12LeadsECG = innerjoin(Table12LeadsECG , TableRadiomicsWithAtrial_AFsameN,'Keys',{'f_eid','Eval'});
[feat_reduced_AFA_Rad12LeadsECG_all, Measurements_test_Rad12LeadsECG_all,classifier_best_Rad12LeadsECG_all,TableScores_Rad12LeadsECG_all,TableFairnessbySex_Rad12LeadsECG,TableFairnessbyAge_Rad12LeadsECG,TableFairnessbySexAge_Rad12LeadsECG] = TrainingFeatureTableNested(  TablelectroRad12LeadsECG ,'chi',30,iscor_removed,is_smote);
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blood test (normal)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%TableBlood = innerjoin(OutcomeIds , TableBlood  ,'Keys',{'f_eid'});
%[feat_reduced_AFA_Blood_all, Measurements_test_AFA_Blood_all, classifier_best_AFA_Blood_all,TableScores_AFA_Blood_all,TableFairnessbySex_Blood,TableFairnessbyAge_Blood,TableFairnessbySexAge_Blood] = TrainingFeatureTableNested(TableBlood,'chi',29, iscor_removed,is_smote);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Exposome                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% TableExposome = innerjoin(OutcomeIds , TableExposome  ,'Keys',{'f_eid'});
% 
% [features_best_Exposome, Measurements_test_Exposome,classificationSVM_best_Exposome,TableScores_Exposome] = TrainingFeatureTableNestedRF(TableExposome ,'chi',iscor_removed,false,30,false);
% 
% mean_TableFairnessbySex_Exposome = mean(table2array(TableFairness_Exposome));
% mean_TableFairnessbySex_Exposome = array2table( mean_TableFairnessbySex_Exposome);
% mean_TableFairnessbySex_Exposome.Properties.VariableNames = {'mean_StatisticalParityDifference', 'mean_DisparateImpact', 'mean_EqualOpportunityDifference', 'mean_AverageAbsoluteOddsDifference','mean_GroupCount_female', 'mean_GroupSizeRatio_female','mean_Accuracy_female','mean_FalsePositiveRate_female','mean_FalseNegativeRate_female' ,'mean_GroupCount_male', 'GroupSizeRatio_male','mean_Accuracy_male','mean_FalsePositiveRate_male','mean_FalseNegativeRate_male' };
%        
% std_TableFairnessbySex_Exposome = std(table2array(TableFairness_Exposome));
% std_TableFairnessbySex_Exposome = array2table( std_TableFairnessbySex_Exposome);
% std_TableFairnessbySex_Exposome.Properties.VariableNames = {'std_StatisticalParityDifference', 'std_DisparateImpact', 'std_EqualOpportunityDifference', 'std_AverageAbsoluteOddsDifference','std_GroupCount_female', 'std_GroupSizeRatio_female','std_Accuracy_female','std_FalsePositiveRate_female','std_FalseNegativeRate_female' ,'std_GroupCount_male', 'GroupSizeRatio_male','std_Accuracy_male','std_FalsePositiveRate_male','std_FalseNegativeRate_male' };
%  

 