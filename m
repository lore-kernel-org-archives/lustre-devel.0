From: Andrew C. Uselton <acuselton@lbl.gov>
Date: Tue, 17 Mar 2009 14:45:59 -0700
Subject: [Lustre-devel] protocol backofs
In-Reply-To: <20090317152844.GG17185@sun.com>
References: <49BEA192.2050701@lbl.gov> <029901c9a66b$d7107020$85315060$@com>
	<49BEB984.5030206@lbl.gov> <20090317152844.GG17185@sun.com>
Message-ID: <49C01A17.6070108@lbl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Isaac Huang wrote:
> On Mon, Mar 16, 2009 at 01:41:40PM -0700, Andrew C. Uselton wrote:
>> Howdy Isaac,
...
> Hello Andrew, please see my comments inline.
> 
>> ......
>> The "frank_jag" page shows data collected during 4 test with 256 tasks  
>> (4 tasks per node on 64 nodes).  The target is a single file striped  
>> across all OSTs of the Lustre file system.   Two tests are on Franklin  
>> and two on Jaguar.  Each machine runs a test using the POSIX I/O  
>> interface and another using the MPI-I/O interface.  In the third column  
>> the Franklin, MPI-I/O test has extremely long delays in the reads in the  
>> middle phase, but not during the other reads or any of the writes.  This  
> 
> I've got zero knowledge on MPI-IO. Could you please elaborate for a
> bit on how this "delays in the reads" are measured and what "the
> middle phase" is?
> 
All discussion is related to figures in:

	http://www.nersc.gov/~uselton/frank_jag/

The application in question is MADbench.  I can send a reference or two 
if you want detail on how MADbench works.  In short it is an MPI 
application that solves a very large matrix problem with an out-of-core 
algorithm.  That is, It works on a matrix problem that fills all the 
memory on all the nodes, 64 nodes/256 tasks in this case.  It must write 
out intermediate results and the read them back in.  As such, every task 
must execute a write of 300 MB at each step in "phase 1".  In our 
example phase 1 has eight steps, so eight 300 MB writes from each of 256 
tasks.  In "phase 2", each of the eight matrices must be read in turn, a 
result calculated, and the result written out - for(i=0;i<8i++){read(300 
MB); compute(); write(300 MB);}.  In "phase 3" the eight results are 
again read back in and a final value calculated.

So the reads in the middle phase take a long time when using an MPI-I/O 
interface and a single-file I/O model.  If you follow along in the 
graphs you should be able ot pick out the above actions and see where 
the slow reads are.

The data for identifying this behavior comes from augmenting the 
application with the "Integrated Performance Monitoring" library (IPM). 
  That tool provides an event trace across the whole application of 
library call, result, and timeing information.  Whith that one may 
reconstruct the trace graphs see in the web page.  Other interesting 
manipulations of that data also appear, for instance a histogram of 
frequency of occurence versus bandwidth exibited by individual I/Os.

> 
> Not sure about Franklin, but on Jaguar, depending on the file-system in
> use, the OSSs could reside in either the Sea-Star network or an IB
> network (accessed via lnet routers). I think it might be worthwhile to 
> double check what server network had been used.
> 
I was using /lustre/scr144 on Jaguar.  I believe that is SeaStar.

> 
> It involves many layers:
> 1. At Lustre/PTLRPC layer, there is a limit on the number of in-flight
> RPCs to a server. This is end-to-end, and the limit could change at
> runtime.
The amount of I/O (1.2 GB per node, per step) is large enough I'd assume 
we hit steady state in the RPC mechanism.  Most of the time all 
available system "cache" is full and RPCs are being issued as quickly as 
they can be completed.

> 2. At lnet/lnd layer, for ptllnd and o2iblnd, there's a credit-based
> mechanism to prevent a sending node from overrunning buffers at the
> remote end. This is not end-to-end, and the number of pre-granted
> credits doesn't change over runtime. 

I am only vaguely familiar with the credit mechanism.   That would be 
relevant for the writes, yes?  Is it possible to exhaust the available 
credits and get blocked trying to clear "cache" such that the reads 
(which got started after) can't complete until the writes are drained 
from "cache".  that would certain address why the delays only occur in 
the read,write,read,write... (middle) phase.

> 3. Cray Portals and the Sea-Star network runs beneath lnet/ptllnd, 
> and I'd think that there could also be some similar mechanisms.

Yes, I'm shopping for an understanding of how things can get bogged down 
this way, and why it only appears to happen for MPI-I/O not POSIX.

> 
> Thanks,
> Isaac

Your follow-up note about congestion is consistent with Eric's comment. 
  It may be that the cross-section bandwidth to the region with the OSSs 
is not high enough to forestall congestion.  This could be worse on 
Franklin (20 OSSs) than on Jaguar (72 OSSs) even if Jaguar does have a 
problem with it.
Cheers,
Andrew
