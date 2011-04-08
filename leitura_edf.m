function [saida] = leitura_edf(filename)
% leitura_edf  rotina para leitura de arquivo no formato edf
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
[FID, MESSAGE] = fopen(filename);
tline = fread(FID,'int16');
fclose(FID);

[FID, MESSAGE] = fopen(filename);
header = fread(FID,'uint8=>char');
fclose(FID);

base_header=header(1:256)';

version = base_header(1:8);
% patient ident.
patientid = base_header(9:88);                
%record ident.
recordid = base_header(89:166);  
% date
startdate = base_header(169:176); 
%time            
starttime = base_header(177:184); 
% bytes of header
nbytesheader = str2num(base_header(185:192));   
% reserved field
reserved = base_header(193:236);
% data records
ndatarecords = str2num(base_header(237:244));  
% duration 
duration = str2num(base_header(245:252));
% number of sign
nsignals = str2num(base_header(253:256)); 

% leitura dos outros cabeçalhos



extra_header = header(257:nbytesheader)';

%labels
ponteiro = 1;
for I=1:nsignals                       
    label{I}=extra_header(ponteiro:ponteiro+16-1);
    ponteiro = ponteiro + 16;
end


%transdutor
for I=1:nsignals
    transducer{I}=extra_header(ponteiro:ponteiro+80-1);
    ponteiro = ponteiro + 80;
end

% phys. dimensions
for I=1:nsignals
    physdim{I}=extra_header(ponteiro:ponteiro+8-1);
    ponteiro = ponteiro + 8;
end

% physical minimum
for I=1:nsignals
    physmin{I}=str2num(extra_header(ponteiro:ponteiro+8-1));
    ponteiro = ponteiro + 8;
end

% physical maximum
for I=1:nsignals
    physmax{I}=str2num(extra_header(ponteiro:ponteiro+8-1));
    ponteiro = ponteiro + 8;
end

%digital minimum
for I=1:nsignals 
    digmin{I}=str2num(extra_header(ponteiro:ponteiro+8-1));
    ponteiro = ponteiro + 8;
end
% digital maximum
for I=1:nsignals 
    digmax{I}=str2num(extra_header(ponteiro:ponteiro+8-1));
    ponteiro = ponteiro + 8;
end
% prefiltering 
for I=1:nsignals
    prefilter{I}=extra_header(ponteiro:ponteiro+80-1);
    ponteiro = ponteiro + 80;
end
% samples of sign. 
for I=1:nsignals
    nsamples{I}=str2num(extra_header(ponteiro:ponteiro+8-1));
    ponteiro = ponteiro + 8;
end
% reserved
% for I=1:nsignals
%     reserved{I}=extra_header(ponteiro:ponteiro+32-1);
%     ponteiro = ponteiro + 32;
%     reserved{I}
%     pause;
% end


clear header;

ns = nsignals;
%considera que os sinais tem mesmo número de amostras,
%que nem sempre é verdade
nr = nsamples{1};

offset = nbytesheader/2 ;

B = tline(offset+1:end);



for J = 1 : ns
    A{J,:} = [];     
end

% para o escalonamento admite-se que a quantização 
% é simétrica, e o fundo de escala também

 
for I = 1 : (ns * nr): length(tline(offset:end)) - (ns*nr)
    for J = 1 : ns
        trecho = (physmax{J} /digmax{J})*  B((I + (J-1) * nr):(I + ...
                                                          (J) * nr -1));
        A{J} = [ A{J}; trecho ];
    end
end


saida.data = A;
%patient ident.
saida.id = patientid;
%record ident.
saida.recordid = recordid;
%date
saida.startdate = startdate;
%time            
saida.starttime = starttime;
%reserved field
saida.reserved = reserved;
%duration 
saida.duration = duration;
%number of sign
saida.nsignals = nsignals;
