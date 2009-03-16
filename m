From: Andrew C. Uselton <acuselton@lbl.gov>
Date: Mon, 16 Mar 2009 13:41:40 -0700
Subject: [Lustre-devel] protocol backofs
In-Reply-To: <029901c9a66b$d7107020$85315060$@com>
References: <49BEA192.2050701@lbl.gov> <029901c9a66b$d7107020$85315060$@com>
Message-ID: <49BEB984.5030206@lbl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Howdy Isaac,
   Nice to meet you.  As Eric suggested I am also cc:ing Nick Henke, 
since he might find this an interesting discussion.  For all you 
lustre-devel dwellers out there, feel free to chime in.
   I have been running a few tests on the Franklin Cray XT at NERSC and 
also on Jaguar (Cray XT at ORNL) and on Jacquard (Opteron/Infiniband 
w/GPFS at NERSC).  You can see a lot of what I have done here:

	http://www.nersc.gov/~uselton/ipm-io.html

In particular, this link shows something of interest:

	http://www.nersc.gov/~uselton/frank_jag/

These tests use Madbench, which has a somewhat unusual I/O pattern.  It 
is implementing an out-of-core solution to a series of very large matrix 
operations.  The third row of graphs gives an idea of the aggregate I/O 
emerging from the application over the course of the run.  It has a 
pattern of writes, reads and writes, then reads.  Each of the I/O spikes 
is from every task writing or reading a single 300 MB buffer.  The last 
row of graphs gives a sense of the task by task behavior.

The "frank_jag" page shows data collected during 4 test with 256 tasks 
(4 tasks per node on 64 nodes).  The target is a single file striped 
across all OSTs of the Lustre file system.   Two tests are on Franklin 
and two on Jaguar.  Each machine runs a test using the POSIX I/O 
interface and another using the MPI-I/O interface.  In the third column 
the Franklin, MPI-I/O test has extremely long delays in the reads in the 
middle phase, but not during the other reads or any of the writes.  This 
does not happen for POSIX, nor does it happen for Jaguar using MPI-I/O. 
  The results shown are entirely reproducible and not due to 
interference from other jobs on the system.  The only difference between 
the Franklin and Jaguar configurations is that Jaguar has 144 OSTs on 72 
OSSs instead of 80 OSTs on 20 OSSs.

Eric put the notion in my head that that we may be looking at a 
contention issue in the Sea-Star network.  Since the I/O is being necked 
down to 20 OSSs in the case of Franklin, this seems plausible.  If you 
guys have a moment to consider the subject I'd like to think about:
a)  Why would contention introduce the catastrophic delays rather than 
just slow things down generally and more or less evenly?  Is there some 
form of back-off in the protocol(s) that could occasionally get kicked 
up to tens of seconds?
b)  Why is the contention introduced only in the MPI-I/O test and not in 
the POSIX test?  Does the MPI-I/O from Cray's xt-mpt/3.1.0 divert I/O to 
a subset of nodes so that all the I/O is going through a smaller section 
of the torus?

If I have been too terse in this note feel free to ask questions and 
I'll try to add more detail.
Cheers,
Andrew
