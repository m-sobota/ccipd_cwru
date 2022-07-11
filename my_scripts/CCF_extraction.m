%%
clear all;
close all;
localPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';
hpcPath = '/home/mas542/MATLAB';
using_path = localPath;
addpath(genpath([using_path '/Functions']));
table = readtable([using_path '/spreadsheets/significance_ccf.csv']);
%%
FolderPath = [using_path '/CCF data/CCFR'];
ccfb_inds = find(table.Dataset=="CCFR");
patient_nums = table.PatientID(ccfb_inds);
%del_ = find(patient_nums==28);
delete_inds = [find(patient_nums==45); find(patient_nums==81)];
ccfb_inds(delete_inds) = [];
pats = table.PatientID(ccfb_inds);
lesion = table.LesionNum(ccfb_inds);
%%
T2_template_struc = load_untouch_nii(fullfile(FolderPath,'CCFR_1/T2W_std.nii.gz'));
template_T2 = T2_template_struc.img ;
ADC_template_struc = load_untouch_nii(fullfile(FolderPath,'CCFR_1/ADC_reg.nii.gz'));
template_ADC = ADC_template_struc.img ;

Mask_struc = load_untouch_nii(fullfile(FolderPath, 'CCFR_1/LS1.nii.gz'));
template_caMask = Mask_struc.img ; 
template_caMask = logical(template_caMask);
template_mask = imdilate(template_caMask,strel('disk',18));

templateVolMasked_T2 = double(template_T2).*template_mask;
% templateVolMasked_ADC = double(template_ADC).*template_mask;
%opts.temcancermasks = logical(template_caMask);
opts.docheck = false;
opts.dorescale = false;
%
feats_CCFR = zeros(85, 75*8);
%%

for i =  1:length(pats)
    
        
    casePath = fullfile(FolderPath,['CCFR_',num2str(pats(i))]);
  
    
    T2_struc = load_untouch_nii(fullfile(casePath,'T2W_std.nii.gz'));
    T2 = T2_struc.img ;
    ADC_struc = load_untouch_nii(fullfile(casePath,'ADC_reg.nii.gz'));
    ADC = ADC_struc.img ;
    
    canLes_struc = load_untouch_nii(fullfile(casePath,['LS' num2str(lesion(i)) '.nii.gz']));
    canLes = canLes_struc.img;
    
  
    caMask = canLes;
    caMask = logical(caMask);
    caMask_ADC =  canLes;
    caMask_ADC = logical(caMask_ADC);
    %   header = mha_read_header([mDir filesep studies{1,i} filesep 'T2.mha']);
    mask = imdilate(caMask,strel('disk',18));
    
    if ~isequal(size(T2),size(caMask))
        disp('T2W mask and image are of different size!');
        pause;
    end
    
    if ~isequal(size(ADC),size(caMask_ADC))
        disp('ADC mask and image are of different size!');
        pause;
    end
    
    
    T2w_feats = []; ADC_feats = [];
    
    for j = 1:size(T2,3)
        caMask_ = caMask(:,:,j);
        if max(caMask_(:))>0
            
            T2w_feats = [T2w_feats; computeTextureFeatures(T2(:,:,j),caMask_)];
            %
        end
    end
    
    
    for j = 1:size(ADC,3)
        caMask_ADC_ = caMask_ADC(:,:,j);
        if max(caMask_ADC_(:))>0
            
            ADC_feats = [ADC_feats; computeTextureFeatures(ADC(:,:,j),caMask_ADC_)];
            %
        end
    end
    
    feats_CCFR(i,:) = [computeROIstatistics(T2w_feats) computeROIstatistics(ADC_feats)] ;
end 
save('/Volumes/GoogleDrive/My Drive/Sobota_Michael/feats_CCFR','feats_CCFR');
