From: Andreas Dilger <adilger@sun.com>
Date: Sat, 16 Feb 2008 00:40:46 -0700
Subject: [Lustre-devel] Global generic database
In-Reply-To: <200802152050.28398.alexander.zarochentsev@sun.com>
References: <47B335B6.5010703@sun.com>
	<200802152050.28398.alexander.zarochentsev@sun.com>
Message-ID: <20080216074046.GD3029@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 15, 2008  20:50 +0300, Alexander Zarochentsev wrote:
> On 13 February 2008 21:23:50 Nathaniel Rutman wrote:
> > The design of various new features in Lustre call for global
> > (filesystem wide) databases, accessible from
> > clients or other servers:
> > A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool
> > policies (all .jpg files to pool #1)
> > B. filesets - fileset policies (log creates on fileset #1 to feed
> > "foo") C. HSM - (aureleien - what was the use case here?)
> >
> > We've already implemented at least 2 of these:
> > D. Fid Location Database - (is this done?)
> > E. configuration parameters - stored in MGS llogs
> 
> ?ould be the same (file?) interface used for anything Lustre-specific 
> under /proc? Anyway we need a /proc replacement for use-level lustre 
> servers.

There won't immediately be a /proc replacement for uOSS.  Instead, there
will be a new "lctl {get,set}_param" command that reads/writes the
same proc entries.  At some later time we will make a .lustre/proc
directory which will allow access to the files currently in /proc,
possibly also allowing access to /proc values on all lustre nodes.
That hasn't been designed yet, but would definitely be convenient.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
