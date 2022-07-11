%% px1
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
labels = table.label(~isnan(table.label));
names_raw = table.fileName; 
filenames = names_raw(~cellfun('isempty',names_raw));
proxID = table.ProxID(~cellfun('isempty',table.ProxID));
les = table.fid(~isnan(table.fid));
folderPath_px = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1' ;
gen_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';

inds_px = find(labels==0);
%% UH 
volFolderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized' ;
table_raw = readtable('/Users/mike/Desktop/MATLAB/spreadsheets/UHMRF_label.xlsx');
table = [table_raw(1:11,:);table_raw(16:end,:)];
set = table.Set; 
MRID = table.MRID;
ROI = table.ROI;

inds_uh = find(table.label==0);

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

inds_ccf = find(table.Sig(ccfb_inds)==0);
%% 
% px1
temp_px1 = zeros(length(inds_px),1);
for i = 1:length(inds_px)
    
    px_ind = inds_px(i);
    
    pname = replace(proxID{px_ind},'-','_');
    pname = [pname(1:9) '1' pname(end-4:end)];  
    
    %T2_px = niftiread([folderPath_px '/' pname '/' 'T2W_REstd.nii']);
        T2_px = niftiread([folderPath_px '/' pname '/' 'ADC_reg_std.nii.nii']);
    ca_px = niftiread([folderPath_px '/' pname '/' 'LS' num2str(les(px_ind)) '.nii.gz']);
    
    
    temp_px1(i) = mean(T2_px(ca_px==1));
    
end 
% ccf
temp_ccf = zeros(length(inds_ccf),1);
for e = 1:length(inds_ccf)
    
    ccf_ind = inds_ccf(e);
    
    casePath = fullfile(FolderPath,['CCFR_',num2str(pats(ccf_ind))]);
    %T2_ccf = niftiread(fullfile(casePath,'T2W_REstd.nii'));
        T2_ccf = niftiread(fullfile(casePath,'ADC_reg_std.nii.nii'));
    ca_ccf = niftiread(fullfile(casePath,[ 'LS' num2str(lesion(ccf_ind)) '.nii.gz']));
    
    temp_ccf(e) = mean(T2_ccf(ca_ccf>=1));
    
end 
% uh
temp_uh = zeros(length(inds_uh),1);
for j = 1:length(inds_uh) 
    
    uh_ind = inds_uh(j);
    
    if length(num2str(MRID(uh_ind))) < 2
    
        folderPath = fullfile(volFolderPath,sprintf('UHMRF_000%d', MRID(uh_ind)));
    elseif length(num2str(MRID(uh_ind))) > 1
        folderPath = fullfile(volFolderPath,sprintf('UHMRF_00%d', MRID(uh_ind)));
    end
    
    %T2_uh = niftiread(fullfile(folderPath,'T2W_REstd.nii'));
        T2_uh = niftiread(fullfile(folderPath,'ADC_reg_std.nii.nii'));
    ca_uh = niftiread(fullfile(folderPath, ['LS' num2str(ROI(uh_ind)) '.nii.gz']));
    
    temp_uh(j) = mean(T2_uh(ca_uh==1));
    
end 
%% 
temp_mean = zeros(length(inds_px) + length(inds_uh) + length(inds_ccf),1);
temp_mean(1:length(inds_px)) = temp_px1;
temp_mean(length(inds_px)+1:length(inds_px)+length(inds_uh)) = temp_uh;
temp_mean(length(inds_px)+length(inds_uh)+1:length(inds_px)+length(inds_uh)+length(inds_ccf)) = temp_ccf;
group = zeros(length(inds_px) + length(inds_uh) + length(inds_ccf),1);
group(1:length(inds_px)) = 1;
group(length(inds_px)+1:length(inds_px)+length(inds_uh)) = 2;
group(length(inds_px)+length(inds_uh)+1:length(inds_px)+length(inds_uh)+length(inds_ccf)) = 3;
%% 
p = anova1(temp_mean,group);