
%%
clear all;
close all;

%% CHECK ABOVE FIRST THEN EDIT BELOW (for all pats at once)
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-Corrected.xlsx');
names_raw = table.fileName; 
pro_id_raw = table.ProxID;
proxID = pro_id_raw(~cellfun('isempty',pro_id_raw));

%% this is for specific pats can ignore
load '/Users/mike/Desktop/MATLAB/pixelData/OG/OG_top_sum.mat';
load '/Users/mike/Desktop/MATLAB/pixelData/OG/OG_top_gleas.mat';
top_ = cell(10,2);
top_(1:5,1) = top_5sum(:,2); top_(6:10,1) = top_5gleas(:,2);
top_(1:5,2) = top_5sum(:,3); top_(6:10,2) = top_5gleas(:,3);
%%
fig_feats = cell(1,1); %make this cell array nx1, n being the number of pats you want to run this for
file_names = table(205,:);
Volpath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1';
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/les_nums_up.mat'); %variable is named temp num
proxID_table = file_names(1,1);
proxID = proxID_table.ProxID;
les_table = file_names(1,2);
les = les_table.fid;
%% 
T2_template_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0000/T2W_std.nii');
template_T2 = T2_template_struc.img ;
ADC_template_struc = load_untouch_nii('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0000/ADC_reg.nii.gz');
template_ADC = ADC_template_struc.img ;

Mask_struc = load_untouch_nii('//Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0000/PM.nii.gz');
template_caMask = Mask_struc.img ; 
template_caMask = logical(template_caMask);
template_mask = imdilate(template_caMask,strel('disk',18));

templateVolMasked_T2 = double(template_T2).*template_mask;
opts.docheck = false;
opts.dorescale = false;
%%

for i =  1 %  this will have to be edited to 1-5 cases 
                         %that you want to generate heatmaps for, otherwise 
                         %it gets extremely intensive due to the size of the feature maps
                         % I suggest putting the filenames of a few cases
                         % you want to do feature maps for in a spreadsheet and then load it in
                         % 
   
    pname = replace(proxID{i},'-','_');
    pname = [pname(1:9) '1' pname(end-4:end)]; 
    
    T2 = niftiread([Volpath '/' pname '/T2W_std.nii.gz']);
    
    ADC = niftiread([Volpath '/' pname '/ADC_reg.nii.gz']);
    
    %fixing path name @ alisa this may not be necesary for you
    pro_mask_path = [Volpath '/' pname];
    %unzipping pm
    unzip_pm = char(gunzip(fullfile(pro_mask_path,'PM.nii.gz')));
    caMask = niftiread(fullfile(pro_mask_path, 'PM.nii'));
    caMask = logical(caMask);
    caMask_ADC =  caMask ;
    caMask_ADC = logical(caMask_ADC);
    %   header = mha_read_header([mDir filesep studies{1,i} filesep 'T2.mha']);
 %   mask = imdilate(caMask,strel('disk',18));
    
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
    
    fig_feats{i} = [T2w_feats ADC_feats] ; %here we are saving just the feature maps, 
                                                       %not doing the
                                                       %feature statistics 
end
