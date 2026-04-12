function SetupEnv()

simPaths = {
    genpath(fullfile('Aerodynamics'))
    genpath(fullfile('Component_Plots'))
    genpath(fullfile('ORK'))
    genpath(fullfile('Sim'))
    genpath(fullfile('Structures'))
    genpath(fullfile('Tabulations'))
    genpath(fullfile('Test_Data'))
    genpath(fullfile('Utils'))
};

simPaths = strjoin(simPaths,';');
addpath(simPaths);

end