% Distancia entre proyecciones en GF(2^16)
function [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(V1,V2, delta2,display)

LV1=size(V2,1);  %% El número de puntos en Vault2
LV2=size(V1,1);  %% El número de puntos en Vault1

k=1;
for i=1:LV2
    flag=0;
    for j=1:LV1
        if dist_qt(V1(i,:),V2(j,:))<delta2
            flag=1;
            break;
        end
    end
    
    if flag==1
        Real_PointsV1(k,:)=V1(i,:);
        Vault_indiceV1(k,:)=i;
        Real_PointsV2(k,:)=V2(j,:);
        Vault_indiceV2(k,:)=j;
        k=k+1;
    end
end

if k == 1;

    Real_PointsV1=[];
    Vault_indiceV1=[];
    Real_PointsV2=[];
    Vault_indiceV2=[];
end

if display == 1
    if isempty(Real_PointsV1)
        plot(Real_PointsV1,Real_PointsV1),title('No hay puntos coincidentes que mostrar')
    else
    hold on;
    plot(Real_PointsV1(:,1),Real_PointsV1(:,2),'gv'), title('Puntos Coincidentes Ambas Bovedas');
    hold on;
    plot(Real_PointsV2(:,1),Real_PointsV2(:,2),'mv');
    set(gcf,'position',get(0,'ScreenSize'))
    end
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function distancia=dist_qt(Te,Qe)
   D1=dist_ec(Te(1:2),Qe(1:2));
   distancia=D1;
end