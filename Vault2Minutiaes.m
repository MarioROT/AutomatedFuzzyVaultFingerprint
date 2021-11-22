%  Devolver de Vault a Minucias
function  T_minucia=Vault2Minutiaes(Vault,NB_UVT)



X=Vault(:,1);  %%% Cancatenado con (u, v, th)

%%%%Recuperar valores originales de puntos (incluyendo Chaff points) %%%%%
%%%%%%%%%%%%%%%%%%%%% Minicia decoding 
bit1=NB_UVT(2)+NB_UVT(3);
bit2=NB_UVT(3);

Uq=fix(X/(2^bit1));
X2=X-Uq*(2^bit1);
Vq=fix(X2/2^bit2);
Thq=X2-Vq*(2^bit2);
T_minucia=[Uq,Vq,Thq];
