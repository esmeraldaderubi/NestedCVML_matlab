%[idsWithPropScoreFeats] =  propensityScore('AFA','All',true);
function [idsWithPropScoreFeats] =  propensityScore(disease_str,isSuperHealthyCohort)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extraction of features for INCIDENT DISEASE (e.g,AFA,MI,SK,HF) to create the following models:
%- Risk factors
%- Standard CMR indices
%- Radiomics
%- Radiomics + RF
%- Radiomics + SCMR indices 
%- Standard CMR indices + cardiovascular risk factors
%- Radiomics + SCMR indices + cardiovascular risk factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disease_str = upper(disease_str);
if(~(strcmp(disease_str,'AFA' )==1  || strcmp(disease_str,'MI' )==1  || strcmp(disease_str,'SK' )==1 || strcmp(disease_str,'HF' )==1 || strcmp(disease_str,'R03_Hypertension' )==1  || strcmp(disease_str,'R01_Diabetes' )==1 ))
  fprintf('The argument is wrong: It should be uppercase as: MI, AFA, SK, HF, R03_Hypertension and R01_Diabetes\n');
  return;
end


filespath = '../../../excels/';
T = readtable(strcat(filespath,'radiomics_outcomes_32K.xlsx'));
%Remove NANs from the table which are empty cells
for i= 1: width(T)
    if(isnumeric(T.(i)))
      T.(i)(isnan(T.(i))) = 0;
    end
end  

%%% Remove the patients out of the study because they gave up %%%
%%% Information given by Cel                                  %%%
toDelete = (str2num(cell2mat(T.f_eid)) == 1676083 | str2num(cell2mat(T.f_eid)) ==2211094 | str2num(cell2mat(T.f_eid)) ==5918867) ;
T(toDelete,:) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cardiovascular risk factors %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Select the rows with patients with incident AF
%That is, they got AF after imaging (status_2). If it has
%AFA_status_4=1 automatically AFA_status_2=0
Colname = strcat(disease_str,'_status_2');
ColIndex_status_2 = find(strcmp(T.Properties.VariableNames, Colname), 1);
%IndexAF = T.AFA_status_2 == 1;
IndexCVD = T.(ColIndex_status_2) == 1;
TableWithCVD = T(IndexCVD,:);


%Select the features
%CLASS 1: Prevalent CVD Disease (AFA, MI,HF,SK)
%CLASS 2: Control or healthy
eval = ones(size(TableWithCVD,1),1);
CVDpatientsTable = table(eval,TableWithCVD.f_eid);
CVDpatientsTable.Properties.VariableNames = {'Eval','f_eid'};
CVDpatientsTable.f_eid = str2num(cell2mat(CVDpatientsTable.f_eid ));

%We are only interested in the ECGs that have rest test
ECGsRestIds = readtable('Angelica_ECGMeasurementsFromCardiologistTable.csv');
ECGsRestIds = flip(ECGsRestIds);
ECGsRestIds = table(ECGsRestIds .f_eid);
ECGsRestIds.Properties.VariableNames = {'f_eid'};
CVDpatientsTable = innerjoin(ECGsRestIds,CVDpatientsTable,'Keys','f_eid');


Colname = strcat(disease_str,'_status_2');
ColIndex_status_2 = find(strcmp(T.Properties.VariableNames, Colname), 1);
ColIndex_status_4 = ColIndex_status_2+1;

IndexHealthy = T.(ColIndex_status_2)==0 & T.(ColIndex_status_4)==0;
TableWithNonCVDPatients = T(IndexHealthy,:);

%If you want super-healthy replace the previous healthy cohort
if(isSuperHealthyCohort)
    IndexHealthy = T.CVD_any_status_2==0 & T.CVD_any_status_4==0 & T.SK_status_2==0 & T.SK_status_4==0;
    TableWithNonCVDPatients = T(IndexHealthy,:);
end

%We want normal sinus in ECGs so that it does not hide any CVD
%ECGNormalSinus2 checks normal sinus in diagnosis
%ECGNormalSinus check if abnormal is all leads
normalSinus = readtable("ECGNormalSinus2.csv");
normalSinus.Properties.VariableNames = {'f_eid'};
TableWithNonCVDPatients.f_eid = str2num(cell2mat(TableWithNonCVDPatients.f_eid ));
TableWithNonCVDPatients = innerjoin(normalSinus, TableWithNonCVDPatients,'Keys','f_eid');


%Select the features
%Eval = 1 equivalent to AF, Eval= 2 equivalent to Healthy
eval = ones(size(TableWithNonCVDPatients,1),1)*2;
NonCVDpatientsTable.Eval = uint8(eval);
NonCVDpatientsTable = table(NonCVDpatientsTable.Eval,TableWithNonCVDPatients.f_eid);
NonCVDpatientsTable.Properties.VariableNames = {'Eval','f_eid'};


%Join the populationn
TableAllpopulationAFvsNonCV = [CVDpatientsTable;NonCVDpatientsTable];


RiskFactorsTable = readtable(strcat(filespath,'CMR_Radiomics_32k_V2.xlsx'),'Sheet','Clinical');
RFpropscore = table(RiskFactorsTable.f_eid,RiskFactorsTable.cov_age0,RiskFactorsTable.cov_sex);
RFpropscore.Properties.VariableNames = {'f_eid', 'age', 'sex'};
RFpropscore.f_eid = str2num(cell2mat(RFpropscore.f_eid ));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% population + risk factors                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idsWithPropScoreFeats = innerjoin(TableAllpopulationAFvsNonCV,RFpropscore,'Keys','f_eid');
idsWithPropScoreFeats.Eval(idsWithPropScoreFeats.Eval == 2) = 0;
idsWithPropScoreFeats.Properties.VariableNames = {'f_eid', 'Y', 'age', 'sex'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ids that we have atrials visible           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

atrialsRadsIds = readtable(strcat(filespath,'TableAtrialRadiomicsNay.csv'));
atrialsRadsIds = table(atrialsRadsIds.f_eid);
atrialsRadsIds.Properties.VariableNames = {'f_eid'};
idsWithPropScoreFeats = innerjoin(idsWithPropScoreFeats,atrialsRadsIds,'Keys','f_eid');

writetable(idsWithPropScoreFeats,'idsBeforePropScoreFeats.csv');
