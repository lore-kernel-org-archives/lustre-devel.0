From: Isaac Huang <He.Huang@Sun.COM>
Date: Tue, 17 Mar 2009 14:13:29 -0400
Subject: [Lustre-devel] protocol backofs
In-Reply-To: <49BEB984.5030206@lbl.gov>
References: <49BEA192.2050701@lbl.gov> <029901c9a66b$d7107020$85315060$@com>
	<49BEB984.5030206@lbl.gov>
Message-ID: <20090317181329.GO17185@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Mar 16, 2009 at 01:41:40PM -0700, Andrew C. Uselton wrote:
> ......
> The "frank_jag" page shows data collected during 4 test with 256 tasks  
> (4 tasks per node on 64 nodes).  The target is a single file striped  
> across all OSTs of the Lustre file system.   Two tests are on Franklin  
> and two on Jaguar.  Each machine runs a test using the POSIX I/O  
> interface and another using the MPI-I/O interface.  In the third column  
> the Franklin, MPI-I/O test has extremely long delays in the reads in the  
> middle phase, but not during the other reads or any of the writes.  This  
> does not happen for POSIX, nor does it happen for Jaguar using MPI-I/O.  
> The results shown are entirely reproducible and not due to interference 
> from other jobs on the system.  The only difference between the Franklin 
> and Jaguar configurations is that Jaguar has 144 OSTs on 72 OSSs instead 
> of 80 OSTs on 20 OSSs.

I just happened to have a talk with an ORNL folk and was told that,
when compared with the other Cray XT system, it's relatively easier
to hit congestion in Sea-Star network on Jaguar where the servers are
less distributed with regard to the network topology. So I wonder
whether there could be a similar difference between Franklin and
Jaguar? On the other hand, were the POSIX test and the MPI-IO test on
Franklin run over the same set of client nodes?

Thanks,
Isaac
