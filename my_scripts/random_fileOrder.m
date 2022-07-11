%% 
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
label = table.label(~isnan(table.label));
proxID = table.ProxID(~cellfun('isempty',table.ProxID));
fileName = table.fileName(~cellfun('isempty',table.fileName));
%% 

pos_inds = find(label==1);
neg_inds = find(label==0);

rand_pos = randperm(size(pos_inds,1))';
rand_neg = randperm(size(neg_inds,1))';

train_int = cell(56,3);
test_int = cell(56,3); 

train_int(1:38,1) = proxID(pos_inds(rand_pos(1:38)));
train_int(1:38,2) = fileName(pos_inds(rand_pos(1:38)));
for i = 1:38
train_int{i,3} = num2str(label(pos_inds(rand_pos(i))));
end 
train_int(39:end,1) = proxID(neg_inds(rand_neg(1:18)));
train_int(39:end,2) = fileName(neg_inds(rand_neg(1:18)));
for i = 1:18
train_int{i+38,3} = num2str(label(neg_inds(rand_neg(i))));
end 

test_int(1:37,1) = proxID(pos_inds(rand_pos(39:end)));
test_int(1:37,2) = fileName(pos_inds(rand_pos(39:end)));
for i = 39:75
test_int{i-38,3} = num2str(label(pos_inds(rand_pos(i))));
end 
test_int(38:end,1) = proxID(neg_inds(rand_neg(19:37)));
test_int(38:end,2) = fileName(neg_inds(rand_neg(19:37)));
for i = 19:37
test_int{i+19,3} = num2str(label(neg_inds(rand_neg(i))));
end

%%

internal_train = train_int(randperm(56)',:);
internal_test = test_int(randperm(56)',:);
%% 

list = cell(112,3);
list(:,1) = fileName(:);
list(:,2) = proxID(:);
for i = 1:112
list{i,3} = label(i);
end 

internal_list = list;




