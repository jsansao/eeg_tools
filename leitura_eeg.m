function [saida] = leitura_eeg(filename)
% leitura_edf  rotina para leitura de arquivo no formato egg
%      uso: [saida] = leitura_edf(filename) 
%
%      sendo saida uma struct que contém:
%
%         saida.id: identificação paciente
%         saida.recordid: identificação médico
%         saida.startdate: data da medição
%         saida.starttime: hora de início da medição
%         saida.reserved: equipamento 
%         saida.duration: duração em segundos
%         saida.nsignals: número de canais
%         saida.data - medições 
%  
%  A.C.S.Souza, J.P.H.Sansão, Abril/2011
%  baseado em: http://www.neurotraces.com/scilab/scilab2/node25.html
%
%[FID, MESSAGE] = fopen(filename);
%tline = fread(FID,'int16');
%fclose(FID);

TamanhoHeader = 224;  
TamanhoFooter = 1751; % deve ser variavel !

offset=160; % achei no chute
bloco=6408; 
nsignals = 32;


[FID, MESSAGE] = fopen(filename);
header = fread(FID,'uint8=>char');
base_header=header(1:TamanhoHeader)';
footer=header(end-TamanhoFooter:end)';
clear header;
fclose(FID);
 
[FID, MESSAGE] = fopen(filename);
header = fread(FID,'int16');
fclose(FID);

nchunks = floor( (length(header)-TamanhoFooter-TamanhoHeader)/bloco);

for J = 1 : nsignals
    A{J,:} = [];     
end


figure(1)
hold on;
for I = 1 : nchunks
    %    subplot(2,1,I)
    chunk = header(offset+(I-1)*bloco+1:offset+(I)*bloco-1-7); ...
    for J = 1 : nsignals
        A{J} = [ A{J}; chunk(J:nsignals:end)];
    end
end

keyboard;

saida.data = A;



