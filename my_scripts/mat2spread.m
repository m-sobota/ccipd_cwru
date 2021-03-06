clear all;
dir = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/prob_scores';
readers = {'OG','LKB','JR','RDW','SV','STAPLE'};
inst = {'CC','UH'};
savePath = '/Volumes/GoogleDrive/My Drive/Sobota_Michael/models/newly_std/probScoreSpreadsheets';
%% 
tempMat = [];
%whole = zeros(85,18);
for r = 1:size(readers,2)
    
    for i = 1:2
        
        tempMat = [];
        
        load(sprintf(fullfile(dir,'prob_%s_%s.mat'),readers{r},inst{i}))
        
        for q = 1:3
            for e = 1:3
                tempMat = [tempMat; prob{q,e}'];
            end 
        end 
        
        switch i 
            case 1 
                whole = tempMat';
                writematrix(whole,sprintf(fullfile(savePath,'prob_%s_CC.xlsx'),readers{r}))
            case 2
                whole = tempMat';
                %whole(30:end,:) = [];
                writematrix(whole,sprintf(fullfile(savePath,'prob_%s_UH.xlsx'),readers{r}))
        end 
          clear tempMat  
    end 
end 
