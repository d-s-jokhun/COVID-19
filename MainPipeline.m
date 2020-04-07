%% Written by d.s.jokhun on 2020.03.21

rep_BaseName=datetime;
rep_BaseName.Format='yyyyMMdd';
rep_BaseName=['report_',char(rep_BaseName),'.pdf'];
file=which('analyser.mlx');
address=extractBetween(file,1,'analyser');
addpath (char(address))
cd ([char(address),char('csse_covid_19_data\csse_covid_19_time_series')])
matlab.internal.liveeditor.executeAndSave(file);
matlab.internal.liveeditor.openAndConvert(file,[char(address),char('Reports\'),char(rep_BaseName)]);
cd (char(address))

'Analysis Complete!'
