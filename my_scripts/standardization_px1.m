%% px1
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
labels = table.label(~isnan(table.label));
names_raw = table.fileName; 
filenames = names_raw(~cellfun('isempty',names_raw));
proxID = table.ProxID(~cellfun('isempty',table.ProxID));
les = table.fid(~isnan(table.fid));
inds = find(labels);
folderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1' ;
gen_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';
%% CCF
gen_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';
table = readtable([gen_path '/spreadsheets/significance_ccf.csv']);
FolderPath = [gen_path '/CCF data/CCFR'];
ccfb_inds = find(table.Dataset=="CCFR");
patient_nums = table.PatientID(ccfb_inds);
%del_ = find(patient_nums==28);
delete_inds = [find(patient_nums==45); find(patient_nums==81)];
ccfb_inds(delete_inds) = [];
pats = table.PatientID(ccfb_inds);
lesion = table.LesionNum(ccfb_inds);
%% UH
volFolderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized' ;
table_raw = readtable('/Users/mike/Desktop/MATLAB/spreadsheets/UHMRF_label.xlsx');
table = [table_raw(1:11,:);table_raw(16:end,:)];
set = table.Set; 
MRID = table.MRID;
ROI = table.ROI;
%% standardization templates
gen_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';
temp_T2 = niftiread([gen_path '/Volumes/template/new_temp/T2W.nii.gz']); 
temp_ADC = niftiread([gen_path '/Volumes/template/new_temp/ADC_reg.nii.gz']); 
temp_pm = niftiread([gen_path '/Volumes/template/new_temp/PM.nii.gz']); 
temp_masked_T2 = double(temp_T2).*double(temp_pm);
temp_masked_ADC = double(temp_ADC).*double(temp_pm);
%opts.temcancermasks = temp cancer masks
%opts.incancermasks = input cancer mask of 
opts.docheck = false;
opts.dorescale = false;
%% standardizing
for i = 1:size(table,1)


    if length(num2str(table.MRID(i))) < 2
    
        folderPath = fullfile(volFolderPath,sprintf('UHMRF_000%d', table.MRID(i)));
    elseif length(num2str(table.MRID(i))) > 1
        folderPath = fullfile(volFolderPath,sprintf('UHMRF_00%d', table.MRID(i)));
    end 
    
    %casePath = fullfile(FolderPath,['CCFR_',num2str(pats(i))]);
    
    %pname = replace(proxID{i},'-','_');
    %pname = [pname(1:9) '1' pname(end-4:end)];  
    %[folderPath '/' pname '/' 'ADC_reg.nii.gz']
    
    T2 = niftiread(fullfile(folderPath,'T2W_std.nii.gz'));
    ADC = niftiread(fullfile(folderPath,'ADC_reg.nii.gz'));
    ADC(ADC<0) = 0;
    PM = niftiread(fullfile(folderPath,'PM.nii.gz'));


    mask = imdilate(PM,strel('disk',18));
    inputVolMask_T2 = double(T2).*double(mask);
    inputVolMask_ADC = double(ADC).*double(mask);
        %[~,stdMap,~] = int_stdn_landmarks(inputVolMask,templateVolMasked_T2,opts);
    [~,stdMap_T2,~] = int_stdn_landmarks(inputVolMask_T2,temp_masked_T2,opts);
    [~,stdMap_ADC,~] = int_stdn_landmarks(inputVolMask_ADC,temp_masked_ADC,opts);
    maskDil = dilateMaskVol(mask,30);
        %inputVolMaskDil = double(T2_volume).*maskDil;
    T2_REstd = applystdnmap_rs(T2,stdMap_T2);
    ADC_reg_std = applystdnmap_rs(ADC,stdMap_ADC);
    close all 
    
    
    %niftiwrite(T2_REstd,fullfile(folderPath, 'T2W_LESstd.nii'));
    %niftiwrite(ADC_reg_std,fullfile(folderPath,'ADC_reg_LESstd.nii'));
    

end 








%% clin sig pCa lesions size

inds = find(labels);

store_vol = zeros(75,1);

for i = 1:length(inds)
    
    ind = inds(i);
    
    pname = replace(proxID{ind},'-','_');
    pname = [pname(1:9) '1' pname(end-4:end)];   
    
    mask_struc = load_untouch_nii([folderPath '/' pname '/' 'LS' num2str(les(ind)) '.nii.gz']);
    mask = mask_struc.img ;
    
    temp = zeros(size(mask,3),1);
    for e = 1:size(mask,3)
    les_area = regionprops(imbinarize(double(mask(:,:,e))),'area');
    if ~isempty(les_area)
        temp(e) = les_area.Area;
    end 
    end 
    
    store_vol(i) = sum(temp) *0.5*0.5*3;
    
end 