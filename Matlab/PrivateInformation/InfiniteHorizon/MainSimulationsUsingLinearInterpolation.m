load (['Data/' Para.StoreFileName])
if matlabpool('size')>0
matlabpool close force local
end
matlabpool open local


fineGridSize=300;
fineGrid=linspace(Para.vSuperMin,Para.vSuperMax,fineGridSize);
PolicyRulesStoreOld=PolicyRulesStore;
PolicyRulesStore=[];
tic
parfor ctr=1:fineGridSize        
        
       % INITAL GUESS FOR THE INNER OPTIMIZATION
        %InitContract=PolicyRulesStore(ctr,:);
        InitContract=GetInitialApproxPolicy(fineGrid(ctr),domain', PolicyRulesStoreOld);
        % INNER OPTIMIZATION
        strucOptimalContract=SolveInnerOptimization(fineGrid(ctr),InitContract,Para,c,Q) ;      
        ExitFlag(ctr)=strucOptimalContract.ExitFlag;
        QNew(ctr)=strucOptimalContract.QNew;
        LambdaStore(ctr)=-strucOptimalContract.Mu.eqnonlin;
        MuStore(ctr,:)=strucOptimalContract.Mu.ineqnonlin';
        DistortedBeliefsAgent1Store(ctr,:)=strucOptimalContract.tilde_p0_agent_1 ;
    DistortedBeliefsAgent2Store(ctr,:)=strucOptimalContract.tilde_p0_agent_2 ;
    
        %UPDATE POLICY RULES
             PolicyRulesStore(ctr,:)=strucOptimalContract.Contract;   
end
 domain=fineGrid; 
OptimalChoices=[ PolicyRulesStore LambdaStore' MuStore DistortedBeliefsAgent1Store DistortedBeliefsAgent2Store];
save(['Data/' Para.StoreFileName],'c','Q','cdiff','domain','cdiff','cStore','LambdaStore','PolicyRulesStore','Para','MuStore','ExitFlag','DistortedBeliefsAgent1Store','DistortedBeliefsAgent2Store')


% number of startng points
K=3;
% vLow vMed vHigh
z=1;
TargetConsumption(1)=.10*Para.y;
%vHigh=fzero(@(v) ResMapConsumptionToValue(TargetConsumption(1),v,c,Q,Para,domain,PolicyRulesStore,z) ,[min(domain),max(domain)]);
TargeConsumption(2)=.5*Para.y;
vMed=fzero(@(v) ResMapConsumptionToValue(TargeConsumption(2),v,c,Q,Para,domain,PolicyRulesStore,z) ,[min(domain),max(domain)]);
TargeConsumption(3)=(1-Para.Delta)*Para.y;
%vLow=fzero(@(v) ResMapConsumptionToValue(TargeConsumption(3),v,c,Q,Para,domain,PolicyRulesStore,z) ,[min(domain),max(domain)]);

v0=[domain(end)*.98 vMed domain(1)*1.01];
% NumSim

parfor k=1:K
    tic
    SimData(k)=RunSimulationsUsingLinearInterpolation(v0(k),rHist,NumSim,fineGrid,OptimalChoices,Para);
    toc
end

save(['Data/Sim' Para.StoreFileName],'rHist','SimData','TargetConsumption','K','NumSim','Para','Q','c','domain','PolicyRulesStore')
