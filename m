From: Isaac Huang <He.Huang@Sun.COM>
Date: Tue, 17 Mar 2009 11:28:44 -0400
Subject: [Lustre-devel] protocol backofs
In-Reply-To: <49BEB984.5030206@lbl.gov>
References: <49BEA192.2050701@lbl.gov> <029901c9a66b$d7107020$85315060$@com>
	<49BEB984.5030206@lbl.gov>
Message-ID: <20090317152844.GG17185@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Mar 16, 2009 at 01:41:40PM -0700, Andrew C. Uselton wrote:
> Howdy Isaac,
>   Nice to meet you.  As Eric suggested I am also cc:ing Nick Henke,  
> since he might find this an interesting discussion.  For all you  
> lustre-devel dwellers out there, feel free to chime in.

Hello Andrew, please see my comments inline.

> ......
> The "frank_jag" page shows data collected during 4 test with 256 tasks  
> (4 tasks per node on 64 nodes).  The target is a single file striped  
> across all OSTs of the Lustre file system.   Two tests are on Franklin  
> and two on Jaguar.  Each machine runs a test using the POSIX I/O  
> interface and another using the MPI-I/O interface.  In the third column  
> the Franklin, MPI-I/O test has extremely long delays in the reads in the  
> middle phase, but not during the other reads or any of the writes.  This  

I've got zero knowledge on MPI-IO. Could you please elaborate for a
bit on how this "delays in the reads" are measured and what "the
middle phase" is?

> does not happen for POSIX, nor does it happen for Jaguar using MPI-I/O.  
> The results shown are entirely reproducible and not due to interference 
> from other jobs on the system.  The only difference between the Franklin 
> and Jaguar configurations is that Jaguar has 144 OSTs on 72 OSSs instead 
> of 80 OSTs on 20 OSSs.

Not sure about Franklin, but on Jaguar, depending on the file-system in
use, the OSSs could reside in either the Sea-Star network or an IB
network (accessed via lnet routers). I think it might be worthwhile to 
double check what server network had been used.

> Eric put the notion in my head that that we may be looking at a  
> contention issue in the Sea-Star network.  Since the I/O is being necked  
> down to 20 OSSs in the case of Franklin, this seems plausible.  If you  
> guys have a moment to consider the subject I'd like to think about:
> a)  Why would contention introduce the catastrophic delays rather than  
> just slow things down generally and more or less evenly?  Is there some  
> form of back-off in the protocol(s) that could occasionally get kicked  
> up to tens of seconds?

It involves many layers:
1. At Lustre/PTLRPC layer, there is a limit on the number of in-flight
RPCs to a server. This is end-to-end, and the limit could change at
runtime.
2. At lnet/lnd layer, for ptllnd and o2iblnd, there's a credit-based
mechanism to prevent a sending node from overrunning buffers at the
remote end. This is not end-to-end, and the number of pre-granted
credits doesn't change over runtime. 
3. Cray Portals and the Sea-Star network runs beneath lnet/ptllnd, 
and I'd think that there could also be some similar mechanisms.

Thanks,
Isaac
