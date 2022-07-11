%%
clear all;
close all;

hpc_path = '/home/mas542/MATLAB';
local_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael';
%gen_path = hpc_path;
gen_path = local_path;

table = readtable([gen_path '/spreadsheets/new_UH_RP_datasheet_Feb6_20.xlsx']);
fileNum = cell(45,1);
for e = 1:size(table,1)
fileNum{e} = table.ProstateID{e}(end-5:end);
end 

addpath(genpath([gen_path '/Functions']));



%%
template_T2 = mha_read_volume([gen_path '/Volumes/UH_PPF/000001/T2W_std.mha']);
%template_T2 = T2_template_struc.pixelData ;

template_ADC = mha_read_volume([gen_path '/Volumes/UH_PPF/000001/ADC_reg.mha']);
%template_ADC = ADC_template_struc.pixelData ;

template_caMask = mha_read_volume([gen_path '/Volumes/UH_PPF/000001/LS1.mha']);
%template_caMask = Mask_struc.pixelData ; 
template_caMask = logical(template_caMask);
template_mask = imdilate(template_caMask,strel('disk',18));

templateVolMasked_T2 = double(template_T2).*template_mask;
opts.docheck = false;
opts.dorescale = false;

%% standardization template
master_temp = load_untouch_nii([gen_path '/Volumes/template/T2W.nii']); master_temp_img = master_temp.img;
master_pm = load_untouch_nii([gen_path '/Volumes/template/PM.nii']); master_temp_pm = master_pm.img;
master_temp_masked = double(master_temp_img).*double(master_temp_pm);

pz_feats_UHPPF = zeros(size(45,1), 75*8); 
%%

for i =  1:45
    
 pmName = fullfile(gen_path,['/Volumes/UH_PPF/' fileNum{i} '/PM.mha']);
 cgName = fullfile(gen_path,['/Volumes/UH_PPF/' fileNum{i} '/CG.nii.gz']);
 volName = fullfile(gen_path,['/Volumes/UH_PPF/' fileNum{i} '/T2W_std.mha']);
 ADC_name = fullfile(gen_path,['/Volumes/UH_PPF/' fileNum{i} '/ADC_reg.mha']);
    
    pm = mha_read_volume(pmName);
    cg_struc = load_untouch_nii(cgName);
    cg = cg_struc.img;
    pz = double(pm) - double(cg);
    pz(pz==-1) = 0;
    is_mask = reshape(sum(sum(pz,1),2),[],1);
    first = find(is_mask);
    ind = first(1) + 9;
    pz_mask = pz(:,:,ind);
 
 
    caMask = pz_mask;
    %caMask = caMask_struc.pixelData ; 
    caMask = logical(caMask);
    
    T2_volume = mha_read_volume(volName);
    %T2_volume = T2_struc.pixelData ;
    
% standardization    
    mask = imdilate(caMask,strel('disk',18));
    inputVolMask = double(T2_volume).*mask;
    %[~,stdMap,~] = int_stdn_landmarks(inputVolMask,templateVolMasked_T2,opts);
    [~,stdMap,~] = int_stdn_landmarks(inputVolMask,master_temp_masked,opts);
    maskDil = dilateMaskVol(mask,30);
    inputVolMaskDil = double(T2_volume).*maskDil;
    T2_std_ = applystdnmap_rs(T2_volume,stdMap);
    close all 
    
    %loading adc
    ADC_ = mha_read_volume(ADC_name);
    %ADC = ADC_struc.img ;
    
    ADC = ADC_(:,:,9);
    T2_std = T2_std_(:,:,9);

    caMask_ADC =  caMask ;
    caMask_ADC = logical(caMask_ADC);
    %   header = mha_read_header([mDir filesep studies{1,i} filesep 'T2.mha']);
 
    
     if ~isequal(size(T2_std),size(caMask))
        disp('T2W mask and image are of different size!');
        pause;
    end
    
    if ~isequal(size(ADC),size(caMask_ADC))
        disp('ADC mask and image are of different size!');
        pause;
    end
    
    
    T2w_feats = []; ADC_feats = [];
    
    for j = 1:size(T2_std,3)
        caMask_ = caMask(:,:,j);
        if max(caMask_(:))>0
            
            T2w_feats = [T2w_feats; computeTextureFeatures(T2_std(:,:,j),caMask_)];
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
    
    pz_feats_UHPPF(i,:) = [computeROIstatistics(T2w_feats) computeROIstatistics(ADC_feats)] ;
end
save([ gen_path '/featureStats/pz_feats_UHPPF'],'featStats_UH_PPF');