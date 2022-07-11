%% 
folderPath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/proX1_annotations/';
folderName = 'px1Label_LKB_qc';
folderPath = [folderPath folderName];
reader = 'px1Label_LKB' ;
%
table = readtable('/Users/mike/Desktop/MATLAB/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
Tfnames = table.fileName(~cellfun('isempty',table.fileName));
TlesID = table.fid(~isnan(table.fid));
TproxID = table.ProxID(~cellfun('isempty',table.ProxID));
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/px1_fileNumbers');
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/temp_num.mat')
%% 
LKB = dir('/Volumes/GoogleDrive/My Drive/Sobota_Michael/proX1_annotations/px1Label_LKB_qc');
LKB(1:2,:) = [];


%% make the folders 
for i = 1:length(TproxID)
    
    pname = replace(TproxID{i},'-','_');
    pname = [pname(1:9) '1' pname(end-4:end)];
    
    mkdir(sprintf('/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/px1Label_LKB/%s',pname));
    
end 

    
%% load in files and save

for i = 1:length(TproxID)
    
    
    pname = replace(TproxID{i},'-','_');
    pname = [pname(1:9) '1' pname(end-4:end)];
    
    newPath = ['/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/' reader '/' pname];
    
    %loadPath = [folderPath '/' pname '/Annotations/' 'LS' num2str(temp_num(i)) '.nii.gz'];
    
    fname = LKB(i).name;
    
    vol = load_untouch_nii([folderPath '/' fname]);
    %vol = load_untouch_nii(loadPath);
        
    fname_new = ['LS' num2str(temp_num(i))] ;
    
    save_untouch_nii(vol, [newPath '/' fname_new])
    


end 
