## 27/7/2015 - Dylan Madisetti
## Under WTFPL

clear
disp('**************************')
disp('*    kMeans subdivider   *')
disp('**************************')
addpath ('helpers')

csv = input('* Please input data file:','s');

disp('** Loading raw data')
fflush(stdout);
file = csvread(strcat('csv/',csv,'.csv'));
[rows,cols] = size(file);
X  = file(2:end,2:end);

disp('** Preprocessing data')
fflush(stdout);
% Normalize
Xn = zeros(rows-1,cols-1);
for i = 1:cols-1
	mx = max(X(:,i));
	mn = min(X(:,i));
    Xn(:,i) = (X(:,i) - mn) / (mx - mn);
end

csv = input('* Please input messages file:','s');

disp('** Loading messages')
fflush(stdout);
[instances] = textread(strcat('csv/', csv ,'.csv'),'%s','delimiter','\n','headerlines',1);
quotes = {};
for i = 1:length(instances)
    j = findstr(instances{i}, ',')(1);
    quotes{i} = strtrim(instances{i}(j + 1:end));
end

[UB, LB] = bound();

disp('* Intially Processing')
fflush(stdout);
[success, costs, collective, counters] = kmeans(Xn,LB:UB,1:rows-1);

if !success
	disp('**** Something broke, not all Ks clustered ****')
end

disp('**** Processed. Press enter to continue ****')
pause;

manage;