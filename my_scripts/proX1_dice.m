addpath('/Users/mike/Desktop/MATLAB/Functions/NIfTI_20140122');
L1path = '/Users/mike/Desktop/MATLAB/proX1_data/proX1_annotations/px1Label_JR';
L2path = '/Users/mike/Desktop/MATLAB/proX1_data/proX1_annotations/px1Label_LKB';
L3path = '/Users/mike/Desktop/MATLAB/proX1_data/proX1_annotations/px1Label_Original';
%% 
L1struc = dir(L1path);
L1struc(1:3) = [];
L2struc = dir(L2path);
L2struc(1:3) = [];
L3struc = dir(L3path);
L3struc(1:2) = [];
%% 
dice_mat = zeros(112,6);
sum_mat = zeros(112,3);

for i = 1:length(L1struc)
    
    display(['Reading File: ' L1struc(i).name]) 
    
    R1 = niftiread(fullfile(L1path,L1struc(i).name));
    R2 = niftiread(fullfile(L2path,L2struc(i).name));
    R3 = niftiread(fullfile(L3path,L3struc(i).name));
    
    dice_mat(i,1) = dice(logical(R1),logical(R2));
    dice_mat(i,2) = dice(logical(R2),logical(R3));
    dice_mat(i,3) = dice(logical(R3),logical(R1));
    
    store_dice1 = zeros(size(R1,3),1);
    store_dice2 = zeros(size(R2,3),1);
    store_dice3 = zeros(size(R3,3),1);
    
    for j = 1:size(R1,3)
        store_dice1(j) = dice(logical(R1(:,:,j)),logical(R2(:,:,j)));
        store_dice2(j) = dice(logical(R2(:,:,j)),logical(R3(:,:,j)));
        store_dice3(j) = dice(logical(R3(:,:,j)),logical(R1(:,:,j)));  
    end 
    
    dice_mat(i,4) = max(store_dice1);
    dice_mat(i,5) = max(store_dice2);
    dice_mat(i,6) = max(store_dice3);
    
    sum_mat(i,1) = sum(reshape(sum(sum(R1,1),2),1,[]));
    sum_mat(i,2) = sum(reshape(sum(sum(R2,1),2),1,[]));
    sum_mat(i,3) = sum(reshape(sum(sum(R3,1),2),1,[]));
end

        
        
        
        
        
        
        
        
        