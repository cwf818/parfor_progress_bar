function DQ=parfor_progress_bar(msg,N,barStyle,fqMultiplier,backspaceOn)
% parfor_progress_bar
% Yet another elegant progress monitor (progress bar) that works with parfor.
%
% Example output of the commandbar style('$msg$' will be replaced with the
% user defined parameter 'msg'):
%   3.6%[==>                                                ]$msg$| ~     2min.
% 
% Parameters:
%   'msg': a user defined message, which is embeded into the output line.
%   'N':   the total count of upcoming calculations.
%   ['barStyle']: 0 for commandbar only, 1 for waitbar window only, and 2
% for both. It is optional, and 0 is the default value. If there is output
% stream during parfor calculation, 1 is suggested.
%   ['fqMultiplier']:  the updating frequency multiplier for the progress 
% bar. It is optional, the default value is 1, which means 1x of the unit 
% frequency(every 1%). For example, 10x means every 0.1%, which means that 
% the progress bar updates much faster.
%   ['backspaceOn']: backspace trigger. 0 is off, and 1(default) is on.
% When Matlab is running under nosplash/nodesktop mode, the backspace
% dose not work. For better display, fqMultiplier could set to be 1/4 to
% get a suitable updating frequency(~4%).
% 
% Return: 
%   N>0: a DataQueue for receive updating msg by 'send(DQ,msg)'.
%   N=0: empty.
% 
% Typical usage:
% 1. Initialization
%   parfor_progress_bar(msg, N, barStyle, fqMultiplier, backspaceOn);
%   initializes the progress monitor for a set of N upcoming calculations.
% 2. Finalization
%   parfor_progress_bar(msg, 0);
%   finalizes the progress bar when N is 0
% 3. Updating
%   send(DQ, msg);
%   
if nargin<3
    barStyle=0;
end
if nargin<4
    fqMultiplier=1;
end
if nargin<5
    backspaceOn=1;
end
BarStyle(barStyle);
Frequency(fqMultiplier);
BackspaceOn(backspaceOn);

if N>0
    DQ=parallel.pool.DataQueue;
    afterEach(DQ,@parfor_each);
    parfor_each(msg,N);
else
    parfor_each(msg,0);
end

function bs=BarStyle(barStyle)
persistent ww
if isempty(ww)
    ww=0;
end
if nargin>0
    ww=barStyle;
end
bs=ww;

function fq=Frequency(frequency)
persistent ff
if isempty(ff)
    ff=1;
end
if nargin>0
    ff=frequency;
end
fq=ff;

function bs=BackspaceOn(backspaceOn)
persistent bb
if isempty(bb)
    bb=1;
end
if nargin>0
    bb=backspaceOn;
end
bs=bb;

function parfor_each(msg,N)
persistent h count total_count tstart

if nargin==2
    if N~=0
        count=0;
        total_count=N;
        if BarStyle()
            h=waitbar(0,msg);
        end
        commandbar(0,total_count,[msg,'|','running...']);
        tstart=tic;
    else 
        elapse=toc(tstart);
        remaining=sprintf(' =%6.1fmin.| %.4fs/iter', elapse/60, elapse/total_count);
        commandbar(total_count,total_count,[msg,'|',remaining]);
        if BarStyle() && isvalid(h)
            delete(h);
        end
    end
else
    count=count+1;
    needupdate=false;
    if floor(floor(count*100*Frequency()/total_count))-floor(floor((count-1)*100*Frequency()/total_count))>=1 && count<total_count
        needupdate=true;
    end
    if needupdate
        elapse=toc(tstart);
        tm=(elapse*total_count/count-elapse)/60;
        if tm<1
            remaining=sprintf(' <%6.0fmin.', 1);
        else
            remaining=sprintf(' ~%6.0fmin.', tm);
        end
        commandbar(count,total_count,[msg,'|',remaining]);
        if BarStyle() && isvalid(h)            
            waitbar(count/total_count,h,[msg,'|',remaining]);
        end            
    end        
end

function commandbar(current,total,msg)
persistent wdispmsg
if mod(BarStyle(),2)==0 % 0(commandbar only) or 2(both)
    w = 50; % Width of progress bar
    percent=100*current/total;
    perc = sprintf('%5.1f%%', percent); % 5 characters wide, percentage
    formatString='%s';
    if current==0
        wdispmsg=0;
        dispmsg=['  0.0%[>', repmat(' ', 1, w), ']', msg];
    elseif current==total
        dispmsg=['100.0%[', repmat('=', 1, w+1), ']', msg];
        formatString='%s\n';
    else
        dispmsg=[perc, '[', repmat('=', 1, round(percent*w/100)), '>', repmat(' ', 1, w - round(percent*w/100)), ']', msg];
    end
    backstring=repmat(char(8), 1, wdispmsg);
    if BackspaceOn()
        fprintf(backstring);
        wdispmsg=fprintf(formatString,dispmsg);
    else
        disp(dispmsg);
    end
%     disp([backstring,dispmsg]);
%     wdispmsg=length(dispmsg)+1;
end

