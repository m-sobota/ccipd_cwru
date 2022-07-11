csv = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/significance_ccf.csv');
table = readtable('/Volumes/GoogleDrive/My Drive/Sobota_Michael/spreadsheets/ProstateX-2-Findings-Train-Corrected.xlsx');
ID = table.ProxID(~cellfun('isempty',table.ProxID));
%% 
%num = csv.PatientID(360:684);
%data = ones(size(num));
lesnum = csv.LesionNum(360:684);
tru = csv.Sig(360:684);

%% 
for i = 1:length(ID)
    check_ = ID{i}(end-3:end);
    if contains(check_, '0000')
        check = '0';
    elseif contains(check_, '000')
        check = check_(end);
    elseif contains(check_,'00')
        check = check_(end-1:end);
    else 
        check = check_(end-2:end);
    end 
    temp = find(num==str2double(check));
    data(temp) = 0;  
end 

%% 
ProID = num(find(data));
Les = lesnum(find(data));
Sig = tru(find(data));

