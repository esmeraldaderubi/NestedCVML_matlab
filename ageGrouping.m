
%%%%%%%%%%%%%%%%%%%%%%%%
%%%  grouping by Age  %%
%%%%%%%%%%%%%%%%%%%%%%%%

RiskFactors = readtable('CMR_Radiomics_32k_V2.xlsx');
groupingAge = zeros(1,size(RiskFactors,1));

%Prevalence of diagnosed atrial fibrillation in adults: national implications for 
% rhythm management and stroke prevention: the AnTicoagulation and Risk Factors in
%Atrial Fibrillation (ATRIA) Study
%Prevalence increased from 0.1% among adults younger than 55 years 
index = find(RiskFactors.cov_age0<55);
groupingAge(index)= 1;


index = find(RiskFactors.cov_age0>=55 & RiskFactors.cov_age0<65 );
groupingAge(index)= 2;

%The prevalence of AF is 2.3 in people older than 40 years and 5.9
%in those older than 65 years. 
%Approximately 70% of individuals with AF are between 65 and 85 years of age.
index = find(RiskFactors.cov_age0>=65 & RiskFactors.cov_age0<=85 );
groupingAge(index)= 3;

RiskFactors.groupAge =  groupingAge';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  grouping by Sex Age  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

groupingSexAge = zeros(1,size(RiskFactors,1));
index = find(RiskFactors.cov_age0<55 & RiskFactors.cov_sex==0);
groupingSexAge(index)= 1;
index = find(RiskFactors.cov_age0<55 & RiskFactors.cov_sex==1);
groupingSexAge(index)= 2;

index = find(RiskFactors.cov_age0>=55 & RiskFactors.cov_age0<60 & RiskFactors.cov_sex==0 );
groupingSexAge(index)= 3;
index = find(RiskFactors.cov_age0>=55 & RiskFactors.cov_age0<60 & RiskFactors.cov_sex==1 );
groupingSexAge(index)= 4;

index = find(RiskFactors.cov_age0>=60 & RiskFactors.cov_sex==0);
groupingSexAge(index)= 5;

index = find(RiskFactors.cov_age0>=60 & RiskFactors.cov_sex==1);
groupingSexAge(index)= 6;

RiskFactors.groupSexAge =  groupingSexAge';


writetable(RiskFactors,'RiskFactors.csv');