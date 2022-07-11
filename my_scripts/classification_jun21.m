
%%
%clear all;
%train data*********
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
%load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_STAPLE.mat');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/new_splits/feats_nJR.mat');

%labels = table.label(~isnan(table.label));
%------->> FOR NEW SPLITS ONLY BELOW
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/newSplitsLabels.mat');
labels = nlabels;

feats = feats_nJR;

%X_train = feats_STAPLE; 
%Y_train = labels;
%% INTERNAL VALIDATION

X_train = feats(1:75,:);
Y_train = labels(1:75);
%

X_test = feats(76:end,:);
Y_test = labels(76:end);

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

%% train prep

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

%% training

for cID = 1:3
    for fsID = 1:3
        disp(['running ' num2str(cID) '-' num2str(fsID)]);
        output = crossVal_MR_noinds(featsAvgN,label,cID,fsID);
        save(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits/SV/trainData_' num2str(cID) '_' num2str(fsID) '.mat'],'output');
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


%% FREQ Based Train
% use frequency from cross validation
freqAUC = zeros(3,1);
%fsID = 1;

for fsID = 1:3

    load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits/JR/trainData_3_' num2str(fsID) '.mat']);
    %load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits/LKB/trainData_3_1.mat']);
    f_list = [];
% 
for i = 1:size(output.B_all,1)
    for j = 1:size(output.B_all,2)
        f_list = [f_list;reshape([output.B_all{i,j}.f],[],1)];
    end
end

f_table = tabulate(f_list);

[freq,indx] = sort(f_table(:,2),'descend');
f_sort = indx;

%retrain and test classifiers

frequentF = f_sort(1:round(0.07*size(featsAvgN,1))); 
trainData = featsAvgN(:,frequentF);
%trainData = trainData1(:,1:15);
testData = featsAvgNT(:,frequentF);
%testData = testData1(:,1:15);
% 
% SVM classifier
%k = 3; %3 fold cross val
%AUCstore = [];

    
B(fsID).b = svmtrain(Y_train,trainData, '-t 2 -c 100 -b 1 -q');

[~,~,posteriors] = svmpredict(Y_test,testData,B(fsID).b , '-b 1');

% 

[X,Y,~,AUC,optPT,~,~] = perfcurve(Y_test,posteriors(:,2),1);

save(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits/FREQ/JR/freqAUC_3_' num2str(fsID) '.mat'],'AUC');

freqAUC(fsID) = AUC;
end 


%% TESTING -  REMEMBER TO CHANGE DIR

%store_featsIN = cell(3,3);
aucMatrix =[];
clc
aucPlot = struct;
for cID = 1:3
    for fsID = 1:3
        load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits/JR/trainData_' num2str(cID) '_' num2str(fsID) '.mat']);
        disp(num2str(output.aucAll(1:5,[3 6])));
        temp = input('enter the row aucAll  - ');
        x = output.aucAll(temp,1:2);
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
        temp_auc_store(fold) = AUC;
        end 
        
        aucPlot(fsID).X = X;
        aucPlot(fsID).Y = Y;
        pause;
        
        %max_fold = find(temp_auc_store==max(temp_auc_store));
        %if size(max_fold,1) > 1
            %max_fold_ = max_fold(1,1);
        %end 
        
        aucMatrix = [ aucMatrix; output.aucAll(temp,[3 5 6]) max(temp_auc_store)  mean(temp_auc_store)];
    end
end


