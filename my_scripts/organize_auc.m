%%
clear all;
dir = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits';
folder = 'SV';
path = [dir '/' folder];
fname = 'SV_auc.mat';
var_name = 'SV_auc';
SV_auc = [];
%% 
for i = 1:3
    for j = 1:3
        load(sprintf(fullfile(path,'trainData_%d_%d.mat'),i,j));
        SV_auc = [ SV_auc; output.aucAll(:,3)' ];
    end 
end 
SV_auc = SV_auc';
%% save
writematrix(SV_auc,'/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/new_splits/AUC/SV_auc.xlsx');






%% write train SV_auc
dir = '/Users/mike/Desktop/MATLAB/models/newly_std/SV_auc';
reader = 'OG';
newpath = fullfile([dir '/' reader], [reader '_auc.mat']);
load(newpath);
xlswrite([reader '_auc'],SV_auc)

%% uh
clear all
reader = 'LKB';
load(['/Users/mike/Desktop/MATLAB/models/' reader '/uh_test/matlab.mat'],'aucMatrix');
xlswrite([reader '_uh_test'], aucMatrix);

%% ccf
clear all
reader = 'LKB';
load(['/Users/mike/Desktop/MATLAB/models/' reader '/ccfr_test/matlab.mat'],'aucMatrix');
xlswrite([reader '_ccfr_test'], aucMatrix);


