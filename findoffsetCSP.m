function [Offsets_CSP] = findoffsetCSP(t_windows,t_search_windows,s,Start_point_search,fs)
% Groenveld D., may 2015
%
% See also automatic_csp_determination, findonsetCSPMEP, PSDframetemplate, PSDframesallwindows
%
% Copyright: This is published under NeuroCure Clinical Center (NCRC),
% Cluster of Excellence NeuroCure of the Charité – Universitätsmedizin Berlin., 
% Charitéplatz 1, 10117 Berlin
% All rights reserved.
% All copyright for the following code are owned in full by the Cluster of 
% Excellence NeuroCure of the Charité – Universitätsmedizin Berlin.
% Permission is granted to download, share and use this software as long as any
% publications made in which this software was used for any purpose reference 
% the corresponding article of this software: "The cSPider 1.0 - An open-source 
% automatic tool to analyze" etc.

N=3;
cf=0.1;
[B,A]=butter(N,cf,'high');
s_filt=filtfilt(B,A,s);
abs_diff_s=abs(diff(s_filt));

A=size(t_search_windows);
detection_limit=nan(1,A(1,1));
t_without_t_window=1:round(t_windows(1,1)*fs);
s_without_t_window=abs_diff_s(t_without_t_window);
[LOCS2,PKS2]=peakseek(s_without_t_window,1,0);
positive_abs_diff_EMG_data_outside_t_window=PKS2;    
detection_limit(1,1)=mean(positive_abs_diff_EMG_data_outside_t_window);
for i=1:A(1,1)-1
    t_without_t_window=round(t_windows(end,i)*fs):round(t_windows(1,i+1)*fs);
    s_without_t_window=abs_diff_s(t_without_t_window);
    [LOCS2,PKS2]=peakseek(s_without_t_window,1,0);
    positive_abs_diff_EMG_data_outside_t_window=PKS2;    
    detection_limit(1,i+1)=mean(positive_abs_diff_EMG_data_outside_t_window);
end

Offsets_CSP_per_window=0;
for i=1:A(1,1)
    MA_abs_diff_s=moving(abs_diff_s(round(t_search_windows(i,1:end)))',30);
    [LOCS3,PKS3]=peakseek(MA_abs_diff_s,1,0.75*detection_limit(1,i));
  
    if length(LOCS3)==0
    LOCS3=1;
    end
    
    Offsets_CSP_per_window=[Offsets_CSP_per_window LOCS3(1,1)];
end
Offsets_CSP_per_window=Offsets_CSP_per_window(1,2:end);
Offsets_CSP=Start_point_search+Offsets_CSP_per_window/fs;

end