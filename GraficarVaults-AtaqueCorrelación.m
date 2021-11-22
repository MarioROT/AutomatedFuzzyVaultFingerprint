
Imgs= dir(strcat(pwd,'\DB1_B\*.tif'));

cont = 0;
huf = 1;
for hu=1:length(Imgs)
cont = cont + 1;   
if cont == 9
    huf = huf+1;
    cont = 1;
end
im_no(huf,cont) = string(Imgs(hu).name(1:5));
inds(huf,cont) = cont;
end

[s1_ino,s2_ino] = size(im_no);
for i =1:s1_ino
    combs(i,:, :) =  nchoosek(inds(i,:),2);
end
[s1,s2,s3] = size(combs);

for r = 1:s1
   for t = 1:s2
       comb_names(r,t,:) = im_no(r,combs(r,t,:));
   end
end

for i = 5:5%1:s1
    for j = 1:s2
        name1 = comb_names(i,j,1)
        name2 = comb_names(i,j,2)
        Vault1 = load(strcat('Vaults\Vault',name1, '.txt'));
        Vault2 = load(strcat('Vaults\Vault',name2, '.txt'));
        Real_XY1 = load(strcat('Real_XYs\Real_XY', name1, '.txt'));  %%%% Vault T
        Real_XY2 = load(strcat('Real_XYs\Real_XY', name2, '.txt'));  %%%% Vault Q
        Chaff_Data1 = load(strcat('Chaff_Datas\Chaff_Data', name1, '.txt'));  %%%% Vault T
        Chaff_Data2 = load(strcat('Chaff_Datas\Chaff_Data', name2,'.txt'));  %%%% Vault Q
        
%         figure;
        hFig = figure(2);
        set(gcf,'position',get(0,'ScreenSize'))
        subplot(1,2,1),plot(Vault1(:,1),Vault1(:,2),'kv'), title('Bovedas Original: ' + name1 + ' y ' + name2);
                       hold on;
                       plot(Vault2(:,1),Vault2(:,2),'ro');
        subplot(1,2,2),plot(Real_XY1(:,1),Real_XY1(:,2),'kx'), title('Boveda Con Real y Chaffs Señalados');
                       hold on;
                       plot(Real_XY2(:,1),Real_XY2(:,2),'rx');
                       plot(Chaff_Data1(:,1),Chaff_Data1(:,2),'ko');
                       plot(Chaff_Data2(:,1),Chaff_Data2(:,2),'ro');
        inmp = input('Presiona enter para ir a la siguiente comparativa o presiona espacio+1+2+enter para salir')
        if isempty(inmp)
            close all;
        else
            break
            close all;
        end
    end
    if isempty(inmp)
        close all;
    else
        break
        close all;
    end
end

