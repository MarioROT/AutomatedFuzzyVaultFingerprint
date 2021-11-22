%
%   template = generar_template(im, delta1, beta, display)
%
%   Dado una imagen de de huella, extrae tenplate
%
function [template_final, ridgeEnd_final, ridgeBif_final, normim] = generar_template(im,delta1,beta,n_points,display)

%template1 = extractminutae(im1,display)

[ridgeEnd,ridgeBifurcation] = extractminutae2(im,display);
N_end=size(ridgeEnd,1);
N_bif=size(ridgeBifurcation,1);
template = [ridgeEnd;ridgeBifurcation];
NT=size(template,1);

%%%%%% Evaluación de la calidad de minucias y eliminar minucias con mala
%%%%%% calidad %%%

[template_ok,N_end_ok]=Filtro_Calidad(im, template, N_end);

NT_ok=size(template_ok,1);
% Identify ridge-like regions and normalise image
blksze = 16; thresh = 0.1; margin=20;
[normim, mask] = ridgesegment(im, blksze, thresh, margin);

ridgeEnd_ok=template_ok(1:N_end_ok,:);
ridgeBif_ok=template_ok(N_end_ok+1:end,:);
if display == 1
show_minutia(normim, ridgeEnd_ok, ridgeBif_ok, 'Minutiae Good Quality');
end
%%%%%%%% Obtener distancia %%%%%%%
%%%%%% Filtrar huellas por distancias %%%%%

[template_final,N_end_final]=Filtro_distancia(template_ok, delta1, beta, N_end_ok);


ridgeEnd_final=template_final(1:N_end_final,:);
ridgeBif_final=template_final(N_end_final+1:end,:);


if display == 1
show_minutia(normim, ridgeEnd_final, ridgeBif_final, 'Minutiae Final');  
end

% El parámetro n_points es para ajustar a un número N de minucias que se
% necesite obtener y actuaran como los puintos genuinos. Sin embargo, con 
% ese parametro activo se desprecián las métricas de calidad de minucias. 
% Dependiendo de la calidad de la imagen de la huella, pero recomendable 
% que si se usa, este parámetro sea mayor a 10,15 y menor a 30, pero depende 
% de las imagenes con las que se use.
% Si no se quiere ajustar a ningun número N de minucias se debe poner ese 
% parametro como 0 (cero) y el número de minucias que se obtendra será las 
% que se identifiquen con la suficiente calidad.

if n_points ~= 0
   New_N_End = n_points - N_bif;
   if New_N_End > N_end
       disp(['El número de minucias no se ha podido ajustar a: ', num2str(n_points)])
       ridgeEnd_final=ridgeEnd(1:end,:);
       ridgeBif_final=ridgeBifurcation(1:end,:);
       template_final = [ridgeEnd_final;ridgeBif_final];
   else
       if N_bif > floor(n_points/2)
           if mod(n_points,2) == 0
               ridgeEnd_final=ridgeEnd(1:floor(n_points/2),:);
               ridgeBif_final=ridgeBifurcation(1:floor(n_points/2),:);
               template_final = [ridgeEnd_final;ridgeBif_final];
           else
               ridgeEnd_final=ridgeEnd(1:floor(n_points/2),:);
               ridgeBif_final=ridgeBifurcation(1:floor(n_points/2)+1,:);
               template_final = [ridgeEnd_final;ridgeBif_final];
           end
           if display == 1
               disp(['El número de minucias obtenidas ajustado a: ', num2str(n_points)])
               show_minutia(normim, ridgeEnd_final, ridgeBif_final, 'n_points Minutiaes Selected');  
           end
       else
           ridgeEnd_final=ridgeEnd(1:New_N_End,:);
           ridgeBif_final=ridgeBifurcation(1:end,:);
           template_final = [ridgeEnd_final;ridgeBif_final];
           if display == 1
               disp(['El número de minucias obtenidas ajustado a: ', num2str(n_points)])
               show_minutia(normim, ridgeEnd_final, ridgeBif_final, 'n_points Minutiaes Selected');  
           end
       end
   end
end

end
