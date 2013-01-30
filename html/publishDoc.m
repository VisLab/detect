%% Publish the documentation in this directory
%


%% Publish the function scripts
baseDirectory = pwd;
publish_options.outputDir = baseDirectory;
publish_options.maxHeight = 300;
generalFunctions = { ...
              'getARfeatures_help', ...
              'getModel_help', ...
              'labelData_help', ...
              'labelWindows_help', ...
              'compareLabels_help', ...
              };
          
for k = 1:length(generalFunctions)
   publish([generalFunctions{k} '.m'], publish_options);
end

%% Publish the function scripts
baseDirectory = pwd;
publish_options.outputDir = baseDirectory;
publish_options.maxHeight = 300;
EEGFunctions = { ...
              'getLabels_help', ...
              'plotLabeledData_help', ...
              'plotMarkedData_help', ...
              'plotWindowData_help', ...
              'markEvents_help', ...
              };
          
for k = 1:length(EEGFunctions)
   publish([EEGFunctions{k} '.m'], publish_options);
end


%% Publish the function scripts
baseDirectory = pwd;
publish_options.outputDir = baseDirectory;
publish_options.maxHeight = 300;
policyFunctions = { ...
              'thresholdPolicy_help', ...
              'unknownPolicy_help' ...
              };
          
for k = 1:length(policyFunctions)
   publish([policyFunctions{k} '.m'], publish_options);
end

