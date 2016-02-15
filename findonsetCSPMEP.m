function [find_25ms_points,Onsets_CSP_option_A,Onsets_CSP_option_B] = findonsetCSPMEP(LOCS,t_windows,fs,s,wx,j)
% Groenveld D., may 2015
%
% See also automatic_csp_determination, findoffsetCSP, PSDframetemplate, PSDframesallwindows
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

if wx==1
find_25ms_points=(LOCS(1,j)+0.025*fs)/fs;
s_abs=abs(s);
LOCS_minima_around_25ms=0;
for i=1:length(LOCS(1,j))
    t_search=find_25ms_points(:,i)*fs-100:1:find_25ms_points(:,i)*fs+100;
    [LOCS2,PKS2]=peakseek(s_abs(round(t_search)),0.04*fs,0.5);  

    if length(LOCS2)<1
    A=s_abs(round(t_search));
    B=max(s_abs(round(t_search)));
    [I,J]=find(A==B);
    LOCS2=I;
    end
    
    LOCS2=t_search(LOCS2);
    LOCS_minima_around_25ms=[LOCS_minima_around_25ms LOCS2];
end
LOCS_minima_around_25ms(:,1)=[];

Onsets_CSP_option_B=LOCS_minima_around_25ms/fs;

[A,B]=find(diff_all_LOCS==max(diff_all_LOCS));
max_window_LOC_number=B(1,1);
i=max_window_LOC_number;  % longest window between time windows of interest (ie t_windows)

t_without_t_window=round(t_windows(end,i)*fs):round(t_windows(1,i+1)*fs);
s_without_t_window=nan(length(t_without_t_window),length(LOCS));

t_without_t_window1=1:round(t_windows(1,1)*fs);  % this one is slightly different from rest, fill rest matrix with mean of its peaks:
s_without_t_window(:,1)=[s(t_without_t_window1);ones(length(t_without_t_window)-length(t_without_t_window1),1)*mean(s(t_without_t_window1))];

avg_min_peaks=0;
inverse_s=s_without_t_window(:,1).*-1;
[locs pks]=peakseek(inverse_s,1,mean(s(t_without_t_window1)));
avg_min_peak=mean(pks);

% or use the normal average below (not the average of the minima!):
% avg_min_peak=mean(s(t_without_t_window1));
avg_min_peaks=[avg_min_peaks avg_min_peak];
for i=1:length(LOCS(1,j))-1
    t_without_t_window1=round(t_windows(end,i)*fs):round(t_windows(1,i+1)*fs);
    if length(t_without_t_window)==length(t_without_t_window1)
        s_without_t_window(:,1+i)=s(t_without_t_window1);
    else
        s_without_t_window(:,1+i)=[s(t_without_t_window1);ones(length(t_without_t_window)-length(t_without_t_window1),1)*mean(s(t_without_t_window1))];
    end
    inverse_s=s_without_t_window(:,1+i).*-1;
    [locs pks]=peakseek(inverse_s,1,mean(s(t_without_t_window1)));
    avg_min_peak=mean(pks);
    avg_min_peaks=[avg_min_peaks avg_min_peak];
end
avg_min_peaks(:,1)=[];
avg_min_peaks=avg_min_peaks*-1;

% implement search program for 1st of 5 points below avg_min_peaks of corresponding window!
Onsets_CSP_option_A=nan(1,1);
for i=1:length(LOCS(1,j))
    reverse_search_from_onset=round(Onsets_CSP_option_B(1,i)*fs):-1:round(Onsets_CSP_option_B(1,i)*fs)-200;
    j=1;
    while j<201
        if s(reverse_search_from_onset(1,j))>avg_min_peaks(1,i)
            Onsets_CSP_option_A(1,i)=round(Onsets_CSP_option_B(1,i)*fs)-j+1;
            j=201;
        end
        j=j+1;
    end
end
Onsets_CSP_option_A=Onsets_CSP_option_A/fs;
    

elseif wx==0
    %%
find_25ms_points=(LOCS+0.025*fs)/fs;

s_abs=abs(s);
LOCS_minima_around_25ms=0;
for j=1:length(LOCS)
    t_search=find_25ms_points(:,j)*fs-100:1:find_25ms_points(:,j)*fs+100;
    [LOCS2,PKS2]=peakseek(s_abs(round(t_search)),0.04*fs,0.5);  
    
    if length(LOCS2)<1
    A=s_abs(round(t_search));
    B=max(s_abs(round(t_search)));
    [I,J]=find(A==B);
    LOCS2=I;
    end
    
    if length(LOCS2)>1
        LOCS2=LOCS2(1,1);
    end
    
    LOCS2=t_search(LOCS2);
    LOCS_minima_around_25ms=[LOCS_minima_around_25ms LOCS2];
end
LOCS_minima_around_25ms(:,1)=[];

Onsets_CSP_option_B=LOCS_minima_around_25ms/fs;
%%
% search longest window between time windows of interest (ie t_windows)
diff_all_LOCS=0;
for i=1:length(LOCS)-1
difference_LOCS=LOCS(i+1)-LOCS(i);
diff_all_LOCS=[diff_all_LOCS difference_LOCS];
end
diff_all_LOCS(:,1)=[];

[A,B]=find(diff_all_LOCS==max(diff_all_LOCS));
max_window_LOC_number=B(1,1);

i=max_window_LOC_number;   % longest window 
t_without_t_window=round(t_windows(end,i)*fs):round(t_windows(1,i+1)*fs);
s_without_t_window=nan(length(t_without_t_window),length(LOCS));

t_without_t_window1=1:round(t_windows(1,1)*fs);  % this one is slightly different from rest, fill rest matrix with mean of its peaks:
s_without_t_window(:,1)=[s(t_without_t_window1);ones(length(t_without_t_window)-length(t_without_t_window1),1)*mean(s(t_without_t_window1))];

avg_min_peaks=0;
inverse_s=s_without_t_window(:,1).*-1;
[locs pks]=peakseek(inverse_s,1,mean(s(t_without_t_window1)));
avg_min_peak=mean(pks);

% or use the normal average below (not the average of the minima!):
% avg_min_peak=mean(s(t_without_t_window1));
avg_min_peaks=[avg_min_peaks avg_min_peak];
for i=1:length(LOCS)-1
    t_without_t_window1=round(t_windows(end,i)*fs):round(t_windows(1,i+1)*fs);
    if length(t_without_t_window)==length(t_without_t_window1)
        s_without_t_window(:,1+i)=s(t_without_t_window1);
    else
        s_without_t_window(:,1+i)=[s(t_without_t_window1);ones(length(t_without_t_window)-length(t_without_t_window1),1)*mean(s(t_without_t_window1))];
    end
    inverse_s=s_without_t_window(:,1+i).*-1;
    [locs pks]=peakseek(inverse_s,1,mean(s(t_without_t_window1)));
    avg_min_peak=mean(pks);
    avg_min_peaks=[avg_min_peaks avg_min_peak];
end
avg_min_peaks(:,1)=[];
avg_min_peaks=avg_min_peaks*-1;

% implement search program for 1st points above avg_min_peaks of corresponding window!
Onsets_CSP_option_A=nan(1,length(LOCS));
for i=1:length(LOCS)
    reverse_search_from_onset=round(Onsets_CSP_option_B(1,i)*fs):-1:round(Onsets_CSP_option_B(1,i)*fs)-200;
    j=1;
    while j<201
        if s(reverse_search_from_onset(1,j))>avg_min_peaks(1,i)
            Onsets_CSP_option_A(1,i)=round(Onsets_CSP_option_B(1,i)*fs)-j+1;
            j=201;
        end
        j=j+1;
    end
end
Onsets_CSP_option_A=Onsets_CSP_option_A/fs;
end

end