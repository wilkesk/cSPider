function [Onsets_CSP2,Offsets_CSP2,MEP_durations,Peak2peak2] = automatic_csp_determination(j,rMT,wx,x,xy,y,yz,z,s,fs);
% This function finds the CSP onsets and offsets for a given TMS measurement trial
% (i.e. at least 10 experiments) measured under the normal CSP measurement 
% window length or number of datapoints. Times of CSP pulses are defined in
% 'timing_csp_pulses.txt' for a full measurement (4 times 10 pulses) and 
% 'timing_csp_pulses_1trial.txt' for 1 trial (1 time 10 pulses)
%
%
% Call this function always with the following inputs:
%
% templ: window of which we'll choose a template (and examples) from. NB: with 
% only 1 run, maximum templ can be 10!
%
% rMT: choose rMT=1,2,3 or 4 when only 1 run (10 CSPs) is measured, for 
% respectively the strength TMS 110%, 120%, 130% 140% rMT. Choose rMT=0 for 
% all (4) runs included
%
% wx: choose wx=1 to only analyze chosen template, in which the CSP offset is 
% chosen manually and results are in the command window
%
% x: choose x=1 if, for any reason, a shorter window is preferred (standard: x=0)
%
% xy: choose xy=1 if a visual check of all windows is desired, only possible for all 
% (4) runs (plots all windows behind each other plus on- and offsets) 
%
% y: choose y=0 for 1st option onset (real start) or y=1 for 2nd (minimum around
% 25 ms after TMS artefact)
%
% yz: choose yz=0 for MEP offset finder with filtered signal + peakseek, yz=1 for 
% MEP offset finder with spectrograms + matched filter, or yz=2 for fixed MEP 
% duration (from found onset) of 0.025 ms (standard)
%
% z: give a row with failed (pulse) numbers of the data in the CSP-measurement. 
% Give value 0 when no failures! Example: z=[3,4,8];
%
%
% Groenveld D., may 2015
%
% See also findoffsetCSP, findonsetCSPMEP, PSDframetemplate, PSDframesallwindows
%
% Copyright: This is published under NeuroCure Clinical Center (NCRC),
% Cluster of Excellence NeuroCure of the Charité – Universitätsmedizin Berlin, 
% Charitéplatz 1, 10117 Berlin
% All rights reserved.
% All copyright for the following code are owned in full by the Cluster of 
% Excellence NeuroCure of the Charité – Universitätsmedizin Berlin.
% Permission is granted to download, share and use this software as long as any
% publications made in which this software was used for any purpose reference 
% the corresponding article of this software: "cSPider – Evaluation of a free 
% and open-source automated tool to analyze corticomotor silent period" etc.

t=(1:length(s))/fs;

% signal in real time:
figure()
plot(t,s)
title('EMG-signal in real time','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');


%% Creating windows of interest (with use of 'timing_csp_pulses.txt'):

% getting the data in cells
if rMT==1 || rMT==2 || rMT==3 || rMT==4
fid=fopen('timing_csp_pulses_1trial.txt');
elseif rMT==0
    fid=fopen('timing_csp_pulses.txt');
% standard:
% 3     7.1     11.7    15.9    20.8    26.6    31.1    36.3    40.5    45.7	
% 53    57.1    61.7    65.9    70.8    76.6    81.1    86.3    90.5    95.7	
% 103   107.1   111.7   115.9   120.8   126.6   131.1   136.3   140.5   145.7	
% 153   157.1   161.7   165.9   170.8   176.6   181.1   186.3   190.5   195.7	
end

% this reads the lines in a cell:
txt={};
tline=fgets(fid);
while ischar(tline)
    txt=[txt;tline];
    tline=fgets(fid);
end

% finding the numbers and put them in collumns per phase/electrode
if rMT==0
LOCS_110rMT=(0*200+str2double(txt{1}))*fs;
LOCS_120rMT=(1/4*200+str2double(txt{1}))*fs;
LOCS_130rMT=(2/4*200+str2double(txt{1}))*fs;
LOCS_140rMT=(3/4*200+str2double(txt{1}))*fs;
LOCS=[LOCS_110rMT LOCS_120rMT LOCS_130rMT LOCS_140rMT];
end

if rMT==1
LOCS=(0*200+str2double(txt{1}))*fs;
end
if rMT==2
LOCS=(0*200+str2double(txt{1}))*fs;
end
if rMT==3
LOCS=(0*200+str2double(txt{1}))*fs;
end
if rMT==4
LOCS=(0*200+str2double(txt{1}))*fs;
end

% making the frames:
if x==0
    i=1;
    while i<=length(LOCS)
        t_windows(:,i)=(LOCS(i)-300:LOCS(i)+1800);
        i=i+1;
    end
else
    i=1;
    while i<=length(LOCS)
        t_windows(:,i)=(LOCS(i)-300:LOCS(i)+1300);
        i=i+1;
    end
end

% delete the data in s (no deletion, but good enough (can't be found by
% matched filter :) --> zoom in on figure to see it!)
if z(1,1)==0;
else
    z2=fliplr(z);
    for z3=z2;
        s(round(t_windows(:,z3)))=0;
    end
end

% delete the data of given failures in the just determined windows and signal
if z(1,1)==0;
    disp('No failures given manually, i.e. 0 failed CSP trials during measurement')
else
    for z3=z2
        t_windows(:,z3)=[];
        LOCS(:,z3)=[];
    end
end

if z(1,1)==0;
else
% signal in real time:
figure()
plot(t,s)
title('Signal with deleted windows','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
end

t_windows=t_windows/fs;

if wx==1
    t_windows2=t_windows(:,j);
end

%% Find onsets of CSPs and make example window:
[find_25ms_points,Onsets_CSP_option_A,Onsets_CSP_option_B] = findonsetCSPMEP(LOCS,t_windows,fs,s,wx,j);
if y==0
    Onsets_CSP=Onsets_CSP_option_A;
elseif y==1
    Onsets_CSP=Onsets_CSP_option_B;
end

i=j;
% example of window in real time to check
t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

if wx==1
figure();
subplot(2,1,1)
plot(t_example1,s_example)
hold on
plot(find_25ms_points*ones(size(s)),s,'red','Linewidth',1)
title('Windowed signal + 20ms point determination','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
subplot(2,1,2)
plot(t_example1,s_example)
hold on
plot(Onsets_CSP*ones(size(s)),s,'red','Linewidth',1)
title('Windowed signal + mininum around 20ms point (=onsets CSPs and onsets MEPs)','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
elseif wx==0    
figure();
subplot(2,1,1)
plot(t_example1,s_example)
hold on
plot(find_25ms_points(:,i)*ones(size(s)),s,'red','Linewidth',1)
title('Windowed signal + 20ms point determination','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
subplot(2,1,2)
plot(t_example1,s_example)
hold on
plot(Onsets_CSP(:,i)*ones(size(s)),s,'red','Linewidth',1)
title('Windowed signal + mininum around 20ms point (=onsets CSPs and onsets MEPs)','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
end

if wx==1
disp('Choose CSP offset of current window')
g_userinput1=ginput(1);
CSP_onset=Onsets_CSP
CSP_offset=g_userinput1(1,1)
CSP_duration=CSP_offset-CSP_onset
figure();
plot(t_example1,s_example)
hold on
plot(CSP_onset*ones(size(s)),s,'red','Linewidth',1)
title('Example windowed signal + found CSP onset and offset','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
hold on
plot(CSP_offset*ones(size(s)),s,'red','Linewidth',1)
elseif wx==0 % goes all the way down!


%% Finding MEP offsets (=start point searching CSP offsets):
if yz==0
    N=3;
    cf=0.01;
    [B,A]=butter(N,cf,'low');
    s_filt=filtfilt(B,A,s);
    abs_s_filt=abs(s_filt);
    s_example=abs(s_filt(t_example2));
    
figure();
plot(t_example1,s_example)
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
title('Windowed signal','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
plot(t,abs_s_filt)
    
    [LOCS2,PKS2]=peakseek(abs_s_filt,1,0.2);
    possible_end_MEP=LOCS2/fs;
    i=1;
possible_end_MEP2=0;
possible_end_MEP3=0;
while i<length(Onsets_CSP)+1
    for j=1:length(possible_end_MEP)
        if Onsets_CSP(1,i)<possible_end_MEP(j)
            if possible_end_MEP(j)<Onsets_CSP(1,i)+0.06
            possible_end_MEP2=[possible_end_MEP2 j];
            end
        end
    end
    possible_end_MEP3=[possible_end_MEP3 possible_end_MEP2(1,end)];
    possible_end_MEP2=0;
    i=i+1;
end

for i=fliplr(1:length(possible_end_MEP3))
    if possible_end_MEP3(1,i)==0
        possible_end_MEP3(:,i)=[];
    end
end

end_MEP=LOCS2(possible_end_MEP3)/fs;


elseif yz==1

i=j;
[x_axis_P_sum4_all_frames,P_sum4_all_frames]=PSDframesallwindows(LOCS,t_windows,s,fs);
[x_axis_P_sum2,P_sum2]=PSDframetemplate(i,t_windows,s,fs);

% example window & spectrogram choosing template for matched filter
t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

figure();
subplot(2,1,1)
plot(t_example1,s_example)
line('XData',[Onsets_CSP(:,i) Onsets_CSP(:,i)], 'YData', [-2 2], 'LineStyle', '--', ...
    'LineWidth', 2, 'Color','k')
line('XData',[Onsets_CSP(:,i)+0.035 Onsets_CSP(:,i)+0.035], 'YData', [-2 2], 'LineStyle', '--', ...
    'LineWidth', 2, 'Color','k')
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
title('Windowed signal for choosing template (with estimated onset and offset template)','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
subplot(2,1,2)
x_axis_P_sum2_real_time=x_axis_P_sum2/fs;
plot(x_axis_P_sum2_real_time,P_sum2,'red')
line('XData',[Onsets_CSP(:,i) Onsets_CSP(:,i)], 'YData', [0 300], 'LineStyle', '--', ...
    'LineWidth', 2, 'Color','k')
line('XData',[Onsets_CSP(:,i)+0.035 Onsets_CSP(:,i)+0.035], 'YData', [0 300], 'LineStyle', '--', ...
    'LineWidth', 2, 'Color','k')
xlim([t_windows(1,i) t_windows(end,i)])
title('Spectrogram for choosing template','Fontweight','bold');
xlabel('Time (s)');
ylabel('PSD per 0.01 seconds');

disp('Choose the exact onset and offset of the MEP in the figure')

g_userinput1=ginput(1)*fs;
g_userinput2=ginput(1)*fs;

j=1;
while g_userinput1(:,1) > x_axis_P_sum2(:,j)
    j=j+1;
end
j;      % number of row of t_windows in which g_userinput1 is!

k=1;
while g_userinput2(:,1) > x_axis_P_sum2(:,k)
    k=k+1;
end
k;      % number of row of t_windows in which g_userinput2 is!

x_found=j:k;
x=P_sum2(x_found);

% Using 'matched filter' with chosen template
h=fliplr(x);           
u=P_sum4_all_frames;    
ylin=filter(h,1,u);     
ynon=matchednl(x,u);    % -1 <= ynon(n) <= 1

[PKS2,LOCS2]=findpeaks(ynon,'MINPEAKHEIGHT',0.95,'MINPEAKDISTANCE',0.05.*10^2);
% NB: get only the good LOCS2 (delete the pre-pulse found peaks
% & only use first found peak after the pulse:
possible_end_MEP=x_axis_P_sum4_all_frames(LOCS2)/fs;
i=1;
possible_end_MEP2=0;
possible_end_MEP3=zeros(length(Onsets_CSP),1);
while i<length(Onsets_CSP)
    for j=1:length(possible_end_MEP)
        if Onsets_CSP(1,i)<possible_end_MEP(j)
            if possible_end_MEP(j)<Onsets_CSP(1,i)+0.06
            possible_end_MEP2=[possible_end_MEP2 j];
            end
        end
    end
        if length(possible_end_MEP2)==1
            % nothing
        else
        possible_end_MEP3(i,:)=possible_end_MEP2(1,2);
        possible_end_MEP2=0;
        end
    i=i+1;
end
possible_end_MEP3=possible_end_MEP3';

for i=fliplr(1:length(possible_end_MEP3))
    if possible_end_MEP3(1,i)==0
        possible_end_MEP3(:,i)=[];
    end
end

end_MEP=x_axis_P_sum4_all_frames(LOCS2(possible_end_MEP3))/fs;


elseif yz==2
end_MEP=Onsets_CSP+0.025;
LOCS2=end_MEP*fs;
end


bad_intervals=0;

if length(LOCS2)<0.5*length(LOCS)
    disp('Choose new template and run whole script again: template was not good') 
    disp('for finding similarities in event')
else
% NB: this 'else' ends at the total end!


%% Manuel selection for missed offsets MEPs + example found offset MEP
a=size(t_windows);
if length(end_MEP)==a(1,2);
    % code below is unnecessary :)
else       
% find windows of failed MEP offset detection (through matched_filter)    
i=1;
j=1;
failed_peak_LOCS=0;
while i<length(LOCS)
if j>length(end_MEP)
    j=length(end_MEP);
end
if abs(LOCS(i)/fs-end_MEP(j))>1
    failed_peak_LOCS=[failed_peak_LOCS i];
    j=j-1;
end
i=i+1;
j=j+1;
end
failed_peak_LOCS(:,1)=[];


%% use this to find start points for searching offsets manually!
bad_intervals=0;
g_userinputs=0;
for i=failed_peak_LOCS
    t_example1=t_windows(:,i)*fs;
    t_example2=round(t_example1');
    s_windowed=s(t_example2);

    figure()
    plot(t_example2/fs,s_windowed)
    title('GUI for choosing offset MEP. Bad interval? --> Click on pulse (or somewhere begin interval)');
    xlabel('Time (s)');
    ylabel('Amplitude (mV)');
    ylim([-1.25 1.25])
    xlim([t_windows(1,i) t_windows(end,i)])
    disp('Choose offset MEP in current figure')

    g_userinput1=ginput(1);
    g_userinputs=[g_userinputs g_userinput1(1,1)];
    disp('Given input: manual input')
    if g_userinput1(1,1)<Onsets_CSP(1,i)
        bad_intervals=[bad_intervals i]
    end
end
if length(bad_intervals)>1
    bad_intervals(:,1)=[];
end
g_userinputs(:,1)=[];


% so now we know the lost rows of 'end_MEP' and their supposed to 
% be values; need to combine them and set them in 'end_MEP':
i=1;
j=1;
k=1;
end_MEP2=nan(1,length(LOCS));
end_MEP2(1:length(end_MEP))=end_MEP;
while i<length(LOCS)
if j>length(end_MEP)
    j=length(end_MEP);
end    
if abs(LOCS(i)/fs-end_MEP(j))>1
    end_MEP2(1,i)=g_userinputs(k);
    j=j-1;
    k=k+1;
else
    end_MEP2(1,i)=end_MEP(1,j);
end
i=i+1;
j=j+1;
end

% sometimes last point needs also manual attention when using script above:
g_userinputs=0;
for y=length(end_MEP2)
    t_example1=t_windows(:,y)*fs;
    t_example2=round(t_example1');
    s_windowed=s(t_example2);

    figure()
    plot(t_example2/fs,s_windowed)
    title('GUI for choosing offset MEP. Bad interval? --> Click on pulse (or somewhere begin interval)');
    ylim([-1.25 1.25])
    xlim([t_windows(1,i) t_windows(end,i)])
    xlabel('Time (s)');
    ylabel('Amplitude (mV)');
    disp('Choose offset MEP in current figure')
    
    g_userinput1=ginput(1);
    g_userinputs=[g_userinputs g_userinput1(1,1)];
    disp('Given input: manual input')
end
g_userinputs(:,1)=[];
end_MEP2(1,end)=g_userinputs(1,1);
    
% now found and replaced all lost peaks, put it in the original:
end_MEP=end_MEP2;
end


%% creating search windows from offsets MEPs for finding offsets CSPs
if yz==1
    t_search_windows=nan(length(end_MEP),2000-0.01*fs);
for i=1:length(end_MEP)
    t_search_windows(i,:)=end_MEP(:,i)*fs+0.01*fs:1:end_MEP(:,i)*fs+1999;
end
else
t_search_windows=nan(length(end_MEP),2000);
for i=1:length(end_MEP)
    t_search_windows(i,:)=end_MEP(:,i)*fs:1:end_MEP(:,i)*fs+1999;
end
end

% example of window in real time with found offsets MEPs & total MEP time
i=j; 
t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

figure();
subplot(2,1,1)
plot(t_example1,s_example)
hold on
plot(end_MEP(:,i)*ones(size(s)),s,'red','Linewidth',1)
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
title('Example windowed signal + found offset MEP (=start search point CSP offset)','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
subplot(2,1,2)
plot(t_example1,s_example)
hold on
plot(end_MEP(:,i)*ones(size(s)),s,'red','Linewidth',1)
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
hold on
plot(Onsets_CSP(:,i)*ones(size(s)),s,'red','Linewidth',1)
title('Example windowed signal of total MEP time','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');


%% Using the absolute derivative, moving averager & detection limit for CSP offset detection
% example of windowed idea
i=j;

% Finding offset points in all data
[Offsets_CSP]=findoffsetCSP(t_windows,t_search_windows,s,end_MEP+0.01,fs);

% example of window with found offset
t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

if xy==0
figure();
plot(t_example1,s_example)
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
hold on
plot(Offsets_CSP(:,i)*ones(size(s)),s,'red','Linewidth',1)
title('Example windowed signal + found CSP onset and offset','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
hold on
plot(Onsets_CSP(:,i)*ones(size(s)),s,'red','Linewidth',1)
end


%% Building tresholds for prevention of failures (i.e. wrong/no offsets CSPs)
for i=1:length(LOCS)
   if  yz==1
       start_search_window=end_MEP(:,i)+0.01;
   else
       start_search_window=end_MEP(:,i);
   end
   if  Offsets_CSP(:,i)-start_search_window<0.005
   t_example1=t_windows(:,i);
   t_example2=t_example1*fs;
   t_example2=round(t_example2');
   s_example=s(t_example2);
   
   figure()
   plot(t_example2/fs,s_example)
   ylim([-1.25 1.25])
   xlim([t_windows(1,i) t_windows(end,i)])
   title('GUI for choosing offset CSP. No CSP? --> click on pulse!');
   xlabel('Time (s)');
   ylabel('Amplitude (mV)');
   disp('GUI for choosing offset CSP. No CSP? --> click on pulse!')
   g_userinput1=ginput(1);
   
   if g_userinput1<end_MEP(:,i)
       disp('Given input: failure, no CSP')
       Offsets_CSP(:,i)=nan;
   else       
       Offsets_CSP(:,i)=g_userinput1(1,1);
       disp('Given input: manual input')
   end
   end
end


%% MEP measurements
% find mins, maxs (& later peak-to peaks)
PKS_minima=0;
PKS_maxima=0;
for j=1:length(LOCS)
    t_search=LOCS(:,j)+0.017*fs:1:LOCS(:,j)+220; % skip 1st 0.017s after pulse: can give wrong result
    minimum=min(s(round(t_search)));    % NB: NEVER do min= here!
    maximum=max(s(round(t_search)));
    PKS_minima=[PKS_minima minimum];
    PKS_maxima=[PKS_maxima maximum];
end
PKS_minima(:,1)=[];
PKS_maxima(:,1)=[];
Peak2peak=PKS_maxima-PKS_minima;


%% Build in failed windows in created data (we need 40 on- and offsets!)
% and calculation of MEP durations
if z(1,1)==0
    % do nothing :)
    Onsets_CSP2=Onsets_CSP;
    Offsets_CSP2=Offsets_CSP;
    end_MEP2=end_MEP;
    Peak2peak2=Peak2peak;

    for i=1:length(LOCS);
    if isempty(end_MEP2(:,i))==1;
        Onsets_CSP2(1,i)=NaN;
        end_MEP2(1,i)=NaN;
        Peak2peak2(1,i)=NaN;
    end
    end
    
    MEP_durations=end_MEP2-Onsets_CSP2;
else
Onsets_CSP2=nan(1,length(LOCS));
i=1;
while i<length(z)+1;
    if z(1,1)==z(1,i)
        Onsets_CSP2(1,1:z(1,i)-1)=Onsets_CSP(1,1:z(1,i)-1);
        Onsets_CSP2(1,z(1,i))=nan;
        i=i+1;
    else
        Onsets_CSP2(1,z(1,i-1)+1:z(1,i)-1)=Onsets_CSP(1,z(1,i-1)-(i-1)+1:z(1,i)-1-(i-1));
        Onsets_CSP2(1,z(1,i))=nan;
        i=i+1;
    end
end
Onsets_CSP2(1,z(1,i-1)+1:end)=Onsets_CSP(1,z(1,i-1)-(i-1)+1:end);

Offsets_CSP2=nan(1,40);
i=1;
while i<length(z)+1;
    if z(1,1)==z(1,i)
        Offsets_CSP2(1,1:z(1,i)-1)=Offsets_CSP(1,1:z(1,i)-1);
        Offsets_CSP2(1,z(1,i))=nan;
        i=i+1;
    else
        Offsets_CSP2(1,z(1,i-1)+1:z(1,i))=Offsets_CSP(1,z(1,i-1)-(i-1)+1:z(1,i)-(i-1));
        Offsets_CSP2(1,z(1,i))=nan;
        i=i+1;
    end
end
Offsets_CSP2(1,z(1,i-1)+1:end)=Offsets_CSP(1,z(1,i-1)-(i-1)+1:end);

end_MEP2=nan(1,40);
i=1;
while i<length(z)+1;
    if z(1,1)==z(1,i)
        end_MEP2(1,1:z(1,i)-1)=end_MEP(1,1:z(1,i)-1);
        end_MEP2(1,z(1,i))=nan;
        i=i+1;
    else
        end_MEP2(1,z(1,i-1)+1:z(1,i))=end_MEP(1,z(1,i-1)-(i-1)+1:z(1,i)-(i-1));
        end_MEP2(1,z(1,i))=nan;
        i=i+1;
    end
end
end_MEP2(1,z(1,i-1)+1:end)=end_MEP(1,z(1,i-1)-(i-1)+1:end);

Peak2peak2=nan(1,40);
i=1;
while i<length(z)+1;
    if z(1,1)==z(1,i)
        Peak2peak2(1,1:z(1,i)-1)=Peak2peak(1,1:z(1,i)-1);
        Peak2peak2(1,z(1,i))=nan;
        i=i+1;
    else
        Peak2peak2(1,z(1,i-1)+1:z(1,i))=Peak2peak(1,z(1,i-1)-(i-1)+1:z(1,i)-(i-1));
        Peak2peak2(1,z(1,i))=nan;
        i=i+1;
    end
end
Peak2peak2(1,z(1,i-1)+1:end)=Peak2peak(1,z(1,i-1)-(i-1)+1:end);

MEP_durations=end_MEP2-Onsets_CSP2;
end


%% build in bad_intervals removal (found by wrong CSP_onsets!):
if bad_intervals==0
    % nothing
else
for i=bad_intervals
    Onsets_CSP2(1,i)=NaN;
    MEP_durations(1,i)=NaN;
    Peak2peak2(1,i)=NaN;
end
end

for i=1:length(LOCS)
    if isempty(Onsets_CSP2(:,i))==1;
        Onsets_CSP2(1,i)=NaN;
        MEP_durations(1,i)=NaN;
        Peak2peak2(1,i)=NaN;
    end
     if isempty(Onsets_CSP2(:,i))==1;
        Onsets_CSP2(1,i)=NaN;
        MEP_durations(1,i)=NaN;
        Peak2peak2(1,i)=NaN;
    end
end

if isempty(a)==1
    z=2;
end


%% plot found MEP onset, CSP onset and offset
if xy==1 && length(Offsets_CSP2)==10
for i=1:10;
t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

figure();
plot(t_example1,s_example)
hold on
plot(Offsets_CSP2(:,i)*ones(size(s)),s,'red','Linewidth',1)
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
title('Example windowed signal + found CSP onset and offset','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
if bad_intervals==0
    % nothing
else
for j=bad_intervals
    Onsets_CSP2(:,j)=NaN;
    Offsets_CSP2(:,j)=NaN;
end
end
if Offsets_CSP2(:,i)==NaN
    %nothing
else
hold on
plot(end_MEP(:,i)*ones(size(s)),s,'red','Linewidth',1)
hold on
plot(Onsets_CSP2(:,i)*ones(size(s)),s,'red','Linewidth',1)
end
end
end

if xy==1 && length(Offsets_CSP2)==40
for i=1:40;
t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

figure();
plot(t_example1,s_example)
hold on
plot(Offsets_CSP2(:,i)*ones(size(s)),s,'red','Linewidth',1)
ylim([-1.25 1.25])
xlim([t_windows(1,i) t_windows(end,i)])
title('Example windowed signal + found CSP onset and offset','Fontweight','bold');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
if bad_intervals==0
    % nothing
else
for j=bad_intervals
    Onsets_CSP2(:,j)=NaN;
    Offsets_CSP2(:,j)=NaN;
end
end
if Offsets_CSP2(:,i)==NaN
    %nothing
else
hold on
plot(end_MEP(:,i)*ones(size(s)),s,'red','Linewidth',1)
hold on
plot(Onsets_CSP2(:,i)*ones(size(s)),s,'red','Linewidth',1)
end
end
end
end
end