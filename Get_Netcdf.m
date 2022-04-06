%% Get_Netcdf reads a NetCdf filename and returns a Struct with all
% the variables in it, it also returns the date in datetime format (but only if
% there's a time coordinate in the .nc file)
%
%   Syntax:
%      [Data]=Get_Netcdf(Filename)
%
%   INPUT:
%      Filename     = String with a name of a .nc file
%  
%   OUTPUT:
%      Data         = Struct with varibles of .nc file as fields
%
% Example:
% Data = Get_Netcdf("CGLO_uv_1993.nc")
% Returns:
% Data = 
%
%   struct with fields:
%
%         time: [365×1 double]
%    longitude: [65×1 single]
%     latitude: [25×1 single]
%        depth: [75×1 single]
%      vo_cglo: [65×25×75×365 single]
%      uo_cglo: [65×25×75×365 single]
%         date: [365×1 datetime]
%
% Created in 26-MAR-2020
% Author:  SAMANTHA CRUZ   
% email: samantha@poli.ufrj.br
%


function [Data]=Get_Netcdf(filename)

Data=struct;
ncid = netcdf.open(filename,'NC_NOWRITE'); % abre o arquivo
varids = netcdf.inqVarIDs(ncid); % pega as IDs das variaveis
for i=1:length(varids) % um loop pra cada variavel
    varname = netcdf.inqVar(ncid,varids(i)); % pergunta o nome da variável
    
    % String com resto da linha de comando necessária para pegar a variável
    resto='=netcdf.getVar(ncid,varids(i));'; 
    eval(strcat("Data.",varname,resto)); % executa o comando de pegar a variável
    
    try % Pega o nome da variável que determina a longitude
        attName=netcdf.getAtt(ncid,varids(i),"long_name");
    catch
        warning(strcat('Variable --> ',varname,' does not have the attribute long_name, trying standard_name'))
        try
            attName=netcdf.getAtt(ncid,varids(i),"standard_name");
        catch
            warning(strcat('Variable --> ',varname,' also does not have the attribute standard_name'))
            attName="nothing";
        end
    end
    
    if (attName=="Longitude" || attName=="longitude") 
        lonname=varname; % Pega o nome da variavel que indica a longitude
    end
    
    if (varname=="time") % Pega a unidade de tempo
        try
            timeUnit=strsplit(netcdf.getAtt(ncid,varids(i),"units"));
        catch
            warning('Variable time has no unit attribute, DEFAULT VALUE: seconds since 2000-01-01')
            len="seconds";
            start="2000-01-01";
        end
        if (exist('timeUnit','var'))
            len=char(timeUnit(1));
            start=char(timeUnit(3));
        end
    end
end

netcdf.close(ncid)
if (exist('lonname','var'))
    if (eval(strcat("max(Data.",lonname,"(end))>190")))
        eval(strcat("Data.",lonname,"=Data.",lonname,"-360;"))
    end
end
if length(start)>10
    if (start(11) == 'T')
        start(11) = ' ';
        start(end) = ' ';
    end
end


if (exist('len','var'))
    % Transforma o tempo no formato datetime
    if strcmp(len,"days")
        Data.date=datetime(Data.time*24*3600,'ConvertFrom', 'epochtime', 'Epoch', start);
    end
    if strcmp(len,"hours")
        Data.date=datetime(Data.time*3600,'ConvertFrom', 'epochtime', 'Epoch', start);
    end
    if strcmp(len,"minutes")
        Data.date=datetime(Data.time*60,'ConvertFrom', 'epochtime', 'Epoch', start);
    end
    if strcmp(len,"seconds")
        Data.date=datetime(Data.time,'ConvertFrom', 'epochtime', 'Epoch', start);
    end
end

end




