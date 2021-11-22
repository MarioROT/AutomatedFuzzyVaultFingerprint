% distancia entre minucia de consulta y minucia de template separado por
% Ends y Bifs
function [Vault_indice_Ends,Querry_indice_Ends,Vault_indice_Bifs,Querry_indice_Bifs,Real_Ends,Querry_Ends,Real_Bifs,Querry_Bifs]=distancia_QTEB(ImDir1,ImDir2,delta2,beta,display)

if nargin<5
  display = 0;
end
% TEnds
% TBifs
% QEnds
% QBifs

[minucia_consulta, TEnds, TBifs, normim] = obtener_minucia_consulta(imread(ImDir1),0.1,0.1,0);
[minucia_consulta2, QEnds, QBifs, normim2] = obtener_minucia_consulta(imread(ImDir2),0.1,0.1,0);


LQE=size(QEnds,1);  %% El número de terminaciones de huella de consulta
LQB=size(QBifs,1);  %% El número de bifurcaciones de huella de consulta
LTE=size(TEnds,1);  %% El número de terminaciones de huella de template
LTB=size(TBifs,1);  %% El número de bifurcaciones de huella de template

ke=1;
for i=1:LTE
    flag=0;
    for j=1:LQE
        if dist_qt(TEnds(i,:),QEnds(j,:),beta)<delta2
            flag=1;
            break;
        end
    end
    
    if flag==1
        Real_Ends(ke,:)=TEnds(i,:);
        Querry_Ends(ke,:)=QEnds(j,:);
        Vault_indice_Ends(ke,:)=i;
        Querry_indice_Ends(ke,:)=j;
        ke=ke+1;
    end
    
end

kb=1;
for m=1:LTB
    flag=0;
    for n=1:LQB
        if dist_qt(TBifs(m,:),QBifs(n,:),beta)<delta2
            flag=1;
            break;
        end
    end
    
    if flag==1
        Real_Bifs(kb,:)=TBifs(m,:);
        Querry_Bifs(kb,:)=QBifs(n,:);
        Vault_indice_Bifs(kb,:)=m;
        Querry_indice_Bifs(kb,:)=n;
        kb=kb+1;
    end
    
end

if display == 1;
    show_minutia(normim, Real_Ends, Real_Bifs, 'Minutiae Real Compared'); 
    show_minutia(normim2, Querry_Ends, Querry_Bifs, 'Minutiae Querry Compared'); 
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function distancia=dist_qt(Te,Qe,beta)

   D1=dist_ec(Te(1:2),Qe(1:2));
   D2=abs(Te(3)-Qe(3))*beta;
   distancia=D1+D2;
end
