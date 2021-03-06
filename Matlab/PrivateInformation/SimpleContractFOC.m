% This program computes the Dynamic Incentive and Promise Keeping Constraints for the expected
% utility case. It also computes the gradients
 function res = SimpleContractFOC(x,v0,z_,Para)
% v0 is the exante promised utility
% z_ is the state previous period
% These both are the state variables for the Optimization.
% c(1),c(2) are components of the consumption plan for z_1 and z_2
% bar_vstar(1),bar_vstar(2) are the mean of the continuation plans

% get components from x
c=x(1);
bar_vstar=x(2);


% get components from Para struc
P=Para.P(:,:,Para.m_true);
ra=Para.RA;
delta=Para.delta;
y=Para.y;
sl=Para.sl;
sh=Para.sh;
Delta=y*(sh-sl);


if (c<y-Delta && c>0 && TerminalPKEU(.01,bar_vstar,1,Para)*TerminalPKEU(y-Delta-.01,bar_vstar,1,Para) <0 && TerminalPKEU(.01,bar_vstar,2,Para)*TerminalPKEU(y-Delta-.01,bar_vstar,2,Para) <0 )
% Terminal Period 
%% This section computes the multiplier associated with PK and the value function in the terminal period corresponding to guessed bar_vstar. Note that the envelope condition links lambdastar=Qstar_v(vstar,z)
        cstar0=u_inv(bar_vstar,ra);
        options=optimset('Display','off');
        
        
        for z=1:2
        [cstar(z),fval,exitflag] = fzero(@(cstar) TerminalPKEU(cstar,bar_vstar,z,Para),[.01 (y-Delta-.01)],options);
        lambdastar(z)=[der_u(cstar(z),ra) der_u(cstar(z)+Delta,ra)]*P(z,:)'/([der_u(y-cstar(z),ra) der_u(y-cstar(z)-Delta,ra)]*P(z,:)');
        end
        Elambdastar=sum(P(z_,:).*lambdastar);
        
            

%% Promisekeeping for Agent 2

res(1)=u(y-c,ra)*P(z_,1)+u(y-c-Delta,ra)*P(z_,2)+delta*bar_vstar-v0;

res(2)=der_u(c,ra)*P(z_,1)+der_u(c+Delta,ra)*P(z_,2)-Elambdastar*(der_u(y-c,ra)*P(z_,1)+der_u(y-c-Delta,ra)*P(z_,2));
else
    
 res=[abs(c-y+Delta) abs(bar_vstar)]*1000;   
end



