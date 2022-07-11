json = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/convertcsv.xlsx');
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/px1_fileNumbers');
fid = table.fid(~isnan(table.fid));
newSplits = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/new splits file order.xlsx');

%% 
feats_nSV = zeros(112,600);
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_SV.mat');

for i = 1:112 
    ind = newSplits.IND(i);
    feats_nSV(i,:) = feats_SV(ind,:);
end 

save('/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/new_splits/feats_nSV.mat','feats_nSV');

    

%%
name_group_les = cell(112,4);

for i = 1:112
    temp = json{2,i};
    name_group_les{i,1} = temp{1}(1:end-2);
    name_group_les(i,2) = json{1,i};
    num = json{2,i};
    num = num{1}(end);
    name_group_les{i,3} = str2double(num);
end 

%% 
%correcting lesion numbers for uniform file naming
    
for j = 1:112
    
    new_fnum = str2num(name_group_les{j,1}(end-3:end));
    
    temp_size = size(find(fileNumbers == new_fnum),1);
    
    if num2str(name_group_les{j,3}) == '1'
        Lnum = '1';
    elseif num2str(name_group_les{j,3}) == '2' && temp_size == 1
        Lnum = '1';
    elseif num2str(name_group_les{j,3}) == '3' && temp_size == 1
        Lnum = '1';
    elseif num2str(name_group_les{j,3}) == '2' && temp_size == 2
        Lnum = '2';
    elseif num2str(name_group_les{j,3}) == '3' && temp_size == 3
        Lnum = '3';
    end 
    
    name_group_les{j,4} = str2double(Lnum);
    
end

%% 

load '/Volumes/GoogleDrive/My Drive/Sobota_Michael/featureStats/newly_std/feats_JR.mat';
feats = feats_JR;
JR = zeros(112,600);
%% 
%re ordering feature matrix 
store_inds = cell(112,1);

for e = 1:112
    
    %temp_ind_num = find(fileNumbers == fileNumbers(e));
    
    new_fnum = str2num(name_group_les{e,1}(end-3:end));
    
    temp_ind_new = find(fileNumbers == new_fnum);
    
   % if size(temp_ind_new,1) == 1
     %   JR(e,:) = feats(temp_ind_new);
     %   store_inds{e} = temp_ind_new;
   % else
     %   store_inds{e} = temp_ind_new;
    %end 
   %%  
    if num2str(name_group_les{j,4}) == '1'
        JR(e,:) = feats(temp_ind_new,:);
    elseif num2str(name_group_les{j,4}) == '2' && temp_size == 1
        JR(e,:) = feats(temp_ind_new,:);
    elseif num2str(name_group_les{j,4}) == '3' && temp_size == 1
        JR(e,:) = feats(temp_ind_new,:);
    elseif num2str(name_group_les{j,4}) == '2' && temp_size == 2
        JR(e,:) = feats(temp_ind_new,:);
    elseif num2str(name_group_les{j,4}) == '3' && temp_size == 3
        Lnum = '3';
    end 
    
    
end 
    