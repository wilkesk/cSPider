function [x_axis_P_sum4_all_frames,P_sum4_all_frames] = PSDframesallwindows(LOCS,t_windows,s,fs)
% Groenveld D., may 2015
%
% See also automatic_csp_determination, findoffsetCSP, PSDframetemplate
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

i=2;
P_sum4_all_frames=0;
x_axis_P_sum4_all_frames=0;

while i<=length(LOCS)+1;   
    t_windows2=round(t_windows(:,i-1)*fs);
    t_windows2=t_windows2';
    [S,F,T,P] = spectrogram(s(t_windows2),100,[],[],[]);
        
    j=1;
    size_P=size(P);
    collumns_P=size_P(:,2);
    while j<(collumns_P+1)
        P_sum4(j)=sum(P(:,j));
        j=j+1;
    end

    % determination of PSD-frames of spectrogram times 10.^2 for visualization purposes
    x_axis_P_sum4=t_windows2(1):52:t_windows2(end);
    if length(x_axis_P_sum4) == 22      % changes between 21 & 22 :)
        x_axis_P_sum4(:,end)=[];
    end
    
    P_sum4_all_frames=[P_sum4_all_frames P_sum4];
    x_axis_P_sum4_all_frames=[x_axis_P_sum4_all_frames x_axis_P_sum4];
    
    i=i+1;
    clear P        % rewriting can be a problem sometimes
    clear P_sum
    clear P_sum4
end

end