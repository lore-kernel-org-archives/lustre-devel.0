From: Eric Barton <eeb@sun.com>
Date: Mon, 28 Jan 2008 21:32:43 +0000
Subject: [Lustre-devel] Feed API draft for comment
In-Reply-To: <479E189E.8090106@sun.com>
References: <479A487D.8020602@sun.com>
	<20080126002051.GQ18433@webber.adilger.int> <479E189E.8090106@sun.com>
Message-ID: <0c8901c861f5$51128870$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan,

> 2.1.1
> The type-specific data struct looks awfully like an MDS_REINT record...
> It would be highly convenient if it were exactly the same.  That would
> make it possible, for example, to implement a mechanism like the ZFS
> "send" and "receive" functionality (at the Lustre level) to clone one
> filesystem onto another by "simply" taking the feed from the parent
> filesystem and driving it directly into the batch reintegration mechanism
> being planned for client-side metadata cache.

Didn't we rule this out in Moscow?

> Is there a benefit to having the clientname as an ASCII string, instead
> of the more compact NID value?  This could be expanded in userspace via
> a library call if needed, but avoids server overhead if it isn't needed.

Yes (compact wire representation - lower layers already have it)
No (interop MUCH easier with strings)

> One aspect of the design that is troubling is the guarantee that a
> feed will be persistent once created.  It seems entirely probable that
> some feed would be set up for a particular task, the task completed, and
> then the userspace consumer being stopped without being destroyed, and
> never restarted again.  This would result in a boundless growth of the
> feed "backlog" as there is no longer a consumer.

Needs a good answer

> I'm assuming that the actual kernel implementation of the feed stream
> will allow a "poll" mechanisms (sys_poll, sys_epoll, etc.) to notify
> the consumer, instead of having it e.g. busy wait on the feed size?
> There are a wide variety of services that already function in a similar
> way (e.g. ftp and http servers), and having them efficiently process
> their requests is important.

Good point

> Also, the requirement that a process be privileged to start a feed
> is a bit unfortunate.  I can imagine that it isn't possible to start a
> _persistent_ feed (i.e. one that lives after the death of the application)
> but it should be possible to have a transient one.  

I wouldn't be tempted to relax the privilege required to do _anything_at_all_
with a feed until the security issues are _completely_ understood.

> A simple use case
> would be integration into the Linux inotify/dnotify mechanism (and
> equivalent for OS/X, Solaris) for desktop updates, Spotlight on OS/X,
> Google Desktop search, etc.  It would of course only be possible to
> receive a feed for files that a particular user already had access to.

Until you've really thought through the security implications, a statement
as seemingly obvious as this can't be trusted.  Security issues are
profoundly devious.

> For applications like backup/sync it is also undesirable that the operator
> not need full system privileges in order to start the backup. I suppose
> unprivileged access might be possible by having the privileged feed be
> sent to a secondary userspace process like the dbus-daemon on Linux...
> This also implies that the feed needs to be filterable for a 
> given user.

Again - must be thought through _completely_ before relaxing constraints.

> For consumer feed restart, how does the consumer know where the first
> uncancelled entry begins?  Assuming this is a linear stream of records
> the file offsets can become very large quite quickly.  A mechanism like
> SEEK_DATA would be useful, as would adding some parameters to the
> llapi_audit_getinfo() data structure to return the first and available
> record offset.  Also, there is the risk of 2^64-byte offset overflow
> if this is presented as a regular file to userspace.  It would make more
> sense to present this as a FIFO or socket.

(BTW, please check my figures in the following - it's too easy to be out
 by an order of magnitude...)

2^64 is about 16384 petabytes, so not than many orders of magnitude bigger
than the whole filesystems envisaged for the near future.  Can a feed
include the actual data?  If so, then this could be a real limitation
(say in the next decade).

However it will take 54 years to push 2^64 bytes as a single stream through
a 10GByte/sec network and even with a future 1TByte/sec network (wow - 
imagine that) it would still be 6 months.  So it's not a limitation for a
single stream FTTB.

But must a feed necessarily be a single stream?  Will the bandwidth at
which a feed can be created never exceed the capacity of a single pipe?
Can we envisage the use cases of a clustered feed receiver?  Could that
ever include another lustre filesystem?

    Cheers,
              Eric
