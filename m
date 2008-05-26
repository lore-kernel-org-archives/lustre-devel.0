From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 27 May 2008 07:28:54 +0800
Subject: [Lustre-devel] FW: Moving forward on Quotas
In-Reply-To: <20080526113530.GA3582@lore>
Message-ID: <C46168B8.5461%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


------ Forwarded Message
From: Johann Lombardi <johann@sun.com>
Date: Mon, 26 May 2008 13:35:30 +0200
To: Nikita Danilov <Nikita.Danilov@Sun.COM>
Cc: "Jessica A. Johnson" <Jessica.Johnson@Sun.COM>, Bryon Neitzel
<Bryon.Neitzel@Sun.COM>, Eric Barton <eeb@bartonsoftware.com>, Peter Bojanic
<Peter.Bojanic@Sun.COM>, <Peter.Braam@Sun.COM>
Subject: Re: Moving forward on Quotas

Hi all,

On Sat, May 24, 2008 at 01:33:36AM +0400, Nikita Danilov wrote:
> I think that to understand to what extent current quota architecture,
> design, and implementation need to be changed, we have --among other
> things-- to enumerate the problems that the current implementation has.

For the record, I did a quota review with Peter Braam (report attached) back
in
March.

> It would be very useful to get a list of issues from Johann (and maybe
> Andrew?).

Sure. Actually, they are several aspects to consider:

**************************************************************
* Changes required to quotas because of architecture changes *
**************************************************************

* item #1: Supporting quotas on HEAD (no CMD)

The MDT has been rewritten, but the quota code must be modified to support
the new framework. In addition, we were said not to land quota patches on
HEAD
until this gets fix (it was a mistake IMHO). So, we also have to port all
quota
patches from b1_6 to HEAD.
I don't expect this task to take a lot of time since there is no fundamental
changes in the quota logic. IIRC, Fanyong is already working on this.

* item #2: Supporting quotas with CMD

The quota master is the only one having a global overview of the quota
usages
and limits. On b1_6, the quota master is the MDS and the quota slaves are
the
OSSs. The code is designed in theory to support several MDT slaves too, but
some
shortcuts have been taken and some additional work is needed to support an
architecture with 1 quota master (one of the MDT) and several OSTs/MDTs
slaves.

* item #3: Supporting quotas with DMU

ZFS does not support standard Unix quotas. Instead, it relies on fileset
quotas.
This is a problem because Lustre quotas are set on a per-uid/gid basis.
To support ZFS, we are going to have to put OST objects in a dataset
matching a
dataset on the MDS.
We also have to decide what kind of quota interface we want to have at the
lustre level (do we still set quotas on uid/gid or do we switch to the
dataset
framework?). Things get more complicated if we want to support a MDS using
ldiskfs and OSSs using ZFS (do we have to support this?).
IMHO, in the future, Lustre will want to take advantage of the ZFS space
reservation feature and since this also relies on dataset, I think we should
adopt the ZFS quota framework at the lustre level too.
That being said, my understanding of ZFS quotas is limited to this webpage:
http://docs.huihoo.com/opensolaris/solaris-zfs-administration-guide/html/ch0
5s06.html
and I haven't had the time to dig further.

****************************************************
* Shortcomings of the current quota implementation *
****************************************************

* issue #1: Performance scalability

Performance with quotas enabled are currently good because a single quota
master
is powerful enough to process the quota acquire/release requests. However,
we
know that the quota master is going to become a bottleneck when increasing
the
number of OSTs.
e.g.: 500 OSTs doing 2GB/s (~tera10) with a quota unit size of 100MB
requires
10,000 quota RPCs to be processed by the quota master.
Of course, we could decide to bump the default bunit, but the drawback is
that
it increases the granularity of quotas which is problematic given that quota
space cannot be revoked (see issue #2).
Another approach could be to take advantage of CMD and to spread the load
across
several quota masters. Distributing master could be done on a
per-uid/gid/dataset
basis, but we would still hit the same limitation if we want to reach
100+GB/s
with a single uid/gid/dataset. More complicated algorithms can also be
considered,
at the price of increasing complexity.

* issue #2: Quota accuracy

When a slave runs out of its local quota, it sends an acquire request to the
quota master. As I said earlier, the quota master is the only one having a
global overview of what has been granted to slaves. If the master can
satisfy
the request, it grants a qunit (can be a number of blocks or inodes) to the
slave. The problem is that an OST can return "quota exceeded" (=EDQUOT)
whereas
another OST is still having quotas. There is currently no callback to claim
back the quota space that has been granted to a slave.
Of course, this hurts quota accuracy and usually disturbs users who are
accustomed to use quotas with local filesystems (users do not understand why
they are getting EDQUOT while the disk usage is below the limit).
The dynamic qunit patch (bug 10600) has improved the situation by decreasing
qunit when the master gets closer to the quota limit, but some cases are
still
not addressed because there is still no way to claim back quota space
granted to
the slaves.

* issue #3: Quota overruns

Quotas are handled on the server side and the problem is that there are
currently no interactions between the grant cache and quotas. It means that
a client node can continue caching dirty data while the corresponding user
is over quota on the server side. When the data are written back, the server
is told that the writes have already been acknowledged to the application
(by
checking if OBD_BRW_FROM_GRANT is set) and thus accepts the write request
even
if the user is over quota. The server mentions in the bulk reply that the
user
is over quota and the client is then supposed to stop caching dirty data
(until
the server reports that the user is no longer over quota). The problem is
that
those quota overruns can be really significant since it depends on the
number of
clients:
max_quota_overruns = number of OSTs * number of clients * max_dirty_mb
e.g.               = 500            * 1,000             * 32
                   = 16TB :(
For now, only OSTs are concerned by this problem, but we will have the same
problem with inodes when we have a metadata writeback cache.
Fortunately, not all applications can run into this problem, but this can
happen
(actually, it is quite easy to reproduce with IOR/1 file per task).
I've been thinking of 2 approaches to tackle this problem:
- introduce some quota knowledge on the client side and modify the grant
cache
  to take into account the uid/gid/dataset.
- stop granting [0;EOF] locks when a user gets closer to the quota limit and
  only grant locks covering a region which fits within the remaining quota
space.
  I'm discussing this solution with Oleg atm.

Cheers,
Johann

------ End of Forwarded Message

-------------- next part --------------
A non-text attachment was scrubbed...
Name: Quota.doc
Type: application/octet-stream
Size: 34304 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080527/4b3743ef/attachment.obj>
