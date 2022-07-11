% load R1 pred results from SVM
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
%
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_STAPLE.mat');
X_train = feats_STAPLE;
%
labels = table.label(~isnan(table.label));
Y_train = labels;
%% TEST CCF
load '/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_CCFR.mat';
csv = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/significance_ccf.csv');
csv([209,233],:) = [];
ccf_label = csv(151:235,:).Sig;

X_test = feats_CCFR; Y_test = ccf_label;
%% TEST UH
load '/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/uh_table_corr.mat';
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_UHMRF.mat');
uh_label = table_uh.label;
X_test = feats_UHMRF; Y_test = uh_label;
  
%%     %**********PREP************
    %train
    featsAvg = simplewhiten(X_train);
    featsAvg_n = featsAvg;
    pVals = zeros(size(featsAvg_n,2),1);
    %pVals = zeros(size(Y_train));

    for i = 1:size(featsAvg,2)
        featsAvg_n(:,i) = rescale(featsAvg(:,i));
%       pVals(i) = ranksum(featsAvgN(Y_train==0,i),featsAvgN(Y_train==1,i));
    end

    for i = 1:size(featsAvg_n,2)
%       featsAvgN(:,i) = rescale_range(featsAvg(:,i),-1,1);
        pVals(i) = ranksum(featsAvg_n(Y_train==0,i),featsAvg_n(Y_train==1,i));
    end

    selectF = find(pVals<=0.05);
    % 
    featsAvg_sf = featsAvg_n(:,selectF);
    label = Y_train;
    featsAvgN = featsAvg_sf;

    %test 
    featsAvgT = simplewhiten_rs(X_test,X_train);

    featsAvgT_n = zeros(size(featsAvgT));
    for i = 1:size(featsAvgT,2)
        featsAvgT_n(:,i) = rescale_range_rs(featsAvgT(:,i),featsAvg(:,i));
%       pVals(i) = ranksum(featsAvgN(Y_train==0,i),featsAvgN(Y_train==1,i));
    end
%   featsAvg = simplewhiten(X_test);
    featsAvgNT = featsAvgT_n(:,selectF);
    
% for storing 
prob = cell(3,3);
readers = {'OG';'LKB';'JR';'RDW';'SV';'STAPLE'};

% get preds for this test set  
%posteriors = zeros(size(testLabels));
%for read = 1:3
    

    %**************************************
    
        for cID = 1:3
            for fsID = 1:3
                load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/OG/trainData_' num2str(cID) '_' num2str(fsID) '.mat']);
%               load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/OG/trainData_3_' num2str(fsID) '.mat']);
                temp = output.aucAll(1:5,[3 6]);
                loginds = temp(:,2)==min(temp(:,2));
                choose = find(loginds);
                %
                x = output.aucAll(choose,1:2);
                B_best_ = output.B_all{x(1),x(2)};
                % going through all 3 folds
                temp_auc_store = zeros(3,1);
                for fold = 1:3
                B_best = B_best_(fold);
                %**************
                %store_featsIN{fsID,cID} = selectF([B_best.f(1) B_best.f(2)]);
                testLabels = Y_test;
        
            
            switch cID
                case 1
                    posteriors = glmval(B_best.b,featsAvgNT(:,B_best.f),'logit');
 %                  [~,posteriors] = predict(B_best.b,featsAvgN(:,B_best.f));
                case 2
                    [predLabel,posteriors] = predict(B_best.b,featsAvgNT(:,B_best.f));
                case 3
                    [predLabel,~,posteriors] = svmpredict(testLabels,featsAvgNT(:,B_best.f),B_best.b , '-b 1');
            end
            
        %accounts for prediction returning postive and negative class
        if size(posteriors,2) == 1
        probability = posteriors;

        elseif size(posteriors,2) == 2
        probability = posteriors(:,2);
    
        end 
                end 
               %saving probabilities 
               prob{cID,fsID} = probability; 
            end   
        end 
  
%end 


save('/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/prob_scores/prob_STAPLE_CC','prob');
