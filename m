From: Mark Seger <Mark.Seger@hp.com>
Date: Tue, 10 Mar 2009 11:07:36 -0400
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <49B67B91.9080605@cray.com>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>	<20090302204501.GQ3199@webber.adilger.int>
	<49B67B91.9080605@cray.com>
Message-ID: <49B68238.4000901@hp.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>>> **** Statistics ****
>>>
>>> During all the tests the following is supposed to be running on all  
>>> the servers:
>>> 1) vmstat
>>> 2) iostat, if there is some disk activity.
>>> smth else?
>>>       
>> I would propose either LLNL's LMT or HP's collectl, which both also
>> collect Lustre stats.  Those both provide more information than the
>> above, and having the IO/CPU load correlated to Lustre RPC counts is
>> very useful.
>>     
>
> It would be great if we could standardize on a set of tools for performance 
> issues. I've got to think a set of tools like this would make it easier for 
> customer & partners to gather the correct data the first time.
>
> Cray has been using lstats, a package of scripts we got from Sun a while back. 
> We've added things like AT timeout and sar per-cpu usage to it (see bug 18574 
> att 22140 for complete set of scripts).
>
> I'm all for using collectl, but I think the requirements and setup for LMT makes 
>   it a tough sell. Does Sun have a set of customizations for collectl or does 
> the standard collectl collect enough information?
>   
My goal when I wrote collectl was to provide one-stop shopping for as 
much system performance data as seemed relevant and view lustre as only 
one of many data sources.  To that end, if you do a merge of all the 
data collected by the *stat utilities, sar, perfquery (for IB), many of 
the lustre stats (but not all) and maybe a few others you'll get closer 
to understanding what collectl can collect.  On the output side you can 
pick and choose what to display - when used interactively only those 
data elements are collected but when run as a daemon you can collect 
them all and replay the data as ofter as you like looking at different 
slices.

As for LMT I haven't played with it as my interests are in dealing with 
all data.  However, as an exercise left to the reader, there are a 
number of switches for changing collectl's display as well as --home 
which moves the cursor the terminal's home position before displaying 
the output, giving a display similar to the feel of top.  If you want to 
display what's happening to lustre and your disks, cpu, etc all at the 
same time on a refreshing display, --top is definitely the way to go.

And finally, if you want something totally different and are feeling 
creative, just write your own print routines in perl and tell collectl 
to use them with the --export switch.

-mark
