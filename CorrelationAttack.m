%% Este script contiene el código para llevar a cabo el ataque de 
% emparejamiento cruzado y correlación, con base en el articulo
% "Realization of correlation attack against fuzzy vault Scheme - Kholmatov, A."

%% En esta primera parte se obtienen transformaciónes para que al emparezar las bóvedas
% obtengamos los mas puntos coincidentes. 

clear all; close all; clc; % limpiamos el intorno de trabajo

% En este punto ya se debiero haver extraido 2 bovedas que se asume 
% que pertenecen a datos biometricos de la misma persona pero que 
% estaban en diferentes sistemas y protegiendo diferentes polinomios

VaultFij = load('Vaults\Vault105_1.txt');  %%%% Vault Extraída de Sistema 1
VaultMov = load('Vaults\Vault105_2.txt');  %%%% Vault Extraída de Sistema 2

% VaultFij, es una boveda que siempre permanecera fija 
% VaultMov, es la otra boveda que se rotara y se haran traslaciones a fin de
% conseguir emparejar mas puntos posibles con VaultFij, al menos n+1, siendo
% n el grado del polinomio.  


min_dist = 2000;%1800;%2000;%2250; % distancia minima para identificar puntos coincidentes

% Movemos el origen del campo de existencia de los puntos a su centro para
% a partir de ahí rotar la bóveda y luego regresarla para comparar los puntos 
VaultMov = VaultMov'; 
VaultXt = VaultMov(1,:) - mean(VaultMov(1,:));
VaultYt = VaultMov(2,:) - mean(VaultMov(2,:));
VaultT = [VaultXt;VaultYt];

rotattempts = 1000; % Se define el número de rotaciones. 
rots = linspace(0,2,rotattempts); % creamos intervalos para rotar  tomando 
% en cuenta el circulo unitario, ya que despues de multiplicará por π (pi),
% por lo que tomando encuenta que al múltiplicar π x 1 esta a 180 grados
% es decir "de cabeza" la gráfica, y en 2 x π vuelve a su posición original
% 0 grados.

transattempts = 20000; % número de translaciones que se harán. 

for i = 1:rotattempts % Se ejecutan las rotaciones
    
    % Se calcula el grado de rotación  respectp al circulo de unitario
    R = [cos(3.1416*rots(i)) -sin(3.1416*rots(i)); sin(3.1416*rots(i)) cos(3.1416*rots(i))]; 
    DataRot = R * VaultT; % Se rota la bóveda
    % Se debe regresar la bóveda al punto de origen original
    VaultMovRot = [DataRot(1,:)+ mean(VaultMov(1,:));DataRot(2,:)+ mean(VaultMov(2,:))]; 
    VaultMovRot = VaultMovRot'; 
    
    % Se comparan la boveda fija y la rotada en la rotación i
    %-Las vaults comparadas deben entrar en forma n x 2, siendo n el numero puntos en el vault-#
    [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,0);
    
    %--- Las dos lineas de abajo solo se activan para pocas iteraciones e.g. 10 y activar display arriba 
%     inp = input('Presiona enter para continuar')
%     close all
    
    % Se guarda para cada i rotación el numero de puntos coincidentes entre bóvedas
    MatchPoints(i) = length(Vault_indiceV1);
end


maxmp = max(MatchPoints); % se saca el número mayor de puntos coincidentes entre todas las rotaciones
maxmpidx = find(MatchPoints==maxmp); % Se saca que rotaciones obtuvieron el maxmp 


% mk2 = 0;
% for f =1:length(maxmpidx)
%     R = [cos(3.1416*rots(maxmpidx(f))) -sin(3.1416*rots(maxmpidx(f))); sin(3.1416*rots(maxmpidx(f))) cos(3.1416*rots(maxmpidx(f)))];
%     DataRot = R * VaultT;
%     VaultMovRot = [DataRot(1,:)+ mean(VaultMov(1,:));DataRot(2,:)+ mean(VaultMov(2,:))];
%     VaultMovRot = VaultMovRot';
%     
%     [Vault_indiceV1BT4R,Real_PointsV1BT4R,Vault_indiceV2BT4R,Real_PointsV2BT4R]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,0);
%     if length(Vault_indiceV1BT4R)> mk2
%        mk2 = length(Vault_indiceV1BT4R);
%        VaultMovRotf = VaultMovRot; % Se establece entonces la mejor VaultMov con transformaciones obtenida
%     end
% end
% VaultMovRot = VaultMovRotf;

% Con las rotaciones que tuvieron el maxmp, se haran traslaciones
% intentando obtener mas coincidencias
for j = 1:length(maxmpidx)
    
    % Se rota la bóveda al j un grado  dentro de  maxmpidx
    R = [cos(3.1416*rots(maxmpidx(j))) -sin(3.1416*rots(maxmpidx(j))); sin(3.1416*rots(maxmpidx(j))) cos(3.1416*rots(maxmpidx(j)))];
    DataRot = R * VaultT;
    VaultMovRot = [DataRot(1,:)+ mean(VaultMov(1,:));DataRot(2,:)+ mean(VaultMov(2,:))];
    VaultMovRot = VaultMovRot';
    
    % Se harán para cada rotación transattempts intentos de translación
    % para buscar el mayor numero de puntos coincidentes
    for k = 1:transattempts
        
        % se calculan los puntos coincidentes iniciales cada que entra al
        % for ya que si mejoran en cierta interación se guardan en la
        % vóbeda que entra aqui, ya con la translación de mejora hecha. Si
        % no mejora, se mantiene igual. 
        [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,0);
        
        % Se trnaladan los funtos de VaultMov ya rotada en las 8
        % direcciones posibles para los pixeles. 
        dir1 = [VaultMovRot(:,1)+500,VaultMovRot(:,2)]; % Derecha
        dir2 = [VaultMovRot(:,1)-500,VaultMovRot(:,2)]; % Izquierda
        dir3 = [VaultMovRot(:,1),VaultMovRot(:,2)+500]; % Arriba
        dir4 = [VaultMovRot(:,1),VaultMovRot(:,2)-500]; % Abajo
        dir5 = [VaultMovRot(:,1)+500,VaultMovRot(:,2)+500]; % Arriba - Derecha
        dir6 = [VaultMovRot(:,1)+500,VaultMovRot(:,2)-500]; % Abajo - Derecha
        dir7 = [VaultMovRot(:,1)-500,VaultMovRot(:,2)+500]; % Arriba - Izquierda
        dir8 = [VaultMovRot(:,1)-500,VaultMovRot(:,2)-500]; % Abajo - Izquierda
        dirs = cat(3,dir1,dir2,dir3,dir4,dir5,dir6,dir7,dir8); % Se guardan las translaciones hechas
        [s1,s2,s3] = size(dirs);
        
        % Ahora se calculará la distacia para cada translación y se
        % obtendra la mejor, si es que hay. La que de mejores numeros de
        % coincidencias
        mk = 0; 
        
        for h = 1:length(s3)
            [Vault_indiceV1T,Real_PointsV1T,Vault_indiceV2T,Real_PointsV2T]=distancia_VaultsCA(VaultFij,dirs(:,:,h), min_dist,0);
            % Se verifica si para la h traslación para la k rotación da mas
            % puntos coincidentes y si si, se establece como la marca a
            % superar y se guarda la bóveda en esas condiciones. 
            if length(Vault_indiceV1T) > mk 
               mk =  length(Vault_indiceV1T);
               best_trans = dirs(:,:,h);
            else
                best_trans = [];
            end
        end
        
        if isempty(best_trans)
            continue
        else  % se ccheca si si mejoro la coincidencia con alguna rotación
            [Vault_indiceV1BT,Real_PointsV1BT,Vault_indiceV2BT,Real_PointsV2BT]=distancia_VaultsCA(VaultFij,best_trans, min_dist,0);
            % se verifica que realmente sea mejor a la del inicio del for para la k rotación. 
            if length(Vault_indiceV1BT) > length(Vault_indiceV1)
                % Si si, se guarda como la bóveda original para continuar con el for y ver si se puede mejorar aun mas
                VaultMovRot = best_trans; 
            end
        end
    end
    b_trans4rot(:,:, j) = VaultMovRot; % Se guarda cada rotación de las mejores con translaciones hasta que mas coincidencias diera
end

% Ahora de las rotaciones con tranlaciones hasta el mejor punto, se toma
% solo la que mas puntos coincidentes tenga de entre estas.
[sb1,sb2,sb3] = size(b_trans4rot);
mk2 = 0;
for f =1:sb3
    [Vault_indiceV1BT4R,Real_PointsV1BT4R,Vault_indiceV2BT4R,Real_PointsV2BT4R]=distancia_VaultsCA(VaultFij,b_trans4rot(:,:,f), min_dist,0);
    if length(Vault_indiceV1BT4R)> mk2
       mk2 = length(Vault_indiceV1BT4R);
       VaultMovRot = b_trans4rot(:,:,f); % Se establece entonces la mejor VaultMov con transformaciones obtenida
    end
end

%% En esta parte se correlacionan las bóvedas  y con las combinaciones de
% n+1 que se pueden obtener de los puntos coincidentes obtenidos se
% procesan para mediante la interpolación de lagrange intentar recuperar el
% polinomio que relaciona los puntos, y por ende la clave secreta. 

[Vault_indiceV1F,Real_PointsV1F,Vault_indiceV2F,Real_PointsV2F]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,0);

NB_UVT=[6,6,4];
N_Digree = 8;
q=2^16+1;
pol=[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1];
L_V1F = length(Vault_indiceV1F);

Vault4Dec = Vault2Minutiaes(Real_PointsV1F,NB_UVT);

if L_V1F < N_Digree+1  %%% Numero de datos reales de minucia no alcanzo para resolver Lagrange
        disp ('########  Falla de Autenticación ########');
    else
        
        Real_Data= Real_PointsV1F; %VaultFij(Vault_indiceV1F,:);
    
    %%% Generar posible combinación de N_Digree+1 datos de Real_Data %%%%%%
    
        Comb=Generar_Comb(L_V1F,N_Digree+1);
        flag_key=0; % flag_key=0: no se pudo recuparar llave
                    % flag_key=1: Se recurero correctamente la llave
    
        for i=1720729:size(Comb,1)%577439:size(Comb,1)%564147:size(Comb,1)%536132:size(Comb,1)%533311:size(Comb,1)%461348:size(Comb,1)%448049:size(Comb,1)%448048:size(Comb,1)%394885:size(Comb,1)%387046:size(Comb,1)%329450:size(Comb,1)%268228:size(Comb,1)%255017:size(Comb,1)%165989:size(Comb,1)%114570:size(Comb,1)% 83611:size(Comb,1)%59481:size(Comb,1)%52869:size(Comb,1)%15898:size(Comb,1)%:size(Comb,1)%3006755:size(Comb,1)%2950872:size(Comb,1)% 2946826:size(Comb,1)%2868010:size(Comb,1)%2644868:size(Comb,1)% 2582493:size(Comb,1)%2514753:size(Comb,1)%2400375:size(Comb,1)%2384344:size(Comb,1)%2172876:size(Comb,1)%1962839:size(Comb,1)%1876837:size(Comb,1)%  1791629:size(Comb,1)% 1775382:size(Comb,1)%1740357:size(Comb,1)%1721701:size(Comb,1)%1720987:size(Comb,1)%1720791:size(Comb,1)%1720756:size(Comb,1)%1720731:size(Comb,1)%1720724:size(Comb,1)%1720723:size(Comb,1)%1630253:size(Comb,1)%1618517:size(Comb,1)%1581245:size(Comb,1)%1486816:size(Comb,1)% 1440414:size(Comb,1)%1332614:size(Comb,1)%1291544:size(Comb,1)% 1280921:size(Comb,1)%1225321:size(Comb,1)% 1125344:size(Comb,1)%972646:size(Comb,1)%806198:size(Comb,1)%584393:size(Comb,1)%577439:size(Comb,1)% 564147:size(Comb,1)%536132:size(Comb,1)% 533311:size(Comb,1)% 461348:size(Comb,1)%448048:size(Comb,1)% 394885:size(Comb,1)%387046:size(Comb,1) %329450:size(Comb,1) %268228:size(Comb,1) %255017:size(Comb,1)%165989:size(Comb,1) %114570:size(Comb,1)% 83611:size(Comb,1) %59481:size(Comb,1) %52869:size(Comb,1)%15898:size(Comb,1)%1:size(Comb,1)
            if mod(i,1000) == 0
                fprintf('\n Iteración: %d  ', i)
            end
%             fprintf('\n Iteración: %d  ', i)
            Ind=Comb(i,:);
            Seleccionados=Real_Data(Ind,:);
            X_select=Seleccionados(:,1);
            Y_select=Seleccionados(:,2);
            %%%% Obtener coeficientes de polinomio usando X_select y
            %%%% Y_select
            S=Lagrange_Poly_iter(Y_select,X_select,N_Digree+1,q,N_Digree+1);
            %%%% Aplicar CRC para revisar si hay errores o no %%%%%%%
%             if i == 210 %|| i == 2634 || i == 9442 || i == 10424 || i == 12592 || i == 22214
%                 continue
%             else
%                 Posible_llave=Generar_llave(S);
%             end
            
            Posible_llave=Generar_llave(S);
            % Si encuentra error, la seleccion de X y Y son erroneo
             [~,error]=CRC_res(Posible_llave,pol);
            
            if sum(error) == 0
                Key_con_redundancia = Posible_llave;  %%% Llave recuparada %%%
                Key_recuperada=Key_con_redundancia(1:end-16);
                flag_key=1;
                fprintf('\n Posible llave recuperada en iteración: %d  ', i)
                break;
            end
            
        end
        
        if flag_key==0
            disp('%%% hay que repetir la captura de huella %%%');
        else
            figure;
            plot(X_select, Y_select,'r*');
            title('  9 minucias coincididos entre template y consulta');
            fprintf('\n Llave recuperada es: \n');
            fprintf('%3d',Key_recuperada);
            fprintf('\n');
            %%%%% Averiguar si la llave recuparada es la llave de usuario
            %%%%% que uso en codificación (Vault_Encoding)
%             load('Key_Usuario.mat');
            Key = logical(load(strcat('Keys/',VaultFijName,'-Key_Usuario.txt')));
            error_de_llave=sum(xor(Key,Key_recuperada));
            if error_de_llave==0
                fprintf('----- La llave recupero correctamente ---\n');
            end
        end
end

%% Esta ultima sección solo es de visualizaciones de 2 bóvedas, 
% Los triangulos azules(verdes) son puntos de VaultFij (La bóveda fija sin cambios)
% Los triangulos rojos(rosas)  pertenecen a VaultMovRot, la boveda movil con transformaciones para obtener las mas coincidencias posibles
% Las X negras pernecen a los puntos genuinos de VaultFij
% Las X rojas pertenecen a los puntos genuinos de VaultMov,en su posición original
% Los Circulos negros identifican a los puntos de ruido de VaultFij
% Los Circulos rojos identifican a los puntos de ruido de VaultMov, en su posición original 
% clear R DataRot VaultMovRot

% hFig1 = figure(1);
% set(gcf,'position',get(0,'ScreenSize'))
% hr = plot(VaultFij(:,1),VaultFij(:,2),'bv'), title('Puntos Reales Ambas Bovedas');
% hold on;
% plot(VaultMovRot(:,1), VaultMovRot(:,2),'rv');
% %Aquí se ponen triangulos verdes sobre los azules genuinos que lograron ser identificados
% %Por lo tanto los puntos de triangulo verde con una cruz 'X' negra encima
% %son los puntos reales (genuinos) de VaultFij, que se lograron obtener con
% %las rotaciones y tranlaciones
% [Vault_indiceV1,Real_PointsV1,Vault_indiceV2,Real_PointsV2]=distancia_VaultsCA(VaultFij,VaultMovRot, min_dist,1);
% 
% name1 = '105_1';
% name2 = '105_2';
% 
% Vault1 = load(strcat('Vaults\Vault',name1, '.txt'));
% Vault2 = load(strcat('Vaults\Vault',name2, '.txt'));
% Real_XY1 = load(strcat('Real_XYs\Real_XY', name1, '.txt'));  %%%% Vault T
% Real_XY2 = load(strcat('Real_XYs\Real_XY', name2, '.txt'));  %%%% Vault Q
% Chaff_Data1 = load(strcat('Chaff_Datas\Chaff_Data', name1, '.txt'));  %%%% Vault T
% Chaff_Data2 = load(strcat('Chaff_Datas\Chaff_Data', name2,'.txt'));  %%%% Vault Q
% 
% plot(Real_XY1(:,1),Real_XY1(:,2),'kx'), title('9 Puntos Genuinos Identificados');
% hold on;
% plot(Real_XY2(:,1),Real_XY2(:,2),'rx');
% plot(Chaff_Data1(:,1),Chaff_Data1(:,2),'ko');
% plot(Chaff_Data2(:,1),Chaff_Data2(:,2),'ro');


