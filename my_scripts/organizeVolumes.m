%% 
gen_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';

table = readtable([gen_path '/spreadsheets/new_UH_RP_datasheet_Feb6_20.xlsx']);
fileNum = cell(45,1);
for e = 1:size(table,1)
fileNum{e} = table.ProstateID{e}(end-5:end);
end 

addpath(genpath([gen_path '/Functions']));

%parentPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UH_PPF';
%mkdir(parentPath);
%% 
for i = 1:45
 
    sub_save_path = fullfile(parentPath,num2str(fileNum{i}));
    mkdir(sub_save_path)
end 
%%
for j = 7:45
    promaskName = fullfile(gen_path,['/Volumes/UH_45PAT_PPF/' fileNum{j} '_T2_prostate_label.mha']);
    ecmaskName = fullfile(gen_path,['/Volumes/UH_45PAT_PPF/' fileNum{j} '_T2_label_ecMask.mha']);
    canmaskName = fullfile(gen_path,['/Volumes/UH_45PAT_PPF/' fileNum{j} '_T2_label_canMask.mha']);
    volName = fullfile(gen_path,['/Volumes/UH_45PAT_PPF/' fileNum{j} '_T2.mha']);
    adcName = fullfile(gen_path,['/Volumes/UH_45PAT_PPF/' fileNum{j} '_ADC_reg.mha']);
    
    pm = mha_read_volume(promaskName);
    pm_head = mha_read_header(promaskName);
    ec = mha_read_volume(ecmaskName);
    ec_head = mha_read_header(ecmaskName);
    can = mha_read_volume(canmaskName);
    can_head = mha_read_header(canmaskName);
    T2 = mha_read_volume(volName);
    T2_head = mha_read_header(volName);
    ADC = mha_read_volume(adcName);
    ADC_head = mha_read_header(adcName);
    
    temp_path = ['/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UH_PPF/' fileNum{j}];
    
    mha_write_volume(fullfile(temp_path,'PM.mha'),pm,pm_head.PixelDimensions,pm_head.Offset);
    mha_write_volume(fullfile(temp_path,'EC.mha'),ec,ec_head.PixelDimensions,ec_head.Offset);
    mha_write_volume(fullfile(temp_path,'LS1.mha'),can,can_head.PixelDimensions,can_head.Offset);
    mha_write_volume(fullfile(temp_path,'T2W_std.mha'),T2,T2_head.PixelDimensions,T2_head.Offset);
    mha_write_volume(fullfile(temp_path,'ADC_reg.mha'),ADC,ADC_head.PixelDimensions,ADC_head.Offset);
 
end 