%
%   Vault Encoding 
%
%     Corresponde Fig. 4 del artículo
%       "Fingerprint-based Fuzzy Vault: Implementation and Performance
%
clear;
close all;
clc;

Imgs= dir(strcat(pwd,'\DB1_B\*.tif'));
count = 0;
for hu=1:length(Imgs)


% clear;
% close all;
% clc;

im_name = string(Imgs(hu).name(1:5))
% im_name = '101_5'

%%%%%
ruta_completo=pwd;
%%drive=ruta_completo(1:3);
%%%%%%%% Parametros %%%%%

delta1=25;  %distancia mínima que pueden tener dos minucias
beta=0.2*pi/180;  % ec. (1) radian 0.2 grado --> 0.2*pi/180 radian
FTC=10; % número mínimo de minucias requerido después de filtros
NChaff=50; %%%%%% Número de puntos falsos
%%%%%%%%% Número de bits de cuantificación 
NB_UVT=[6,6,4];   %%% Alto  0 -- 63
semilla = 1; %% semilla parta generar llave%%%%%%
semilla_perm=2; %% semilla para permutación de de datos de Vault -- mezclar datos real y chaffpoints
n_degree = 8; % El orden de polynomio P(x) %%%%%% Polinomio %%%%%%
pol=[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1]; %% Polinomio que usa CRC
display = 0;
n_minu = 23;
% im_name = '105_1'
im = imread(strcat(ruta_completo,'\DB1_B\', im_name,'.tif'));
%im = imread('F:\Biometricas_Watermarking\DB1_B\106_7.tif');
%im = imread('F:\Biometricas_Watermarking\DB1_B\110_1.tif');
%im = imread('H:\Biometricas_Watermarking\DB1_B\105_7.tif');
%im = imread('H:\Biometricas_Watermarking\DB1_B\103_7.tif');
%im = imread('H:\Biometricas_Watermarking\DB1_B\109_6.tif');

[S1,S2]=size(im); %%%% El tamaño de la imagen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Generación de template %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1. Extracción de minucias
% 2. Eliminar minucias de mala calidad 
% 3. Eliminar minucias muy cercanas a otras minucias

[template, ridgeEnd, ridgeBif, normim] = generar_template(im, delta1, beta, n_minu, display);

% El cuarto parametro de la funcion anterior -- generar_template -- es para
% ajustar a un número N de minucias que necesites obtener y actuaran como 
% los puintos genuinos. Sin embargo, con ese parametro se desprecián las 
% métricas de calidad de minucias. Dependiendo de la calidad de la imagen
% de la huella, pero recomendable que si se usa, este parámetro sea mayor a
% 10,15 y menor a 30, pero depende de las imagenes con las que se use.
% Si no se quiere ajustar a ningun número N de minucias se debe poner ese 
% parametro como 0 (cero) y el número de minucias que se obtendra será las 
% que se identifiquen con la suficiente calidad.

% STemp = ['Dimensiones de template: ', size(template)];
% disp(STemp)

NT_final=size(template,1);

fprintf(' El número de minucias válido es %d \n',NT_final);

if NT_final>FTC  
    
Chaff_points=generate_chaff_points(im, template, delta1, NChaff, beta);
% show_minutia_all(normim, ridgeEnd, ridgeBif, Chaff_points, 'Minutiae and Chaff');      

else
    disp(' %%%% hay que repetir la captura de huella'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Cuantificación  de template y Chaff point %%%%%%%%%%%%%%%%%%
 
     Q_template=Quant(template,NB_UVT,[S1,S2,pi]);
     Q_Chaff=Quant(Chaff_points,NB_UVT,[S1,S2,pi]);
     
     fprintf('Dimensiones de Q_template: [%d,%d] \n', size(Q_template))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Concatenación de tres valores posición (x,y) de minucia y angulo %%%%%%
     Temp=concatenate(Q_template,NB_UVT);
     Chaf=concatenate(Q_Chaff,NB_UVT);
     
     fprintf('Dimensiones de Temp: [%d,%d] \n', size(Temp))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%        CRC coding       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Generar lleve nueva con capacidad de detección de error 

L=n_degree*16;
rng(semilla);  %%%%%%% seed =llave --- llave de la persona 
A=rand(1,L);
fprintf('Dimensiones de A: [%d,%d] \n', size(A))

Key=A>0.5;  %%%% llave de usuariio original 
fprintf('Dimensiones de Key: [%d,%d] \n', size(Key))
% disp(Key)
[New_Key,~] = CRC_res(Key,pol); 
fprintf('Dimensiones de New_Key: [%d,%d] \n', size(New_Key))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%      Generar polinomio %%%%%%%%%%%
V=zeros(n_degree+1,16);
Coef=zeros(1,n_degree+1);
q=15:-1:0;
for k=1:n_degree+1
    V(k,:)=New_Key((k-1)*16+1:k*16);
    Coef(k)=sum(V(k,:).*(2.^q));
end

fprintf('Dimensiones de Coef: [%d,%d] \n', size(Coef))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% %%%%%%%%%%%%% Evaluar polinomio  en GF(2^16)%%%%%%%%%%%%%%%%%%%%%%
   
 Real_XY=Eval_poly(Coef,Temp);

fprintf('Dimensiones de Real_XY: [%d,%d] \n', size(Real_XY))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%% Generar Chaff pointos aleatoriamente         %%%%%%%%
%%%%%%%  Pero cuidando que no se coincide con la proyección de polinomio %%  
    
 Z=randi(2^16,NChaff, 1); 
 Chaff_Data =[Chaf',Z];
 fprintf('Dimensiones de Chaff_Data: [%d,%d] \n', size(Chaff_Data))
 
 NG=Check_Chaff_Data(Chaff_Data, Coef);
 if sum(NG)~=0
     pos=find(NG~=0);
     Chaff_Data=remove_NG(Chaff_Data,pos);
 end
 
% figure;
% plot(Real_XY(:,1), Real_XY(:,2),'r*');
% hold on
% plot(Chaff_Data(:,1),Chaff_Data(:,2),'co');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%      Construcción de Vault                %%%%%%%%%%%%

All_Data=[Real_XY;Chaff_Data];   %%%% Real data + Chaff data
save(strcat('ExpOctubre\Real_XYs\','Real_XY',im_name,'.txt'),'Real_XY', '-ascii');
save(strcat('ExpOctubre\Chaff_Datas\','Chaff_Data',im_name,'.txt'),'Chaff_Data', '-ascii');
rng(semilla_perm);
Pind=randperm(size(All_Data,1)); %%%% mezcular todos los datos
Vault = All_Data(Pind,:);                %%% Aplicar permutación
fprintf('Dimensiones de Vault: [%d,%d] \n', size(Vault))
% figure;
% plot(Vault(:,1),Vault(:,2),'v');

save(strcat('ExpOctubre\Vaults\','Vault',im_name,'.txt'),'Vault', '-ascii'); %%%% Fuzzy Vault V=(A,B), A: valores de X de polynomio
                                %%%%                      B: resultado de
                                %%%%                      polinomio B=f(A)
                                %%%%   
% save(strcat('Keys\',im_name,'-Key_Usuario.txt'),'Key', '-ascii');
csvwrite(strcat('ExpOctubre\Keys\',im_name,'-Key_Usuario.txt'),Key)

if length(Real_XY) ~= n_minu
    count = count + 1;
end
end
fprintf('El número de casos de cantidad de minucias no ajustada es: %d', count)
