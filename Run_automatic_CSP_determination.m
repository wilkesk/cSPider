%% Run_automatic_CSP_determination
clear all;clc;close all;

% When using the GUI, use the following code (and clicking Run above):
end_of_GUI=0;
while end_of_GUI==0
end_of_GUI=0;
GUI_cSPider
end
close all;
end_of_GUI=0;
wx=0;
x=0;
y=0;
z=0;

% Or use (uncomment) the code below instead of GUI for using cSPider 
% without the GUI. Using this, type 'help automatic_csp_determination' 
% in the Command Window below.
% %% Give methods of analysis:
% templ=4;
% rMT=0; 
% x=0;
% xy=1;
% y=0;
% yz=1;
% z=[0];

            
%% Load signal
[filename,pathname]=uigetfile('*.cfs','Select an CFS file');
[s,HDR]=mexSLOAD(filename,'OVERFLOWDETECTION:OFF');
fs=5000;        % sample frequency


%% Call function for automatic CSP determination
[Onsets_CSP2,Offsets_CSP2,MEP_durations,Peak2peak2]=automatic_csp_determination(templ,rMT,wx,x,xy,y,yz,z,s,fs);


%% Export data to Excel-file
delete patientdata_CSP.xls

if rMT==0
CSPs_110rMT_real_time=Offsets_CSP2(:,1:10)-Onsets_CSP2(:,1:10);
CSPs_120rMT_real_time=Offsets_CSP2(:,11:20)-Onsets_CSP2(:,11:20);
CSPs_130rMT_real_time=Offsets_CSP2(:,21:30)-Onsets_CSP2(:,21:30);
CSPs_140rMT_real_time=Offsets_CSP2(:,31:40)-Onsets_CSP2(:,31:40);

MEPs_110rMT_real_time=MEP_durations(:,1:10);
MEPs_120rMT_real_time=MEP_durations(:,11:20);
MEPs_130rMT_real_time=MEP_durations(:,21:30);
MEPs_140rMT_real_time=MEP_durations(:,31:40);

Peak2peaks_110rMT_real_time=Peak2peak2(:,1:10);
Peak2peaks_120rMT_real_time=Peak2peak2(:,11:20);
Peak2peaks_130rMT_real_time=Peak2peak2(:,21:30);
Peak2peaks_140rMT_real_time=Peak2peak2(:,31:40);

rownames = {'CSPs_110rMT','CSPs_120rMT','CSPs_130rMT','CSPs_140rMT','MEPs_110rMT','MEPs_120rMT','MEPs_130rMT','MEPs_140rMT','Peak2peaks_110rMT','Peak2peaks_120rMT','Peak2peaks_130rMT','Peak2peaks_140rMT'};
N = [CSPs_110rMT_real_time', CSPs_120rMT_real_time', CSPs_130rMT_real_time', CSPs_140rMT_real_time',MEPs_110rMT_real_time',MEPs_120rMT_real_time',MEPs_130rMT_real_time',MEPs_140rMT_real_time',Peak2peaks_110rMT_real_time',Peak2peaks_120rMT_real_time',Peak2peaks_130rMT_real_time',Peak2peaks_140rMT_real_time'];

% convert numeric data to a cell array of doubles
nCell = num2cell(N);

% concatenate everything into one cell array
outCell = [rownames;nCell];

% creating of the excel file
xlswrite('patientdata_CSP.xls',outCell)
disp('A file was created under the name patiendata_CSP')
end

if rMT==1
CSPs_110rMT_real_time=Offsets_CSP2(:,1:10)-Onsets_CSP2(:,1:10);
MEPs_110rMT_real_time=MEP_durations(:,1:10);
Peak2peaks_110rMT_real_time=Peak2peak2(:,1:10);

rownames = {'CSPs_110rMT','MEPs_110rMT','Peak2peaks_110rMT'};
N = [CSPs_110rMT_real_time',MEPs_110rMT_real_time',Peak2peaks_110rMT_real_time'];

% convert numeric data to a cell array of doubles
nCell = num2cell(N);

% concatenate everything into one cell array
outCell = [rownames;nCell];

% creating of the excel file
xlswrite('patientdata_CSP.xls',outCell)
disp('A file with all the CSPs was created under the name patiendata_CSP')
end

if rMT==2
CSPs_120rMT_real_time=Offsets_CSP2(:,1:10)-Onsets_CSP2(:,1:10);
MEPs_120rMT_real_time=MEP_durations(:,1:10);
Peak2peaks_120rMT_real_time=Peak2peak2(:,1:10);

rownames = {'CSPs_120rMT','MEPs_120rMT','Peak2peaks_120rMT'};
N = [CSPs_120rMT_real_time',MEPs_120rMT_real_time',Peak2peaks_120rMT_real_time'];

% convert numeric data to a cell array of doubles
nCell = num2cell(N);

% concatenate everything into one cell array
outCell = [rownames;nCell];

% creating of the excel file
xlswrite('patientdata_CSP.xls',outCell)
disp('A file with all the CSPs was created under the name patiendata_CSP')
end

if rMT==3
CSPs_130rMT_real_time=Offsets_CSP2(:,1:10)-Onsets_CSP2(:,1:10);
MEPs_130rMT_real_time=MEP_durations(:,1:10);
Peak2peaks_130rMT_real_time=Peak2peak2(:,1:10);

rownames = {'CSPs_130rMT','MEPs_130rMT','Peak2peaks_130rMT'};
N = [CSPs_130rMT_real_time',MEPs_130rMT_real_time',Peak2peaks_130rMT_real_time'];

% convert numeric data to a cell array of doubles
nCell = num2cell(N);

% concatenate everything into one cell array
outCell = [rownames;nCell];

% creating of the excel file
xlswrite('patientdata_CSP.xls',outCell)
disp('A file with all the CSPs was created under the name patiendata_CSP')
end

if rMT==4
CSPs_140rMT_real_time=Offsets_CSP2(:,1:10)-Onsets_CSP2(:,1:10);
MEPs_140rMT_real_time=MEP_durations(:,1:10);
Peak2peaks_140rMT_real_time=Peak2peak2(:,1:10);

rownames = {'CSPs_140rMT','MEPs_140rMT','Peak2peaks_140rMT'};
N = [CSPs_140rMT_real_time',MEPs_140rMT_real_time',Peak2peaks_140rMT_real_time'];

% convert numeric data to a cell array of doubles
nCell = num2cell(N);

% concatenate everything into one cell array
outCell = [rownames;nCell];

% creating of the excel file
xlswrite('patientdata_CSP.xls',outCell)
disp('A file with all the CSPs was created under the name patiendata_CSP')
end