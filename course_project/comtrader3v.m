%%
clear;clc;
%% Initial pams
P=400000; % set power
%%
n_sim = 3000; % number of iteration
i=1; 
n_ev = 1500;
regimes = ["OnePhaseSC";"TwoPhaseSC"; "ThreePhaseSC"];
readme = fopen('readme.txt','w');
fprintf(readme, [repmat('%s\t',1, size(regimes,1)) '\n'], regimes);
fclose(readme);
regime = "";

while i <n_sim
    f = randn();

      short_cit_start = rand(1)*(5/60-3/60)+1/60;
      short_cit_end = short_cit_start + rand(1)*3/60;
      
      f = "["+short_cit_start+" "+ short_cit_end + "]" ;
%       % установим время появления и продолжительность кз
          set_param('ComtradeRec_v2/fault1','SwitchTimes',...
              f);
          
%       sim_time = abs(randn())*0.1;    
      % время окончания симуляции
%     set_param('ComtradeRec','StopTime',num2str(0.1));

    log= randi([0,1],1,3); % абсолютно случайная генерация   
    ground_key = 1;
    
    
    if sum(log)==1
        if ground_key
            regime = regimes(1);
        else 
            continue
        end
    elseif sum(log)== 2 
            regime = regimes(2);
    elseif sum(log)== 3 
            regime = regimes(3);
    else
        continue
    end
        
  
    model = "fault1";
    
%     установка параметров модели
    set_param("ComtradeRec_v2/"+model,'FaultA',(log(1)));
    set_param("ComtradeRec_v2/"+model,'FaultB',(log(2)));
    set_param("ComtradeRec_v2/"+model,'FaultC',(log(3)));
    set_param("ComtradeRec_v2/"+model,'GroundFault',ground_key);
    
    set_param('ComtradeRec_v2/Load A1','Activepower',num2str(P+abs(randn()*10000)));
    set_param('ComtradeRec_v2/Load A2','Activepower',num2str(P+abs(randn()*10000)))
    set_param('ComtradeRec_v2/Load A3','Activepower',num2str(P+abs(randn()*10000)))
    set_param('ComtradeRec_v2','MaxConsecutiveZCsMsg','none');
    
    % calling a compilation of power system model
    func=sim('ComtradeRec_v2.slx');
  
    
%          subplot(1,2,1)
%     plot(U3ph_comtrade.time,I3ph_comtrade.signals.values,'.-'), legend('1','2','3','4','5','6','7')
%     xlabel('x'), ylabel('Sin(x)'), title('Sin(x) Graph')
% 
%     subplot(1,2,2)
%     plot(U3ph_comtrade.time,U3ph_comtrade.signals.values,'.-'...
%         ), legend('1','2','3','4','5','6','7')

    
%     запись осциллограмм в .csv
    oscill_table = table(U3ph_comtrade.time(1:n_ev), I3ph_comtrade.signals.values(1:n_ev,1),...
        I3ph_comtrade.signals.values(1:n_ev,2),...
        I3ph_comtrade.signals.values(1:n_ev,3),...
        U3ph_comtrade.signals.values(1:n_ev,1),...
        U3ph_comtrade.signals.values(1:n_ev,2),...
        U3ph_comtrade.signals.values(1:n_ev,3), 'VariableNames',...
        {'time','Ia','Ib','Ic','Ua','Ub','Uc'});
    writetable(oscill_table, regime+""+i+".csv");
    
    
    % reset fault position
    set_param("ComtradeRec_v2/"+model,'FaultA',0);
    set_param("ComtradeRec_v2/"+model,'FaultB',0);
    set_param("ComtradeRec_v2/"+model,'FaultC',0);
    set_param("ComtradeRec_v2/"+model,'GroundFault',0);
    i=i+1;

end
