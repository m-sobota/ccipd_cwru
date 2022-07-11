load '/home/mas542/MATLAB/featureStats/pz_feats_CCFR.mat';
load '/home/mas542/MATLAB/featureStats/pz_feats_UHPPF.mat';
load '/home/mas542/MATLAB/featureStats/feats_pz.mat';


%mat to cell
pz_cell = cell(3,1);
pz_cell{1,1} = pz_feats_CCFR;
pz_cell{2,1} = pz_feats_UHPPF;
pz_cell{3,1} = feats_pz;
%
%non_cell = cell(3,1);
%non_cell{1,1} = ccfr_non;
%non_cell{2,1} = og_non;
%non_cell{3,1} = uh_non;

% compute stability 
pz_interDifScore = measureInterStability(pz_cell);
%non_interDifScore = measureInterStability(non_cell);

save('/home/mas542/MATLAB/stability/pz_interDifScore', 'pz_interDifScore');
writematrix(pz_interDifScore','/home/mas542/MATLAB/stability/pz_inter.xlsx');
%save('/home/mas542/MATLAB/stability/non_interDifScore', 'non_interDifScore');
%writematrix(non_interDifScore','/home/mas542/MATLAB/stability/non_inter');


