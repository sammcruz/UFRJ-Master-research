function [Depth_cor,Temp_cor]=FRE_CH14(depth,temp,year_cruz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CORRECAO DA PROFUNDIDADE PELO METODO DESCRITO POR CHENG ET AL (2014) >CH14<
% Criada por SAMANTHA CRUZ EM 21/03/2018
% NOAA: METODO CH14
%
%[Depth_cor,Temp_cor]=FRE_CH14(depth,temp,year_cruz)
%
%%%% INPUT %%%
%   depth (M,N) => Matriz com os dados de profundidade inferidos pela FRE 
%   do fabricante do XBT. 
%   M representa os pontos da radial e N representa a profundidade.
%   
%   temp (M,N) => Matriz com os dados de temperatura coletados pelo XBT. 
%   M representa os pontos da radial e N representa a profundidade.
%
%   year_cruz => ano em que o cruzeiro foi realizado.
%
%%%% OUTPUT %%%
%   Depth_cor (M,N) => Matriz com os dados de profundidade corrigidos com 
%   base em CH14. 
%   M representa os pontos da radial e N representa a profundidade.
%
%   Temp_cor (M,N) => Matriz com os dados de temperatura corrigidos com 
%   base em CH14. 
%   M representa os pontos da radial e N representa a profundidade.
%
%%%% STEPS %%%
%1-Recalculates the depth by using the following fall rate equation: 
%    Depth_cor=A*time-B*time^2-Offset. 
%    Where elapse time (time) for each reported depth by using the 
%    original drop-rate equation (Depth_original = A0*time-B0*time^2). 
%    For MOVAR profiles, (A0=6.472, B0=0.00216) should be applied before 
%    applying this depth bias correction, if necessary. 
%2-Corrects each temperature measurement (Temp_original) by using: 
%    Temp_cor = Temp_original - Tbias.
%3-The corrections are made for 9 different XBT groups according to probe 
%    types: Sippican-T4/T6, Sippican-T7/DB, Sippican-T10, Sippocan-T5, 
%    TSK-T7, TSK-T4/T6, TSK-T5, Unknown-Deep and Unknown-Shallow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Depth_cor=A*time-B*time^2-Offset
% Temp_cor = Temp_original - Tbias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Descobrindo o tempo ----------------------------------
%Depth_original = A0*time-B0*time^2). (A0=6.472, B0=0.00216)
%Fonte: Manual_AOML.pdf (pag 22 => (Sippican, 1994, MK12 Oceanographic Data Acquisition System, User's Manual
...306677-1: Sippican Ocean Systems, Inc., Marion, Massachusetts.))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


A0=6.472;
B0=0.00216;

for i=1:size(depth,1) %loop nos pontos da radial
    for j= 1:size(depth,2)% loop na profundidade
        if isnan(depth(i,j))==1
            time(i,j)=nan;
        else
        coef = [-B0 A0 -depth(i,j)];
        r = roots(coef);
        time(i,j)=r(2);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --------------------- CORRIGINDO A PROFUNDIDADE --------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Atribuindo valores a constantes
H95_A = 6.691;  %para T7/DB

%% Obtendo temperatura media dos 100 primeiros metros
Averaged_Temp_100m = nanmean(nanmean(temp(:,1:151),2)); % media das temperaturas até 100m

%% Obtendo CH14_A_temp
CH14_A_temp = Averaged_Temp_100m * 0.0025;

%% Obtendo o CH14_A_time com base na tabela 1 (https://data.nodc.noaa.gov/woa/WOD/XBT_BIAS/CH14_table1_update.txt)
fid = fopen('/media/samantha/OCEAN/Pesquisa/Rotinas/Pacotes/Samantha/CH14_table1_update.txt','r');
tline = fgetl(fid);
tlines = cell(0,1);
while ischar(tline)
    tlines{end+1,1} = tline;
    tline = fgetl(fid);
end
fclose(fid);
for k=2:size(tlines,1) %loop em cada linha do arquivo
    line=char(tlines(k));
    ano(k-1)=str2double(line(1:4));
    ind=strfind(line,'	');%definindo os espacos entre as colunas da tabela
    val(k-1)=str2double(line(5:ind(1))); %pegando a coluna do T7/DB
end
if year_cruz>ano(end)
    display(['tabela nao está atualizada para o ano de ' num2str(year_cruz(1))])
    year_cruz=ano(end);
end
CH14_A_time = val(ano==year_cruz); %VAlor para o T7/DB. Com base na tabela 1

%% Obtendo o valor de A
A = H95_A+CH14_A_time + CH14_A_temp;

%% Obtendo o valor de B
B=A*0.0070-0.0440;

%% Obtendo o valor de Offset
Offset=A* 6.3765-40.293;
%% OBTENDO A PROFUNDIDADE CORRIGIDA
Depth_cor=(A.*time)-(B.*(time.^2))-Offset;
if Depth_cor < 0
    Depth_cor = Nan;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --------------------- CORRIGINDO A TEMPERATURA ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Obtendo o Tbias (Tbias= Tbias_time + Tbias_temp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtendo o Tbias_time com base na tabela 2 (https://data.nodc.noaa.gov/woa/WOD/XBT_BIAS/CH14_table2_update.txt)
fid = fopen('/media/samantha/OCEAN/Pesquisa/Rotinas/Pacotes/Samantha/CH14_table2_update.txt','r');
tline = fgetl(fid);
tlines = cell(0,1);
while ischar(tline)
    tlines{end+1,1} = tline;
    tline = fgetl(fid);
end
fclose(fid);
for k=2:size(tlines,1) %loop em cada linha do arquivo
    line=char(tlines(k));
    ano(k-1)=str2double(line(1:4));
    ind=strfind(line,'	');%definindo os espacos entre as colunas da tabela
    val2(k-1)=str2double(line(5:ind(1))); %pegando a coluna do T7/DB
end

Tbias_time = val2(ano==year_cruz); %VAlor para o T7/DB. Com base na tabela 2

%% Obtendo o Tbias_temp
Tbias_temp =temp * 0.0014 + 0.0139;

%% Obtendo o Tbias
Tbias= Tbias_time + Tbias_temp; 

%% OBTENDO A TEMPERATURA CORRIGIDA

Temp_cor = temp - Tbias;
end
