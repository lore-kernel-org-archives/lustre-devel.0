From: Andreas Dilger <adilger@Sun.COM>
Date: Tue, 16 Dec 2008 14:01:17 -0700
Subject: [Lustre-devel] statahead redesign status
In-Reply-To: <49479733.4060505@sun.com>
References: <49479733.4060505@sun.com>
Message-ID: <20081216210117.GT5000@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

CC lustre-devel

Yong Fan <Yong.Fan@Sun.COM> wrote:
> "readdir+" and "statahead" are quite different means: the mainly idea
> for "readdir+" is that fetch file attributes (name/FID/uid/gid/mode/nlink,
> and so on) directly from MDS when readpage for dir;  The main idea for
> "statahead" is that fetch file name and FID from MDT when readpage for dir,
> then fetch file attribute one by one from MDT. So "readdir+" reduces
> most of the RPC between client and MDS for "ls -l" operation, and the
> performance should be better than "statahead".

Agreed.  We should also consider (possibly as a priority over changing
the statahead code) to do readdir in more than 1-page chunks using bulk
IO from the MDS.  This would also remove some hundreds of RPCs for large
directory reads and improve performance.

> On the other hand, "statahead" also acquires related locks from MDS, but
> "readdir+" is lockless, the later case is faster than the former one.
> It is another difference between "readdir+" and "statahead".

There is no particular reason why the client could not also request locks
on the files at the same time it is requesting the attributes.  There was
a generic "attribute flags" mechanism just added to the 2.0 readdir request
that will allow the client to specify which inode attributes it needs, and
a lock on the inode could be one of them.

Some careful coding would be needed to avoid deadlocks (e.g. readdir+
waiting on one inode lock while also holding many other attribute locks,
another thread doing rename of file inside directory holding the lock and
waiting on one of the readdir locks).  A straight-forward solution would
be to sort the entries in the page by resource number before getting the
attributes (including locks) so that it optimizes the inode reads as well
as keeping the lock ordering correct.

> Above are the advantages of "readdir+" than "statahead". But "readdir+"
> also has shortcoming:
> "readdir+" is heavy load than "readdir", for "ls -l" case, we need
> "readdir+", for "ls" case, we need "readdir" only. But on the review
> of llite, it is difficult to distinguish whether "readdir" or "readdir+"
> should be issued. If used "readdir+" by mistake, it maybe cause "ls"
> performance drop.  But "statahead" has no such issues.

This could be decided on the client in a similar manner as is done today
with statahead.  The client does a single-page readdir to get the dirents,
and then determines whether the process is doing readdir+stat or not.
If it is doing readdir+stat then the subsequent requests would be readdir+
to avoid the extra stat RPCs.

> Both "readdir+" and "statahead" need to fetch some other file attribute
> (size/mtime/ctime, and so on) from OSS one by one if without "SOM"
> (size on MDT) enabled. That means, if we replace "statahead" with
> "readdir+", we also need some pre-fetch mechanism to get these file
> attributes from OSS in advance.

This is already true today.  We thought that SOM would be released by now.
The current statahead code cannot be more than 2x faster than the linear
readdir+stat operation because the client still needs to do one (parallel)
RPC per file to get the size and mtime.  Consider statahead rate:

	stat time = MDT stat time + max(OST stat time)

If we assume the MDT and OSS stat time are the same, and we shrink the
MDT stat time to 0 (because it is done async before application asks for it)
then at best the stat time will shrink by 1/2.

I have thought in the past that the statahead code should start a glimpse
operation as soon as it gets the MDT statahead reply (i.e. OST statahead)
so that the extra OST RPC latency can also be hidden.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
