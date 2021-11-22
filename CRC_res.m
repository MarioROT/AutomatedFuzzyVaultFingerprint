function  [New_Key,RD]=CRC_res(Key,pol)

NP=length(pol);

New_Key=[Key,zeros(1,NP-1)];
% fprintf('Dimensiones de New_Key: [%d,%d] \n', size(New_Key))
% disp(New_Key)
Ind=find(New_Key==1,1);
% [rrr,lll] = size(New_Key==1);
% disp(rrr)
% disp(lll)
R=New_Key(Ind:end);
NK=length(R);
% fprintf('Dimensiones de R: [%d] \n', NK)

while NK>=NP
 D=NK-NP;
 z=zeros(1,D);
 
 pol_f=cat(2,pol,z);
 
 Q=xor(R,pol_f);
 ind=find(Q==1,1);
%  disp(ind)
 R=Q(ind:end);
 NK=length(R);
%  fprintf('Dimensiones de R: [%d] \n', NK)
end

RD=zeros(1,NP-1);
L=length(R);
RD(end-L+1:end)=R;

New_Key(end-NP+2:end)=RD;

