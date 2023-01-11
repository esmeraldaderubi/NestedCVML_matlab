function TableRadiomicsFeatures =  RemoveUnwantedFeaturesRadiomics(TableRadiomicsFeatures) 
    
    %Remove first order variables of LV and RV because it contains blood and
    %it might distort the results
    TableRadiomicsFeatures(:,81:152) = [];
    %Remove texture for LV and RV for each matrix
    TableRadiomicsFeatures(:,116:207) = [];
    TableRadiomicsFeatures(:,162:225) = [];
    TableRadiomicsFeatures(:,194:257) = [];
    TableRadiomicsFeatures(:,226:245) = [];
    TableRadiomicsFeatures(:,236:291) = [];

%     %Remove unwanted features
%     %radiomics shape features from all three ROIs: LV, RV, and MYO.
%     %radiomics first-order features from MYO only (NOT LV or RV)
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_firstorder');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_firstorder');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     %radiomics texture features from MYO only (NOT LV or RV)
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_gcm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_gcm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_gldm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_gldm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_glrlm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_glrlm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_glszm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_glszm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_glcm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_glcm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'LV_ngtdm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
%     index = strfind(TableRadiomicsFeatures.Properties.VariableNames,'RV_ngtdm');
%     tf = cellfun('isempty',index); % true for empty cells
%     index(tf) = {0}; %set to 0 true
%     index = logical(cell2mat(index));
%     TableRadiomicsFeatures(:,index) = [];
