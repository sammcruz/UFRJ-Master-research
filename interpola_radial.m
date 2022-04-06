%% Função que interpola um par de dados 4D para a radial especificada
% [u,v]=interpola_radial(u,v,lat_old,lon_old,lat_new,lon_new,depth,time)
% INPUT:
%      u        = eastward sea water velocity [m s-1] - size NxMxDxT
% Dimensions: longitude,latitude,depth,time
%      v        = northward sea water velocity [m s-1] - size NxMxDxT
% Dimensions: longitude,latitude,depth,time
%      lat_old  = vector sided 1xM at which the data u and v is given.
%      lon_old  = vector sided 1xN at which the data u and v is given.
%      lat_new  = 1xL vector at which the output data is given
%      lon_new  = 1xL vector at which the output data is given
%      depth    = vector sided 1xD at which the data u and v is given.
%      time     = vector sided 1xT at which the data u and v is given.
%  
%   OUTPUT:
%      uout     = eastward sea water velocity [m s-1] - size LxDxT
%      vout     = northward sea water velocity [m s-1] - size LxDxT

% Exemplo de uso
% for i=1:length(names)
%     tic
%     filename=names(kk).name
%     load /home/samantha/NOTE-MOVAR/MODELOS/Rotinas/gradeMovar2 % carrega os pontos do movar
%     load (strcat('/home/samantha/NOTE-MOVAR/MODELOS/ECCO/arquivos/',filename)) % carrega os dados do modelo
%     [u,v]=interpola_radial(u,v,lat_old,lon_old,lat_new,lon_new,depth,time)
% end

function [uout,vout] = interpola_radial(u,v,lat_old,lon_old,lat_new,lon_new,depth,time)

    for i=1:length(time)
        for j=1:length(depth)

            tempu=squeeze(u(:,:,j,i));
            tempv=squeeze(v(:,:,j,i));

            u2(:,:,j,i) = interp2(lon_old,lat_old,tempu',lon_new,lat_new);
            v2(:,:,j,i) = interp2(lon_old,lat_old,tempv',lon_new,lat_new);

        end
    end

    uout=squeeze(u2);
    vout=squeeze(v2);

return