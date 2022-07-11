
%%
clear all;
close all;


folderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1' ;
lesPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/STAPLE' ;
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/px1_fileNumbers');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/temp_num.mat')

%CHECK
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
%names_raw = table.fileName; 
%filenames = names_raw(~cellfun('isempty',names_raw));
proxID = table.ProxID(~cellfun('isempty',table.ProxID));
%fid = table.fid(~isnan(table.fid));

%%
T2_template_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0000/T2W_REstd.nii');
template_T2 = T2_template_struc.img ;
ADC_template_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0000/ADC_reg_std.nii.nii');
template_ADC = ADC_template_struc.img ;

Mask_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0000/LS1.nii.gz');
template_caMask = Mask_struc.img ; 
template_caMask = logical(template_caMask);
template_mask = imdilate(template_caMask,strel('disk',18));

templateVolMasked_T2 = double(template_T2).*template_mask;
opts.docheck = false;
opts.dorescale = false;
%

feats_STAPLE = zeros(size(112,1), 75*8); 
%%

for i =  88:112
    
    pname = replace(proxID{i},'-','_');
    pname = [pname(1:9) '1' pname(end-4:end)];   
    
    T2_struc = load_untouch_nii([folderPath '/' pname '/' 'T2W_REstd.nii']);
    T2 = T2_struc.img ;
    
    ADC_struc = load_untouch_nii([folderPath '/' pname '/' 'ADC_reg_std.nii.nii']);
    ADC = ADC_struc.img ;
    
    %if filenames{i}(end-4) == '1'
        %tempName = [filenames{i} '.gz'];
    %elseif filenames{i}(end-4) == '2'
        %tempName = [filenames{i} '.gz'];
    %elseif filenames{i}(end-4) == '3'
        %tempName = [filenames{i} '.gz'];
    %else 
        %tempName = [num2str(fileNumbers(i)) '_T2W_std-label_1.nii.gz'];
    %end 
    
    %temp_size = size(find(fileNumbers == fileNumbers(i)),1);
    
    %if num2str(fid(i)) == '1'
     %   Lnum = '1';
    %elseif num2str(fid(i)) == '2' && temp_size == 1
       % Lnum = '1';
    %elseif num2str(fid(i)) == '3' && temp_size == 1
        %Lnum = '1';
   % elseif num2str(fid(i)) == '2' && temp_size == 2
        %Lnum = '2';
    %elseif num2str(fid(i)) == '3' && temp_size == 3
      %  Lnum = '3';
    %end 
    
    les_mask_struc = load_untouch_nii([lesPath '/' pname '/LS' num2str(temp_num(i)) '.nii']);

    les_mask = les_mask_struc.img;
    
    temp = les_mask;
    %caMask = logical(les_mask);
        temp(temp>0.5) = 1;
        %temp(temp<0.5) = 0;
        caMask = zeros(size(temp));
        caMask(temp==1) = 1;
    caMask_ADC = caMask;
    caMask_ADC = logical(caMask_ADC);
    %   header = mha_read_header([mDir filesep studies{1,i} filesep 'T2.mha']);
        %mask = imdilate(caMask,strel('disk',18));
    
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
    
    feats_STAPLE(i,:) = [computeROIstatistics(T2w_feats) computeROIstatistics(ADC_feats)] ;
end