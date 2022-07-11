
%%
%clear all;
%train data*********
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_JR.mat');
labels = table.label(~isnan(table.label));
X_train = feats_JR; 
Y_train = labels;

%% test data UH
load '/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/uh_table_corr.mat';
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_UHMRF.mat');
uh_label = table_uh.label;
X_test = feats_UHMRF; Y_test = uh_label;

%% test data CCFR
load '/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_CCFR.mat';
csv = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/significance_ccf.csv');
csv([209,233],:) = [];
ccf_label = csv(151:235,:).Sig;

X_test = feats_CCFR; Y_test = ccf_label;

%%

featsAvg = simplewhiten(X_train);
featsAvg_n = featsAvg;
pVals = zeros(size(featsAvg_n,2),1);
%pVals = zeros(size(Y_train));

for i = 1:size(featsAvg,2)
    featsAvg_n(:,i) = rescale(featsAvg(:,i));
%     pVals(i) = ranksum(featsAvgN(Y_train==0,i),featsAvgN(Y_train==1,i));
end

for i = 1:size(featsAvg_n,2)
%     featsAvgN(:,i) = rescale_range(featsAvg(:,i),-1,1);
    pVals(i) = ranksum(featsAvg_n(Y_train==0,i),featsAvg_n(Y_train==1,i));
end

selectF = find(pVals<=0.05);
% 
featsAvg_sf = featsAvg_n(:,selectF);
label = Y_train;
featsAvgN = featsAvg_sf;

%% 

for cID = 1:3
    for fsID = 1:3
        disp(['running ' num2str(cID) '-' num2str(fsID)]);
        output = crossVal_MR_noinds(featsAvgN,label,cID,fsID);
        save(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/JR/trainData_' num2str(cID) '_' num2str(fsID) '.mat'],'output');
    end
end
 
%% prepare test data

featsAvgT = simplewhiten_rs(X_test,X_train);

featsAvgT_n = zeros(size(featsAvgT));
for i = 1:size(featsAvgT,2)
    featsAvgT_n(:,i) = rescale_range_rs(featsAvgT(:,i),featsAvg(:,i));
%     pVals(i) = ranksum(featsAvgN(Y_train==0,i),featsAvgN(Y_train==1,i));
end
% featsAvg = simplewhiten(X_test);
 featsAvgNT = featsAvgT_n(:,selectF);



%% REMEMBER TO CHANGE

%store_featsIN = cell(3,3);
aucMatrix =[];
clc
aucPlot = struct;
for cID = 1:3
    for fsID = 1:3
        load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/JR/trainData_' num2str(cID) '_' num2str(fsID) '.mat']);
        disp(num2str(output.aucAll(1:5,[3 6])));
        temp = input('enter the row aucAll  - ');
        x = output.aucAll(temp,1:2);
        B_best = output.B_all{x(1),x(2)};
        % going through all 3 folds
        for fold = 1:3
        B_best = B_best(output.aucAll(temp,fold));
        
        %store_featsIN{fsID,cID} = selectF([B_best.f(1) B_best.f(2)]);
        testLabels = Y_test;
        
            
        switch cID
            case 1
                 posteriors = glmval(B_best.b,featsAvgNT(:,B_best.f),'logit');
%                 [~,posteriors] = predict(B_best.b,featsAvgN(:,B_best.f));
            case 2
                [~,posteriors] = predict(B_best.b,featsAvgNT(:,B_best.f));
            case 3
                [predLabel,~,posteriors] = svmpredict(testLabels,featsAvgNT(:,B_best.f),B_best.b , '-b 1');
        end
        
        %accounts for prediction returning postive and negative class
        if size(posteriors,2) == 1
        [X,Y,~,AUC,optPT,~,~] = perfcurve(testLabels,posteriors(:,1),1);disp(['auc  - ' num2str(AUC)]);

        elseif size(posteriors,2) == 2
        [X,Y,~,AUC,optPT,~,~] = perfcurve(testLabels,posteriors(:,2),1);disp(['auc  - ' num2str(AUC)]);
        
        end 
     
        aucPlot(fsID).X = X;
        aucPlot(fsID).Y = Y;
        pause;
        aucMatrix = [ aucMatrix; output.aucAll(temp,[3 6]) AUC];
        end 
    end
end
