function [AUCsvm,validationAccuracy,Sensitivity,specificity,Xsvm,Ysvm,F1_score,kappa,fairnessStruct] = PerformanceMeasurements(classificationSVM, response,kfolds, testingData, testingData_names,FairnessCompEnabled)

    % Add additional fields to the result struct
    trainedClassifier.ClassificationSVM = classificationSVM;
    fairnessStruct  = [];
    crossvalid_enable = true;

    %If test data is not given the value is obtained by the
    %cross-validation of the classifier
    switch nargin    
        case 1
          disp('Arguments are missing');
          return;
        case 2
            kfolds = 10; %by default
        case 3
            crossvalid_enable = true;
            disp('cross-validation measurents\n');
        case 4
            disp('Measurents for test set\n');
            crossvalid_enable  = false;
        %case 5 
        %    disp('Measurents for test set \n');
        %    crossvalid_enable  = false;
        case 6
            disp('Measurents for test set with or without fairness \n');
            crossvalid_enable  = false;
        otherwise
          disp('Error in the arguments');
          return;
    end
    
    if(crossvalid_enable == true)
        % Perform cross-validation
        rng('default');
        partitionedModel = crossval(trainedClassifier.ClassificationSVM, 'KFold', kfolds); %10);
        
        % Compute validation accuracy
        validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
    
        %Kfold prediction of the validation tests
        [predictions,Score] = kfoldPredict(partitionedModel);
        
    else
        %test set prediction
        [predictions,Score] = predict(classificationSVM,testingData);
        L = loss(classificationSVM,testingData,response,'LossFun', 'ClassifError');
        validationAccuracy = 1-L;

        if(FairnessCompEnabled)
            %filespath = '../../excels/';
            %RiskFactorsTable = readtable(strcat(filespath,'CMR_Radiomics_32k_V2.xlsx'),'Sheet','Clinical');
            RiskFactorsTable = readtable('RiskFactors.csv');
            table_RF = table(RiskFactorsTable.f_eid,RiskFactorsTable.cov_sex);
            table_RF.Properties.VariableNames = {'f_eid','Sex'};
            testingData.f_eid = testingData_names;
    
            [matrixFairness] = FairnessComputation(testingData,predictions,response,table_RF,"Sex");
            fairnessStruct.fairnessSex = matrixFairness;
    
            table_RF = table(RiskFactorsTable.f_eid,RiskFactorsTable.groupAge);
            table_RF.Properties.VariableNames = {'f_eid','groupAge'};
            testingData.f_eid = testingData_names;
    
            [matrixFairness] = FairnessComputation(testingData,predictions,response,table_RF,"groupAge");
            fairnessStruct.fairnessAge = matrixFairness;

            table_RF = table(RiskFactorsTable.f_eid,RiskFactorsTable.groupSexAge);
            table_RF.Properties.VariableNames = {'f_eid','groupSexAge'};
            testingData.f_eid = testingData_names;
    
            [matrixFairness] = FairnessComputation(testingData,predictions,response,table_RF,"groupSexAge");
            fairnessStruct.fairnessSexAge = matrixFairness;
        end


    end

   try
    [c_matrix,Result,RefereceResult]= confusion.getMatrix(response,predictions);
    F1_score = Result.F1_score;
    kappa = Result.Kappa;
   catch
    disp('Error calculating the F1_score and Kappa. The library might not be installed or in the path');
    F1_score = -10000;
    kappa = -10000;
   end

    [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(response,Score(:,1),1);

    
    confmat = confusionmat(response,predictions); % where response is the last column in the dataset representing a class
    TP = confmat(1, 1);
    FN = confmat(1, 2);
    FP = confmat(2, 1);
    TN = confmat(2, 2);
    Accuracy = (TP + TN) / (TP + TN + FP + FN);
    Sensitivity = TP / (FN + TP);
    specificity = TN / (TN + FP);

    disp('AUC:\n');
    disp(AUCsvm);
    
    disp('Accuracy:\n');
    disp(validationAccuracy);

    disp('Sensitivity:\n');
    disp(Sensitivity);

    disp('Specificity:\n');
    disp(specificity);

    disp('Kappa:\n');
    disp(kappa);

    disp('F1_score:\n');
    disp(F1_score);