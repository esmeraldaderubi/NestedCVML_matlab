%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code can be used and changed by third-parties. However, at least one of those two papers or both must be cited as this code was developed for:

%Pujadas, E.R., Raisi-Estabragh, Z., Szabo, L. et al. Atrial fibrillation prediction by combining ECG markers and CMR radiomics. 
%Sci Rep 12, 18876 (2022). https://doi.org/10.1038/s41598-022-21663-w

%Pujadas ER, Raisi-Estabragh Z, Szabo L, McCracken C, Morcillo CI, Campello VM, Martín-Isla C, Atehortua AM, Vago H, Merkely B, 
%Maurovich-Horvat P, Harvey NC, Neubauer S, Petersen SE, Lekadir K. Prediction of incident cardiovascular events using machine learning 
%and CMR radiomics. Eur Radiol. 2022 Dec 13. doi: 10.1007/s00330-022-09323-z. Epub ahead of print. PMID: 36512045.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NESTED CROSS VALIDATION                                     %%
%% Nested All data                                             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [features_best, Measurements_test,classificationSVM_best,TableScores,TableFairnessbySex,TableFairnessbyAge] = TrainingFeatureTableNested(TableFeatures,fs_reduction, num_feats,removecorr,ismote,showGraphs)

    if(nargin ==5)
        showGraphs = false;
    end

    if(isnumeric(num_feats)==0)
        disp('Error in the features');
    end

    FairnessCompEnabled = true;
    TableFairnessbySex =[];
    TableFairnessbyAge = [];
    idx = [];
    scores =[];
    TableScores =[];

  
    keep_featout = [];
    if(removecorr== true)
        highcorrelatedFeats =  removeHighlyCorrelated(TableFeatures);
        keep_featout =[];
        for i=1:size(TableFeatures,2)-2
            if(max(i==highcorrelatedFeats))
                keep_featout = [ keep_featout;true];
            else
                keep_featout = [ keep_featout;false];
            end
        end
        keep_featout= logical(keep_featout)';
    else
        keep_featout = [];
    end     

    if(removecorr== true)
        keep_featout = [false,false,keep_featout];
        TableFeatures(:,keep_featout) = [];
    end

    %remove eval column and f_eid
    Y = TableFeatures.Eval;
    In = table2array(TableFeatures(:,3:end));
    
    
    %Standarazing input
    %In = In-mean(In);
    %In = In./std(In);
     X = In;
    
    
    TableFeaturesNormalized = array2table(X);
    for(i=3:size(TableFeatures,2))
        TableFeaturesNormalized.Properties.VariableNames([i-2]) = TableFeatures.Properties.VariableNames([i]);
    end


    Measurements_test = struct('AUCsvm',[],'validationAccuracy',[],'sensitivity', [],'specificity', [],'F1_score',[],'kappa',[],...
        'mean_AUCsvm',0,'mean_validationAccuracy',0,'mean_sensitivity', 0,'mean_specificity', 0,'mean_F1_score',0,'mean_kappa',0, 'classifier',[],'mean_AUCarray',[],'repetitionsOfFeatures',[]);
        
    Num_it_outer = 10;
    AUC_best = 0;
    classificationSVM_best = 0;
    features_best = 0;

    %num_feats = 30; % 30;

    %%%%%%%%%%%%%%%%%%%%%%%%%
    %% NESTED CV           %%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    rng('default') % For reproducibility
    Testindices = crossvalind('Kfold',Y,Num_it_outer);
    idx_best = [];
    score_best = [];
    features_repetition_nestcv = {};
    matrixFairnessSex_All = [];
    matrixFairnessAge_All = [];
    matrixFairnessSex_byloop = [];
    matrixFairnessAge_byloop = [];

    for outer_loop=1:Num_it_outer
        idxTest = (Testindices == outer_loop); 
        idxTrain = ~idxTest;

        trainingData = TableFeaturesNormalized(idxTrain,:);
        [trainingData, centernorm,stdnorm]= normalize(trainingData);
        responseTrainingData = Y(idxTrain);



     
        %fs_reduction = true;
         switch fs_reduction
            case  'chi'
                %Using Chi-squared for feature selection. 
                [idx,scores] = fscchi2(trainingData,responseTrainingData);
                
                %Identifying the top 20 features
                fs = idx(1:min(size(trainingData,2),num_feats));
                %Later on to select the test set
                feat_reduced = TableFeaturesNormalized(:,fs);
                %To select the training features
                trainingData = trainingData(:,fs);

                Featshown_max = min(size(trainingData,2),num_feats);
                features_repetition_nestcv= [TableFeaturesNormalized.Properties.VariableNames(idx(1:Featshown_max)),features_repetition_nestcv];
                if(showGraphs)
                    %Plot the importance of each feature
                    figure;
                    bar(scores(idx(1:Featshown_max)));
                    set(gca,'xticklabel',strrep(TableFeaturesNormalized.Properties.VariableNames(idx(1:Featshown_max)),'_','\_'))
                    ax=gca;
                    ax.FontSize=8;
                    ax.XTick = [1:Featshown_max];   
                end
            case 'scmrmr'
                %Using  for feature selection. 
                [idx,scores] = fscmrmr(trainingData,responseTrainingData);
                
                %Identifying the top 20 features
                fs = idx(1:min(size(trainingData,2),numfeats));
                %Later on to select the test set
                feat_reduced = TableFeaturesNormalized(:,fs);
                %To select the training features
                trainingData = trainingData(:,fs);

                Featshown_max = min(size(trainingData,2),numfeats);
                features_repetition_nestcv= [TableFeaturesNormalized.Properties.VariableNames(idx(1:Featshown_max)),features_repetition_nestcv];
       
            otherwise
                max_its_fs = num_feats;
                rng('default') % For reproducibility
                c = cvpartition(responseTrainingData,'k',5,'Stratify',true);
                opts = statset('display','iter');
                %optsvmopt =  struct('Optimizer','randomsearch','AcquisitionFunctionName','expected-improvement-plus','showplot',false,'UseParallel',true );
                % ,'OptimizeHyperparameters','all','HyperparameterOptimizationOptions',optsvmopt
                classifierfun = @(train_data,train_labels,test_data,test_labels) ...
                    loss(fitcsvm(train_data,train_labels,'KernelFunction', 'gaussian','KernelScale','auto','Standardize',true),test_data,test_labels,'LossFun', 'ClassifError');
                    %sum(predict(fitcsvm(train_data,train_labels,'KernelFunction', 'gaussian','KernelScale','auto','Standardize',true), test_data) ~= test_labels); 
                   
                [fs,history] = sequentialfs(classifierfun,table2array(trainingData),responseTrainingData,'cv',c,'nfeatures',min(size(trainingData,2),max_its_fs),'options',opts,'keepout',keep_featout);
                [~,idx] = min(history.Crit);
                fs = history.In(idx,:);
                %Later on to select the test set
                feat_reduced = TableFeaturesNormalized(:,fs);
                %To select the training features
                trainingData = trainingData(:,fs);
        end
        
        if(ismote)
            T  = table2array(trainingData);
            %Everytime you run it, the values changes
            [X,C] = smote(T, [] ,5, 'Class', responseTrainingData);
            X = array2table(X);
            X.Properties.VariableNames = trainingData.Properties.VariableNames;
            trainingData = X;
            responseTrainingData = C;
        end
            
    
            
            %%%%%%%%%%%%%%%%%
            %%% Training %%%%
            %%%%%%%%%%%%%%%%%
            
            % Extract predictors and response
            predictors = trainingData;
            response = responseTrainingData;
            
            % Train a classifier
            % This code specifies all the classifier options and trains the
            % classifier.
            %%%replace auto by all to make the whole study with the kernel
            %%%it will overwrite the kernelfuntion (but it takes a while to perform
            %%%the whole study)
            rng("default") % For reproducibility
            c = cvpartition(responseTrainingData,'KFold',5);
            opts = struct('Optimizer','gridsearch','UseParallel',true,'CVPartition',c,'AcquisitionFunctionName','expected-improvement-plus','showplot',false);
            classificationSVM = fitcsvm(...
                predictors, ...
                response, ...
                'KernelFunction','rbf',...
                'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts,'Standardize',true);
            
            
           
            %Transform the scores into posterior probabilities to belong to a class
            classificationSVM = fitPosterior(classificationSVM,...
                trainingData,responseTrainingData);
            
            %%%%%%%%%%%%%%%%
            %Classification%
            %%%%%%%%%%%%%%%%
        
            disp('Performance Measurements of validation set:')
            disp('________________________________________________________\n')
            %idxTest = test(partition);
            
            testingData = feat_reduced(idxTest,:);
            testingData = normalize(testingData, 'center', centernorm(:,fs), 'scale', stdnorm(:,fs));
            testingData_names = TableFeatures(idxTest,:).f_eid;
            responseTestData = Y(idxTest);
            
            %[predictions,score] = predict(classificationSVM,testingData);
            
            [AUCsvm,validationAccuracy,sensitivity,specificity,Xsvm,Ysvm,F1_score,kappa,FairnessStruct] = PerformanceMeasurements(classificationSVM, responseTestData,10,testingData,testingData_names,FairnessCompEnabled);
            
            if(FairnessCompEnabled)
                if(outer_loop==1)
                    matrixFairnessSex_All = zeros(size(FairnessStruct.fairnessSex,1),size(FairnessStruct.fairnessSex,2)-1);
                    matrixFairnessAge_All = zeros(size(FairnessStruct.fairnessAge,1),size(FairnessStruct.fairnessAge,2)-1);
                end

            
                matrixFairnessSex_All = matrixFairnessSex_All+ FairnessStruct.fairnessSex(:,2:end);
                matrixFairnessAge_All = matrixFairnessAge_All+ FairnessStruct.fairnessAge(:,2:end);
    
                matrixFairnessSex_byloop = [FairnessStruct.fairnessSex; matrixFairnessSex_byloop];
                matrixFairnessAge_byloop = [FairnessStruct.fairnessAge; matrixFairnessAge_byloop];
            end

            Measurements_test.AUCsvm = [Measurements_test.AUCsvm;AUCsvm];
            Measurements_test.validationAccuracy = [Measurements_test.validationAccuracy;validationAccuracy];
            Measurements_test.sensitivity = [Measurements_test.sensitivity;sensitivity];
            Measurements_test.specificity = [Measurements_test.specificity;specificity];
            Measurements_test.classifier = {Measurements_test.classifier;classificationSVM};
            Measurements_test.F1_score = [Measurements_test.F1_score;F1_score];
            Measurements_test.kappa = [Measurements_test.kappa;kappa];
            intervals= linspace(0, 1, 100);
            x_adj= adjust_unique_points(Xsvm); %interp1 requires unique points
            if(outer_loop == 1)
                mean_curve= (interp1(x_adj, Ysvm, intervals))/Num_it_outer; 
            else
                mean_curve= mean_curve+ (interp1(x_adj, Ysvm, intervals))/Num_it_outer; 
            end
            
            Measurements_test.mean_AUCarray = mean_curve;
            
           
            fprintf('Auc %.2f in test set \n',AUCsvm);
    
            if(AUCsvm > AUC_best)
                AUC_best = AUCsvm;
                classificationSVM_best = classificationSVM;
                feat_reduced.Eval = Y;
                feat_reduced.f_eid = TableFeatures.f_eid;
                features_best = feat_reduced;
                idx_best = idx;
                score_best = scores;
            end
            
   end
    
         Measurements_test.mean_AUCsvm = mean(Measurements_test.AUCsvm);
         Measurements_test.mean_validationAccuracy = mean(Measurements_test.validationAccuracy);
         Measurements_test.mean_sensitivity = mean(Measurements_test.sensitivity);
         Measurements_test.mean_specificity = mean(Measurements_test.specificity);
         Measurements_test.mean_F1_score = mean(Measurements_test.F1_score);
         Measurements_test.mean_kappa = mean(Measurements_test.kappa);

         %Plot....
         figure; plot(intervals, Measurements_test.mean_AUCarray, 'Color', 'Black', 'LineWidth', 1.0); 
         xlabel('False positive rate'); ylabel('True positive rate');
         
         strlegend = strcat('Mean AUC: ', num2str(Measurements_test.mean_AUCsvm,'%.2f'));
         legend(strlegend); 
         title('ROC curve')


         if(strcmp(fs_reduction,'chi')==1  || strcmp(fs_reduction,'scmrmr')==1 )
             if(showGraphs)
                 %Plot the importance of each feature
                 Featshown_max = num_feats;
                 figure;
                 bar(score_best(idx_best(1:Featshown_max)));
                 set(gca,'xticklabel',strrep(TableFeaturesNormalized.Properties.VariableNames(idx_best(1:Featshown_max)),'_','\_'))
                 ax=gca;
                 ax.FontSize=8;
                 ax.XTick = [1:Featshown_max]; 
             end

             TableScores = TableFeaturesNormalized.Properties.VariableNames(idx_best(1:Featshown_max))';
             TableScores = cell2table(TableScores);
             scores = score_best(idx_best(1:Featshown_max))';
             scores = round(scores,4);
             TableScores.Ranking = scores;
    
    
             %Get how many times each features is repeated in each iteration 
             feats_name_wihtoutreps =unique(features_repetition_nestcv,'stable');
             countRepetitions=cellfun(@(x) sum(ismember(features_repetition_nestcv,x)),feats_name_wihtoutreps,'un',0);
             feats_repetitions=[feats_name_wihtoutreps;countRepetitions];
             Measurements_test.repetitionsOfFeatures = feats_repetitions;
         else
             Measurements_test.features_best= features_best;
         end

         if(FairnessCompEnabled)
             TableFairnessbySex = array2table(matrixFairnessSex_All./Num_it_outer);
             TableFairnessbyAge = array2table(matrixFairnessAge_All./Num_it_outer);
             matrixFairnessSex_byloop = array2table(matrixFairnessSex_byloop);
             matrixFairnessAge_byloop = array2table(matrixFairnessAge_byloop);
    
    
             try
                TableFairnessbySex.Properties.VariableNames = {'StatisticalParityDifference', 'DisparateImpact', 'EqualOpportunityDifference', 'AverageAbsoluteOddsDifference','GroupCount', 'GroupSizeRatio','Accuracy','FalsePositiveRate','FalseNegativeRate' };
                TableFairnessbyAge.Properties.VariableNames = {'StatisticalParityDifference', 'DisparateImpact', 'EqualOpportunityDifference', 'AverageAbsoluteOddsDifference','GroupCount', 'GroupSizeRatio','Accuracy','FalsePositiveRate','FalseNegativeRate' };
                matrixFairnessSex_byloop.Properties.VariableNames = {'Group','StatisticalParityDifference', 'DisparateImpact', 'EqualOpportunityDifference', 'AverageAbsoluteOddsDifference','GroupCount', 'GroupSizeRatio','Accuracy','FalsePositiveRate','FalseNegativeRate' };
                matrixFairnessAge_byloop.Properties.VariableNames = {'Group','StatisticalParityDifference', 'DisparateImpact', 'EqualOpportunityDifference', 'AverageAbsoluteOddsDifference','GroupCount', 'GroupSizeRatio','Accuracy','FalsePositiveRate','FalseNegativeRate' };
                Measurements_test.TableFairnessSex_byloop = matrixFairnessSex_byloop;
                Measurements_test.TableFairnessAge_byloop = matrixFairnessAge_byloop;
             catch
                 disp('Error naming the fairness matrices. End of code');
             end
         end

end
