% FIR Bandpass for EEP
% modified from code for ZUUM
% SZ, April 2015
%
% This script generates the fixed point coefficients used in the Xilinx
% FPGA FIR Filters and Matlab Emulator.
%
% Copyright (c) 2015 Volcano corporation
%
% output floating point form
%
% 12/12/2017    Adapted for Prodigy


%% this code is updated to match optimization settings developed by Andy Hancock
%% AH 06/23/2015

%% starting from floating point 

Fs = 200;       % MHz, sampling frequency
decimaterate = 2;
Fs = Fs/decimaterate;

% for 20MHz Prodigy
fc1 = 10;       % MHz, lower cutoff
fc2 = 30;       % MHz, higher cutoff
N = 23;         % filter order, match previous version by Andy H.

% design using fir1, Hamming window (default)
b = fir1(N,[fc1 fc2]*2/Fs,'bandpass');

% gain factor to deal with insertion loss if needed  
gain_factor = 10; % in units of dB

filter_coef_float=b.*10^(gain_factor./20);

figure; % plot filter frequency response
freqz(filter_coef_float,1,1024,Fs*10^6);
title('BPF for PROD');

% define gain range available for the current filter design used
if log2(sum(abs(filter_coef_float)))>1;
    warning('Insufficient Headroom for the desired gain boost');
end    

number_fractional_bits = 15;

% Convert to fixed point by scaling up, rounding, and scaling downs
temp = round(filter_coef_float*(2^number_fractional_bits));
filter_coef_fixed =temp/2^number_fractional_bits;

filter_coef = int32(temp);

%% save file, Matlab mat file
save BPF_24Tap_10_30Mhz.mat filter_coef filter_coef_float;

if 0

%% save to .coe file, fixed point
fname = 'prod_bpf.coe';

% open the output file
fid = fopen(fname,'wt');

% check...
if (fid < 0)
   error('cannot open output file')
end

% set up header
fprintf(fid,'radix = 10;\n');
fprintf(fid,'coefdata = \n');

for jj = 1:length(filter_coef_fixed)-1
    fprintf(fid,'%22.16f,\n',filter_coef_fixed(jj));
end
fprintf(fid,'%22.16f;\n',filter_coef_fixed(jj+1));
fclose(fid);

%% save to .coe file, int16, added by LHK
fname = 'prod_bpf_int16.coe';

filter_coef_int16 = int16(temp);
clear temp;

% open the output file
fid = fopen(fname,'wt');

% check...
if (fid < 0)
   error('cannot open output file')
end

% set up header
fprintf(fid,'radix = 10;\n');
fprintf(fid,'coefdata = \n');

for jj = 1:length(filter_coef_int16)-1
    fprintf(fid,'%d,\n',filter_coef_int16(jj));
end
fprintf(fid,'%d;\n',filter_coef_int16(jj+1));
fclose(fid);
end