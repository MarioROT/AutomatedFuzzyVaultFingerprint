%
%
function llave=Generar_llave(S)

L=length(S);
llave=zeros(1,16*L);
ini=1;
for i=L:-1:1
%     fprintf('Iteración interna: %d  ', i)
%     srng = ini:ini+15;
%     size(srng)
    if S(i) >= 65536
       S(i) = S(i)-1;
    end
%     comp = S(i)
%     srng2 = dec2bin(S(i),16);
%     size(srng2)
    llave(ini:ini+15)=double(dec2bin(S(i),16))-48;
    ini=ini+16;
end

end

    