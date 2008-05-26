From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 27 May 2008 07:29:52 +0800
Subject: [Lustre-devel] FW: Moving forward on Quotas
In-Reply-To: <20080526224722.GE3582@lore>
Message-ID: <C46168F0.5462%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


------ Forwarded Message
From: Johann Lombardi <johann@sun.com>
Date: Tue, 27 May 2008 00:47:22 +0200
To: Nikita Danilov <Nikita.Danilov@Sun.COM>
Cc: "Jessica A. Johnson" <Jessica.Johnson@Sun.COM>, Bryon Neitzel
<Bryon.Neitzel@Sun.COM>, Eric Barton <eeb@bartonsoftware.com>, Peter Bojanic
<Peter.Bojanic@Sun.COM>, <Peter.Braam@Sun.COM>
Subject: Re: Moving forward on Quotas

On Mon, May 26, 2008 at 09:56:20PM +0400, Nikita Danilov wrote:
> From reading quota hld it is not clear that master has necessary be an
> mdt server.

Indeed, the quota master could, in theory, be run on any nodes.
The advantage of the MDS is that it already has a connection to each OST.

> Given that ost's are going to have mdt-like recovery in 2.0
> it seems reasonable to hash uid/gid across all osts, that act as masters
> (additionally, it seems logical to handle disk block allocation on ost's
> rather than mdt's). Or am I missing something here?

It would mean that _each_ OSS has to establish a connection to all the OSTs.
Do we already plan to do this in 2.0? I assume that it will probably be
required
anyway to support other striping patterns like RAID1 or RAID5.
However, my concern is that, with OST pools, we should expect to see more
and
more configurations with heterogeneous OSSs. As a consequence, some uid/gid
could end up with a very responsive quota master (connected to a fast
network
which can handle 10,000+ RPCs per second), whereas the quota master could
become
a bottleneck for others, depending on the hash function and the uid/gid
number.

> As per discussion with ZFS team, they are going to implement per-user
> and per-group block quotas in ZFS (inode quotas make little sense for
> ZFS).

ah, great.

> Going aside, if I were designing quota from the scratch right now, I
> would implement it completely inside of Lustre. All that is needed for
> such an implementation is a set of call-backs that local file-system
> invokes when it allocates/frees blocks (or inodes) for a given
> object. Lustre would use these call-backs to transactionally update
> local quota in its own format. That would save us a lot of hassle we
> have dealing with the changing kernel quota interfaces, uid re-mappings,
> and subtle differences between quota implementations on a different file
> systems.

This would also mean that we have to rewrite many things that are provided
by the kernel today (e.g. quotacheck, a tree to manage per-uid/gid quota
data,
...). IMO, we should really weigh the pros and cons before doing so.

> Additionally, this is better aligned with the way we handle access
> control: MDT implements access control checks completely within MDD,
> without relying on underlying file system.

ok.

> What strikes me in this description is how this is similar to DLM. It
> almost looks like quota can be easily implemented as a special type of
> lock, and DLM conflict resolution mechanism with cancellation AST's can
> be used to reclaim quota.

Yes, that's what I think too. I've also been discussing this with Oleg.

Johann

------ End of Forwarded Message
