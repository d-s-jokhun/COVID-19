function timeseries19covidConfirmed = import_git(filename, dataLines)
%IMPORTFILE Import data from a text file
%  TIMESERIES19COVIDCONFIRMED = IMPORTFILE(FILENAME) reads data from
%  text file FILENAME for the default selection.  Returns the data as a
%  table.
%
%  TIMESERIES19COVIDCONFIRMED = IMPORTFILE(FILE, DATALINES) reads data
%  for the specified row interval(s) of text file FILENAME. Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  timeseries19covidConfirmed = importfile("E:\Cloud\Google Drive\covid_19\git_GsseRawData\csse_covid_19_data\csse_covid_19_time_series\time_series_19-covid-Confirmed.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 23-Mar-2020 22:37:20

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 3
    dataLines = [2, Inf];
end


%% Setup the Import Options and import the data
% Detects from the file
opts = detectImportOptions(filename);

% Specify range and delimiter
opts.DataLines = dataLines;

% Specify column names
opts.VariableNamesLine=1;


% Specify file level properties
opts.ExtraColumnsRule = "addvars";
opts.EmptyLineRule = "read";

opts = setvaropts(opts, string(opts.VariableNames(3:end)), "FillValue", 0);


% Import the data
timeseries19covidConfirmed = readtable(filename, opts);



end