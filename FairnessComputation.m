function [matrixFairness] = FairnessComputation(testingData,predictions,response,table_RF,attributename)
        
        
        %table_RF.f_eid = str2num(cell2mat(table_RF.f_eid ));
        table_RF.f_eid = table_RF.f_eid ;
        testingData = innerjoin(testingData,table_RF,'Keys','f_eid');
        %Do not change the order
        testingData.Eval = response;
        
        fairness_res = fairnessMetrics(testingData,"Eval", ...
        SensitiveAttributeNames=attributename,Predictions=predictions,PositiveClass=1);
        report(fairness_res,BiasMetrics="all")
        
        fairness_res.GroupMetrics
        fairness_res.BiasMetrics

        matrixFairness = [];

        for i=1:size(fairness_res.BiasMetrics,1)
            try
                matrixFairness_row = [
                i,    
                fairness_res.BiasMetrics.StatisticalParityDifference(i),
                fairness_res.BiasMetrics.DisparateImpact(i),
                fairness_res.BiasMetrics.EqualOpportunityDifference(i),
                fairness_res.BiasMetrics.AverageAbsoluteOddsDifference(i),
                fairness_res.GroupMetrics.GroupCount(i),
                fairness_res.GroupMetrics.GroupSizeRatio(i),
                fairness_res.GroupMetrics.Accuracy(i),
                fairness_res.GroupMetrics.FalsePositiveRate(i),
                fairness_res.GroupMetrics.FalseNegativeRate(i)
               ];

                matrixFairness_row = matrixFairness_row';
                matrixFairness = [matrixFairness;matrixFairness_row];
                
            catch
                matrixFairness = [];
                disp('Error in fairness method');
            end
        end
        0==0;

        
 