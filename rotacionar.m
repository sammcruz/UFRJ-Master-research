%% Rotaciona um par de vetores em certo angulo de acordo com a lat lon enviada
%  
% [uout,vout] = rotacionar(u,v,lat,lon,depth,time)
% INPUT:
%      u        = eastward sea water velocity [m s-1] - size MxDxT
% Dimensions: longitude/latitude,depth,time
%      v        = northward sea water velocity [m s-1] - size MxDxT
% Dimensions: longitude/latitude,depth,time
%      lat  = vector sided 1xM at which the data u and v is given.
%      lon  = vector sided 1xM at which the data u and v is given.
%      depth    = vector sided 1xD at which the data u and v is given.
%      time     = vector sided 1xT at which the data u and v is given.
%  
%   OUTPUT:
%      uout     = eastward sea water velocity [m s-1] - size LxDxT
%      vout     = northward sea water velocity [m s-1] - size LxDxT

% Samantha Cruz - 02/11/2019
% 
% end

function [uout,vout] = rotacionar(u,v,lat,lon,depth,time)

    % Adicionando lat lon da Radial
    lat1=[lat(end),lat(1)];
    lon1=[lon(end),lon(1)];

    % Adicionando o angulo da rotaçao
    [~,a]=sw_dist(lat1,lon1);
    ang=a+180;
    rad=deg2rad(ang); % transforma em radiano

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rotacionando a radial!
    %

    u1=zeros(length(lat),length(depth),length(time)); %alocando espaço nas variaveis
    v1=zeros(length(lat),length(depth),length(time));

    for i=1:length(time) %loop no tempo
        for j=1:length(depth) %loop na profundidade

            tempu=squeeze(u(:,j,i)); %criando uma variavel temporária 2d
            tempv=squeeze(v(:,j,i));

            [tempu,tempv]=rot2D(tempu,tempv,-rad); %rotacionando na função

            u1(:,j,i)=tempu; %acumulando nas novas variaveis
            v1(:,j,i)=tempv;

        end
    end

    %substituindo os nomes
    uout=u1;
    vout=v1;
end
