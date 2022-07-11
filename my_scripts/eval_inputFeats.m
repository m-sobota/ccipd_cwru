
total_feat_list = [];

for cID = 1:3
    for fsID = 1:3
        load(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/Original/models_Original/trainData_' num2str(cID) '_' num2str(fsID) '.mat']);
        
        for x1 = 1:5
            for x2 = 1:150
                B = output.B_all{x1,x2};
                for i = 1:3
                    temp_feat_list = B(i).f;
                    for j = 1:length(temp_feat_list)
                        total_feat_list = [total_feat_list; temp_feat_list(j)];
                    end
                end
            end
        end  
    end 
end 
%% 
inds = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/OG_selected_feat_inds.xlsx');
for q = 1:length(total_feat_list)
    selectF_feat_ind = total_feat_list(q);
    true_feat_num = inds.Var1(selectF_feat_ind);
    total_feat_list(q) = true_feat_num;
end 

    %%
writematrix(total_feat_list,'/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/model_input_feats.xlsx');





