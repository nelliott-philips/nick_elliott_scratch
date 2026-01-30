function outdata = BPF_OutInt16(indata,filter_coef,num_fractional_bits,num_shift_bits)
%% Ver. 1, integer 16 operation
indata = int32(indata);

m = length(filter_coef);    
n = size(indata,1);        
indata = indata'; 
hwdelay = floor((m-1)/2);   
indatanew = cat(2,indata,zeros(size(indata,1),max(hwdelay,m-1),'int32'));
outdata = zeros(size(indatanew),'int32');
for ii = 1 : n+m-1  
    for jj = 1 : min(ii,m)
        outdata(:,ii) = outdata(:,ii) + (filter_coef(jj).*indatanew(:,ii-jj+1));
    end
end

outdata = idivide(outdata,2^(num_fractional_bits-num_shift_bits),'round');

outdata = outdata'; 
outdata = outdata((hwdelay+(1:n)),:); 
outdata = check_bits(outdata, 2^11-1, -2^11, 1); 
outdata = int16(outdata);

end%Function end

function outdata = check_bits(indata, highthresh, lowthresh, signedbits)

outdata = int32(indata);
if isempty(signedbits)
    signedbits = 1; % assume signed data
end
if (signedbits<0) || (signedbits>1)
    error('Not valid Signed Data selection')
end
if signedbits == 1
    outdata(outdata>highthresh) = int32(highthresh);
    outdata(outdata<lowthresh) = int32(lowthresh);
else       
    outdata(outdata>highthresh) = int32(highthresh);
    outdata(outdata < 0) = 0;                            
end
       
outdata = int32(outdata);

end