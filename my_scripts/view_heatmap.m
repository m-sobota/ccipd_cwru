%spreadsheet
tbl = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
fname = tbl.fileName(~cellfun('isempty',tbl.fileName));
path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1';
%*****CHANGE BELOW********
reader_path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new/px1Label_OG';

%% remember to create new folder with name of pat  
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/pz_feats.mat'); 
load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/top_pz_zone.mat'); 
%load('/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/fig_feats.mat');
%% 
%gleason or mask area---------

%variable = top_pz_zone([2 3],:);
%pz_feats = pz_feats([2 3]);
%variable = top_5gleas;

% file_names = tbl(205,:);
file_names = tbl(135,:);
proxID_table = file_names(1,1);
proxID = proxID_table.ProxID;
les_table = file_names(1,2);
les = les_table.fid;

%% fixing naming
i = 2; % 1 or 2 now)
j = 2; %1 or 2 for now
pname = replace(proxID{:},'-','_');
pname = [pname(1:9) '1' pname(end-4:end)]; 
pnum = pname(end-3:end);

T2 = niftiread(fullfile([path '/' pname], 'ADC_reg.nii.gz'));
pm = niftiread(fullfile([path '/' pname], 'PM.nii.gz'));
fig_feats = pz_feats{3};

%% 
for e = [124]

    inds = find(pm==1);
    feats = zeros(size(pm));
        
    feats(inds) = fig_feats(:,e)/max(fig_feats(:,e)); 


    
    cancer = niftiread(fullfile(path, [pname '/LS1.nii.gz']));

    %cancer = niftiread(fullfile(reader_path,top_pz_zone{i,3}));

    fname = ['/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/research_figs/' num2str(e) '_case_' pnum ];
    im_name = [ num2str(e) '_LKB_case_' pnum ];
    %overlayViewer(T2,double(pm), feats, im_name, 1, cancer);
    %overlayViewer_save(T2,double(pm), feats, fname, 1, cancer);
    overlayProbMap2(T2,double(pm), feats, fname, 1, cancer);
    
end 








%% creating 5x5 montage of feature images
current_pat = 77;
pat_77 = cell(75,1);

for f = 1:75
image = imread(['/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/temp/' num2str(f) '_case_' num2str(current_pat) '.png']);
pat_77{f} = image;
end 

pat_77_array = cell(3,1);
pat_77_array{1} = pat_77(1:25);
pat_77_array{2} = pat_77(26:50);
pat_77_array{3} = pat_77(51:75);

for w = 1:3
montage(pat_77_array{w});
print('-r300', ['/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/montages/77_OG/' num2str(current_pat) '_' num2str(w) '.png'],'-dpng')
end 

save('/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/montages/77_OG/pat_77_array','pat_77_array') 


%% image saving for figure making 
readers = {'JR' 'LKB' 'RDW' 'SHT' 'SV'};
path = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/px1_ann_new' ;
T2 = niftiread('/Volumes/GoogleDrive/My Drive/Sobota_Michael/Volumes/proX1/ProstateX1_0195/ADC_res.nii.gz');
T2 = fliplr(imrotate(T2,270));
slice = 6;
T2 = double(T2(:,:,slice));


for i = 1:length(readers)
    
    load_path = [path '/px1Label_' readers{i} '/ProstateX1_0195/LS1.nii'];
    imdat = niftiread(load_path);
    edgeLes = edge(imdat(:,:,slice),'canny');
    edgeLes = fliplr(imrotate(edgeLes,270));
    imshow(T2,[]);
    hold on;
    h1 = imshow(edgeLes);
    set(h1,'AlphaData');
    
    print('-r300',['/Volumes/GoogleDrive/My Drive/Sobota_Michael/pixelData/research_figs/' readers{i} '_p195' '.png'],'-dpng');
    
end 
    
    
    



