
%% initializing folds 
clear all;
%train data*********
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/internal_test.mat');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/internal_list.mat');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/internal_feats/internal_test_OG.mat');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/feats_Original_qc.mat');
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
fileName = table.fileName(~cellfun('isempty',table.fileName));
reader_feats = feats_Original_corr;
g1_feats = zeros(37,600);
g2_feats = zeros(37,600);
g3_feats = zeros(38,600);

%% equal weights 
list = internal_list; 
%randomizing list order
rand_list = list(randperm(112)',:);
group1 = cell(37,3);
group2 = cell(37,3);
group3 = cell(38,3);
%finding pos and neg inds
pos_ind = find(cell2mat(rand_list(:,3))==1);
neg_ind = find(cell2mat(rand_list(:,3))==0);
%equally weighting pos and neg inds 
group1(1:12,:) = rand_list(neg_ind(1:12),:);
group1(13:37,:) = rand_list(pos_ind(1:25),:);
group2(1:12,:) = rand_list(neg_ind(13:24),:);
group2(13:37,:) = rand_list(pos_ind(26:50),:);
group3(1:13,:) = rand_list(neg_ind(25:37),:);
group3(14:38,:) = rand_list(pos_ind(51:75),:);
%randomizing group order
group1_rand = group1(randperm(37)',:);
group2_rand = group2(randperm(37)',:);
group3_rand = group3(randperm(38)',:);
%matching new group order to features 
for i = 1:37
    name_ind_ = strcmp(fileName,group1_rand{i,1});
    name_ind = find(name_ind_);
    g1_feats(i,:) = reader_feats(name_ind,:);
end 
for e = 1:37
    name_ind_ = strcmp(fileName,group2_rand{e,1});
    name_ind = find(name_ind_);
    g2_feats(e,:) = reader_feats(name_ind,:);
end
for q = 1:38
    name_ind_ = strcmp(fileName,group3_rand{q,1});
    name_ind = find(name_ind_);
    g3_feats(q,:) = reader_feats(name_ind,:);
end

%% g1 test
train_labels = zeros(size(g2_feats,1) + size(g3_feats,1),1);
train_labels(1:37) = cell2mat(group2_rand(:,3)); train_labels(38:75) = cell2mat(group3_rand(:,3));
train_feats = zeros(75,600);
train_feats(1:37,:) = g2_feats; train_feats(38:75,:) = g3_feats; 
X_train = train_feats;
Y_train = train_labels;

X_test = g1_feats;
Y_test = cell2mat(group1_rand(:,3));
%% g2 test
train_labels = zeros(size(g1_feats,1) + size(g3_feats,1),1);
train_labels(1:37) = cell2mat(group1_rand(:,3)); train_labels(38:75) = cell2mat(group3_rand(:,3));
train_feats = zeros(75,600);
train_feats(1:37,:) = g1_feats; train_feats(38:75,:) = g3_feats; 
X_train = train_feats;
Y_train = train_labels;

X_test = g2_feats;
Y_test = cell2mat(group2_rand(:,3));
%% g3 test
train_labels = zeros(size(g2_feats,1) + size(g1_feats,1),1);
train_labels(1:37) = cell2mat(group2_rand(:,3)); train_labels(38:74) = cell2mat(group1_rand(:,3));
train_feats = zeros(74,600);
train_feats(1:37,:) = g2_feats; train_feats(38:74,:) = g1_feats; 
X_train = train_feats;
Y_train = train_labels;

X_test = g3_feats;
Y_test = cell2mat(group3_rand(:,3));
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
        save(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/internal/fold/OG/g3/trainData_' num2str(cID) '_' num2str(fsID) '.mat'],'output');
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

aucMatrix =[];
clc
aucPlot = struct;
for cID = 1:3
    for fsID = 1:3
        load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/internal/fold/OG/g3/trainData_' num2str(cID) '_' num2str(fsID) '.mat']);
        disp(num2str(output.aucAll(1:5,[3 6])));
        temp = input('enter the row aucAll  - ');
        x = output.aucAll(temp,1:2);
        B_best = output.B_all{x(1),x(2)};
        B_best = B_best(output.aucAll(temp,4));
        %**************
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