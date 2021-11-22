VaultFij = load('Vaults\Vault105_1.txt');  %%%% Vault T
VaultMov = load('Vaults\Vault105_2.txt');  %%%% Vault Q
% L_Vault=size(Vault105_1,1); % numero de minucias en template

min_dist = 2250;

VaultMov = VaultMov';
VaultXt = VaultMov(1,:) - mean(VaultMov(1,:));
VaultYt = VaultMov(2,:) - mean(VaultMov(2,:));
VaultT = [VaultXt;VaultYt];

rotattempts = 1000;
rots = linspace(0,2,rotattempts);

transattempts = 10000;

for i = 1:rotattempts
    
    R = [cos(3.1416*rots(i)) -sin(3.1416*rots(i)); sin(3.1416*rots(i)) cos(3.1416*rots(i))];
    DataRot = R * VaultT;
    VaultMovRot = [DataRot(1,:)+ mean(VaultMov(1,:));DataRot(2,:)+ mean(VaultMov(2,:))];
    VaultMovRot = VaultMovRot';
    
    %-Las vaults comparadas deben entrar en forma n x 2, siendo n el numero puntos en el vault-#
    [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,0);
    
    %--- Las dos lineas de abajo solo se activan para pocas iteraciones e.g. 10 y activar display arriba 
%     inp = input('Presiona enter para continuar')
%     close all
    
    MatchPoints(i) = length(Vault_indiceV1);
end

maxmp = max(MatchPoints);
maxmpidx = find(MatchPoints==maxmp);

for j = 1:length(maxmpidx)

    R = [cos(3.1416*rots(maxmpidx(j))) -sin(3.1416*rots(maxmpidx(j))); sin(3.1416*rots(maxmpidx(j))) cos(3.1416*rots(maxmpidx(j)))];
    DataRot = R * VaultT;
    VaultMovRot = [DataRot(1,:)+ mean(VaultMov(1,:));DataRot(2,:)+ mean(VaultMov(2,:))];
    VaultMovRot = VaultMovRot';
    
    for k = 1:transattempts
        
        [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,0);
        
        dir1 = [VaultMovRot(:,1)+500,VaultMovRot(:,2)]; % Derecha
        dir2 = [VaultMovRot(:,1)-500,VaultMovRot(:,2)]; % Izquierda
        dir3 = [VaultMovRot(:,1),VaultMovRot(:,2)+500]; % Arriba
        dir4 = [VaultMovRot(:,1),VaultMovRot(:,2)-500]; % Abajo
        dir5 = [VaultMovRot(:,1)+500,VaultMovRot(:,2)+500]; % Arriba - Derecha
        dir6 = [VaultMovRot(:,1)+500,VaultMovRot(:,2)-500]; % Abajo - Derecha
        dir7 = [VaultMovRot(:,1)-500,VaultMovRot(:,2)+500]; % Arriba - Izquierda
        dir8 = [VaultMovRot(:,1)-500,VaultMovRot(:,2)-500]; % Abajo - Izquierda
        dirs = cat(3,dir1,dir2,dir3,dir4,dir5,dir6,dir7,dir8);
        [s1,s2,s3] = size(dirs);
        
        mk = 0; 
        
        for h = 1:length(s3)
        [Vault_indiceV1T,Real_PointsV1T,Vault_indiceV2T,Real_PointsV2T]=distancia_VaultsCA(VaultFij,dirs(:,:,h), min_dist,0);
            if length(Vault_indiceV1T) > mk
               mk =  length(Vault_indiceV1T);
               best_trans = dirs(:,:,h);
            else
                best_trans = [];
            end
        end
        
        if isempty(best_trans)
            continue
        else
            [Vault_indiceV1BT,Real_PointsV1BT,Vault_indiceV2BT,Real_PointsV2BT]=distancia_VaultsCA(VaultFij,best_trans, min_dist,0);
        
            if length(Vault_indiceV1BT) > length(Vault_indiceV1)
                VaultMovRot = best_trans;
            end
        end
    end
    b_trans4rot(:,:, j) = VaultMovRot;
end

[sb1,sb2,sb3] = size(b_trans4rot);
mk2 = 0;
for f =1:sb3
    [Vault_indiceV1BT4R,Real_PointsV1BT4R,Vault_indiceV2BT4R,Real_PointsV2BT4R]=distancia_VaultsCA(VaultFij,b_trans4rot(:,:,f), min_dist,0);
    if length(Vault_indiceV1BT4R)> mk2
       mk2 = length(Vault_indiceV1BT4R);
       VaultMovRot = b_trans4rot(:,:,f);
    end
end


%% clear R DataRot VaultMovRot

hFig1 = figure(1);
set(gcf,'position',get(0,'ScreenSize'))
hr = plot(VaultFij(:,1),VaultFij(:,2),'bv'), title('Puntos Reales Ambas Bovedas');
hold on;
plot(VaultMovRot(:,1), VaultMovRot(:,2),'rv');
[Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,1);

name1 = '105_1';
name2 = '105_2';

Vault1 = load(strcat('Vaults\Vault',name1, '.txt'));
Vault2 = load(strcat('Vaults\Vault',name2, '.txt'));
Real_XY1 = load(strcat('Real_XYs\Real_XY', name1, '.txt'));  %%%% Vault T
Real_XY2 = load(strcat('Real_XYs\Real_XY', name2, '.txt'));  %%%% Vault Q
Chaff_Data1 = load(strcat('Chaff_Datas\Chaff_Data', name1, '.txt'));  %%%% Vault T
Chaff_Data2 = load(strcat('Chaff_Datas\Chaff_Data', name2,'.txt'));  %%%% Vault Q

plot(Real_XY1(:,1),Real_XY1(:,2),'kx'), title('9 Puntos Genuinos Identificados');
hold on;
plot(Real_XY2(:,1),Real_XY2(:,2),'rx');
plot(Chaff_Data1(:,1),Chaff_Data1(:,2),'ko');
plot(Chaff_Data2(:,1),Chaff_Data2(:,2),'ro');


% %-------------------- Show matching points only with the best rot ---------------------%
% R = [cos(3.1416*rots(maxmpidx(1))) -sin(3.1416*rots(maxmpidx(1))); sin(3.1416*rots(maxmpidx(1))) cos(3.1416*rots(maxmpidx(1)))];
% DataRot = R * VaultT;
% VaultMovRot = [DataRot(1,:)+ mean(VaultMov(1,:));DataRot(2,:)+ mean(VaultMov(2,:))];
% VaultMovRot = VaultMovRot';
% 
% hFig1 = figure(1);
% set(gcf,'position',get(0,'ScreenSize'))
% hr = plot(VaultFij(:,1),VaultFij(:,2),'bv'), title('Puntos Reales Ambas Bovedas');
% hold on;
% plot(VaultMovRot(:,1), VaultMovRot(:,2),'rv');
% [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,1);
% %------------------------------------------------------------------------%


% %-------------------- Rot example of the same vault ---------------------%
% R = [cos(3.1416*(2-0.008)) -sin(3.1416*(2-0.008)); sin(3.1416*(2-0.008)) cos(3.1416*(2-0.008))];
% DataRot = R * VaultT;
% hr = plot(VaultMov(1,:),VaultMov(2,:),'bv'), title('Puntos Reales Ambas Bovedas');
% hold on;
% plot(DataRot(1,:)+ mean(VaultMov(1,:)),DataRot(2,:)+ mean(VaultMov(2,:)),'rv');
% %------------------------------------------------------------------------%

% direction = [1 0];
% rotate(hr,direction,90);
% hold on;
% plot(hr.XData,hr.YData,'bo')
% plot(Vault2(Vault_indiceV2,1),Vault2(Vault_indiceV2,2),'ro');

% x = 1:10;
% y = randi(10,1,10)
% xt = x - mean(x);
% yt = y - mean(y);
% 
% data = [xt;yt];
% R = [cos(3.1416) -sin(3.1416); sin(3.1416) cos(3.1416)];
% DataRot = R * data;
% 
% figure;
% h = plot(x,y);
% hold on
% plot(DataRot(1,:) + mean(x),DataRot(2,:) + mean(y));
% camroll(45);



% for i = 1:10    
%     rotate(h,[0 0],20); % rotate h line, by [0 0] point, with 20 degrees
%     hold on;
%     plot(h.XData,h.YData, 'color','b')
% end