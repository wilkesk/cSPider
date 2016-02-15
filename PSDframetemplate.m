function [x_axis_P_sum2,P_sum2] = PSDframetemplate(i,t_windows,s,fs)
% Groenveld D., may 2015
%
% See also automatic_csp_determination, findoffsetCSP, PSDframesallwindows
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

t_example1=t_windows(:,i);
t_example2=t_example1*fs;
t_example2=round(t_example2');
s_example=s(t_example2);

[S,F,T,P] = spectrogram(s_example,100,[],[],[]);

j=1;
size_P=size(P);
collumns_P=size_P(:,2);
while j<(collumns_P+1)
P_sum(:,j)=sum(P(:,j));
j=j+1;
end

P_sum2=[0 P_sum];

% make x_axis as lang as P_sum2:
x_axis_P_sum2=t_example2(1):51:t_example2(end);
if length(x_axis_P_sum2) == 24      % changes between 23 & 24 :)
    x_axis_P_sum2(:,end)=[];
end

end