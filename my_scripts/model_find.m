%%
load '/Users/mike/Desktop/MATLAB/models/models_Original/auc_matrices.mat' auc_1_1 auc_1_2 auc_1_3
%%
auc_1 = auc_1_1;
auc_2 = auc_1_2;
auc_3 = auc_1_3;
%%
sig_auc_1 = zeros(length(auc_1),3);
%%
for i = 1:length(auc_1)
    if auc_1(i,6) < 0.05
        sig_auc_1(i,1) = 1;
        sig_auc_1(i,2) = auc_1(i,3);
        sig_auc_1(i,3) = auc_1(i,6);
    end 
end 
[top_auc1,I] = maxk(sig_auc_1,3);
[top_std1,I] = mink(nonzeros(sig_auc_1(:,3)),3);
model_1_1_auc = zeros(3,2);

temp_auc1 = sig_auc_1(I(1,2),I(1,3));
temp_auc2 = sig_auc_1(I(2,2),I(2,3));
temp_auc3 = sig_auc_1(I(3,2),I(3,3));

model_1_1_auc(:,1) = 
model_1_1_auc(:,2) = top_std1(:,3);

