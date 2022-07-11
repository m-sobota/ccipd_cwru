%% finding top 3 mask magnitudes
top_sums = cell(112,5);

for i = 1:length(fname)

%this is so bad (below)
fileNumber1 = erase(fname{i},'_T2W_std-label.nii');
fileNumber2 = erase(fileNumber1,'_T2W_std-label_1.nii');
fileNumber3 = erase(fileNumber2,'_T2W_std-label_2.nii');
fileNumber = erase(fileNumber3,'_T2W_std-label_3.nii');

cancer = niftiread(fullfile(reader_path,[fileNumber '_L' num2str(les(i)) 'proX1-label.nii']));
les_pres = reshape(sum(sum(cancer,1),2),[],1);
total_mask = sum(les_pres);

top_sums{i,1} = total_mask;
top_sums{i,2} = proID{i};
top_sums{i,3} = fname{i};
top_sums{i,4} = les(i);
top_sums{i,5} = i;

end 

[~, loc] = sort(cell2mat(top_sums(:,1)),'descend');
top_5sum = top_sums(loc(1:5),:);

top_5gleas = cell(5,5);
[~, loc_g] = sort(gleas(:,1),'descend');
for j = 1:5
top_5gleas{j,1} = gleas(loc_g(j),1);
top_5gleas{j,2} = top_sums(loc_g(j),2);
top_5gleas{j,3} = top_sums(loc_g(j),3);
top_5gleas{j,4} = cell2mat(top_sums(loc_g(j),4));
top_5gleas{j,5} = cell2mat(top_sums(loc_g(j),5));
end 

save('OG_top_gleas','top_5gleas')
save('OG_top_sum','top_5sum')