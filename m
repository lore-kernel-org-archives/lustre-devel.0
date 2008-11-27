From: Andreas Dilger <adilger@sun.com>
Date: Thu, 27 Nov 2008 12:05:05 -0700
Subject: [Lustre-devel] HSM arch wiki
In-Reply-To: <492C2EDE.70507@fnal.gov>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48FD0F98.9040300@sun.com> <492C2EDE.70507@fnal.gov>
Message-ID: <20081127190505.GH3186@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 25, 2008  10:59 -0600, Alex Kulyavtsev wrote:
> - For large existing archive of tapes (~10,000,000 files) it is  
> desirable to import file metadata to lustre fs without actually copying  
> files on disk.
> Import shall be done in reasonable time (hours rather than month) or online.

Concievably this could be done with "mknod" and "setxattr" to store the
striping information into the Lustre inode.  However, one issue will be
how to identify this new file to the HSM.  The current plan is that the
Lustre HSM policy engine database will contain the mapping between the
Lustre FID (~= inode number) and the file in the archive.

Since this is a new file (FID) then we would also need to add an entry to
the policy engine database that contains the mapping from FID->archive
file.

> - a "smart" HSM system can reorder requests to optimize tape access. It  
> is common to have 2000 requests pending in queue with tens or hundreds  
> IO transfers actually served. Current limit of pending requests is about  
> 30,000. We found implementing of pending requests as processes (one  
> copy-out tool process per request waiting for IO) is resource consuming  
> and is not scalable. What is the way to serve ~100,000 request waiting  
> for transfer ?

The Lustre HSM design has the policy engine as a mediator between the
copyin/copyout/purge requests and the userspace agents that are specific
to the HSM and do the actual work.

The policy engine it is free to reorder all of the requests as it sees
fit.  CEA is supplying their existing policy engine as a starting point
for Lustre HSM+HPSS, and I this could be made available to interested
parties sooner rather than later.

> - what proposed scanario to handle OST down ? Suppose file is present on  
> one of OSTs and it went down (striping is one). My understanding is  
> client will wait when OST will come back (case[1]) and file will not be  
> staged from tape automatically. IF file is not present on any OST, it  
> will be staged immediately (case[2]). Is possible to stage file  
> automatically (case[1]) to another OST and mark a copy on old OST for  
> removal ?

Since the OST objects will be removed when the file is purged there is
no requirement to store the file on a particular OST during copyin.
The HSM will store the striping attributes (probably only if they do
not match the filesystem defaults) to ensure that wide striped files
retain this property when returned to the filesystem.

In addition to not saving the striping for files that match the default
layout, we may also consider to save the layout of files with
"stripe_count == target_count" as having a stripe_count = -1 (stripe over
all OSTs) so that if there are more OSTs available when the file is
restored it takes advantage of the additional bandwidth.  We might also
consider having a (policy engine?) tunable that files with > N stripes
are restriped over all OSTs when restored.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
