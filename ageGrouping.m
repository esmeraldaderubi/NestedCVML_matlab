%%%%%%%%%%%%%%%%%%%%%%%%
%%%  grouping by Age  %%
%%%%%%%%%%%%%%%%%%%%%%%%

RiskFactors = readtable('CMR_Radiomics_32k_V2.xlsx');
groupingAge = zeros(1,size(RiskFactors,1));
index = find(RiskFactors.cov_age0<50);
groupingAge(index)= 1;

index = find(RiskFactors.cov_age0>=50 & RiskFactors.cov_age0<65 );
groupingAge(index)= 2;

index = find(RiskFactors.cov_age0>=65 );
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