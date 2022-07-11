%%
clear all;
close all;

%add matlab_repo and folders and subfolders to path 
addpath('/Users/mike/Desktop/MATLAB/Functions/NIfTI_20140122');
addpath('/Users/mike/Desktop/MATLAB/Functions/MATLAB_repo_Feb19/Dependencies')
addpath('/Users/mike/Desktop/MATLAB/Functions/MATLAB_repo_Feb19/Dependencies/preprocessing/intensity_stdn');
addpath('/Users/mike/Desktop/MATLAB/Functions/MATLAB_repo_Feb19/Wrappers-master');

volFolderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized' ;
maskFolderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized' ;

%CHECK ABOVE FIRST THEN EDIT BELOW
table_raw = readtable('/Users/mike/Desktop/MATLAB/spreadsheets/UHMRF_label.xlsx');
table = [table_raw(1:11,:);table_raw(16:end,:)];
set = table.Set; 
MRID = table.MRID;
ROI = table.ROI;

%%
T2_template_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized/UHMRF_0005/T2W_std.nii.gz');
template_T2 = T2_template_struc.img ;
ADC_template_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized/UHMRF_0005/ADC_reg.nii.gz');
template_ADC = ADC_template_struc.img ;

Mask_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/UHMRF_Organized/UHMRF_0005/LS1.nii.gz');
template_caMask = Mask_struc.img ; 
template_caMask = logical(template_caMask);
template_mask = imdilate(template_caMask,strel('disk',18));

templateVolMasked_T2 = double(template_T2).*template_mask;
opts.docheck = false;
opts.dorescale = false;
%

feat_UHMRF = zeros(size(29,1), 75*8); 
%%  

for i =  1:size(table,1)
    
    if length(num2str(table.MRID(i))) < 2
    
        folderPath = fullfile(volFolderPath,sprintf('UHMRF_000%d', table.MRID(i)));
    elseif length(num2str(table.MRID(i))) > 1
        folderPath = fullfile(volFolderPath,sprintf('UHMRF_00%d', table.MRID(i)));
    end 
        
    maskName = sprintf('LS%d.nii.gz', table.ROI(i)); 
    T2_struc = load_untouch_nii(fullfile(folderPath,'T2W_REstd.nii'));
    T2 = T2_struc.img ;
    
    ADC_struc = load_untouch_nii(fullfile(folderPath,'ADC_reg_std.nii.nii'));
    ADC = ADC_struc.img ;
    
    caMask_struc = load_untouch_nii(fullfile(folderPath,maskName));
    caMask_struc_ADC = load_untouch_nii(fullfile(folderPath,maskName));
    caMask = caMask_struc.img ; 
    caMask = logical(caMask);
    caMask_ADC =  caMask_struc_ADC.img ;
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
    
    feats_UHMRF(i,:) = [computeROIstatistics(T2w_feats) computeROIstatistics(ADC_feats)] ;
end
