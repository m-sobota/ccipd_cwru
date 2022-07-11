load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/internal_test.mat');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/internal_train.mat');
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
fnames = table.fileName(~cellfun('isempty',table.fileName));

load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/feats_Original_qc.mat');

internal_test_OG = zeros(56,600);
internal_train_OG = zeros(56,600);


for i = 1:56
    test_name = internal_test{i,2};
    train_name = internal_train{i,2};
    
    test_ind_ = strcmp(fnames,test_name);
    test_ind = find(test_ind_);
    internal_test_OG(i,:) = feats_Original_corr(test_ind,:);
    
    train_ind_ = strcmp(fnames,train_name);
    train_ind = find(train_ind_);
    internal_train_OG(i,:) = feats_Original_corr(train_ind,:);
end 