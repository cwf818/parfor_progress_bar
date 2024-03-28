Yet another elegant progress monitor (progress bar) that works with parfor.

Example output of the commandbar style('$msg$' will be replaced with the
user defined parameter 'msg'):

  3.6%[==>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]$msg$| ~     2min.

Parameters:

  'msg': a user defined message, which is embeded into the output line.
  
  'N':   the total count of upcoming calculations.
  
  ['barStyle']: 0 for commandbar only, 1 for waitbar window only, and 2
for both. It is optional, and 0 is the default value. If there is output
stream during parfor calculation, 1 is suggested.

  ['fqMultiplier']:  the updating frequency multiplier for the progress 
bar. It is optional, the default value is 1, which means 1x of the unit 
frequency(every 1%). For example, 10x means every 0.1%, which means that 
the progress bar updates much faster.

  ['backspaceOn']: backspace trigger. 0 is off, and 1(default) is on.
When Matlab is running under nosplash/nodesktop mode, the backspace
dose not work. For better display, fqMultiplier could set to be 1/4 to
get a suitable updating frequency(~4%).

Return: 

  N>0: a DataQueue for receive updating msg by 'send(DQ,msg)'.
  
  N=0: empty.

Typical usage:

1. Initialization

  parfor_progress_bar(msg, N, barStyle, fqMultiplier, backspaceOn);
  
  initializes the progress monitor for a set of N upcoming calculations.
  
2. Finalization
   
  parfor_progress_bar(msg, 0);
  
  finalizes the progress bar when N is 0
  
3. Updating
   
  send(DQ, msg);
