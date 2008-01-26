From: Andreas Dilger <adilger@sun.com>
Date: Fri, 25 Jan 2008 17:20:51 -0700
Subject: [Lustre-devel] Feed API draft for comment
In-Reply-To: <479A487D.8020602@sun.com>
References: <479A487D.8020602@sun.com>
Message-ID: <20080126002051.GQ18433@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 25, 2008  12:37 -0800, Nathaniel Rutman wrote:
> This is draft proposal API for the user-level interface for feeds.  (This 
> does not describe changelogs in general).
>
> Feeds would generally be used for two things: creating audit logs, and 
> driving a database watching for filesystem changes.

2.1.1
The type-specific data struct looks awfully like an MDS_REINT record...
It would be highly convenient if it were exactly the same.  That would
make it possible, for example, to implement a mechanism like the ZFS
"send" and "receive" functionality (at the Lustre level) to clone one
filesystem onto another by "simply" taking the feed from the parent
filesystem and driving it directly into the batch reintegration mechanism
being planned for client-side metadata cache.

I'm not familiar with all of the details of the ZFS "send" structures,
but my understanding is that these are generated as changelogs from a
particular snapshot, and the record contains enough information to make
the target filesystem an exact clone of the current one, including file
offset+length for "write" commands so that a subset of a large file could
be sent instead of the whole thing.  By doing this against a snapshot,
this allows the feed to "reduce" operations that may have been done
as multiple discrete steps originally (e.g. small writes that change a
large part of a file, or creation and subsequent removal of files after
the reference snapshot).

Is there a benefit to having the clientname as an ASCII string, instead
of the more compact NID value?  This could be expanded in userspace via
a library call if needed, but avoids server overhead if it isn't needed.

2.1.2
One aspect of the design that is troubling is the guarantee that a
feed will be persistent once created.  It seems entirely probable that
some feed would be set up for a particular task, the task completed, and
then the userspace consumer being stopped without being destroyed, and
never restarted again.  This would result in a boundless growth of the
feed "backlog" as there is no longer a consumer.

2.1.3
I'm assuming that the actual kernel implementation of the feed stream
will allow a "poll" mechanisms (sys_poll, sys_epoll, etc.) to notify
the consumer, instead of having it e.g. busy wait on the feed size?
There are a wide variety of services that already function in a similar
way (e.g. ftp and http servers), and having them efficiently process
their requests is important.

Also, the requirement that a process be privileged to start a feed
is a bit unfortunate.  I can imagine that it isn't possible to start a
_persistent_ feed (i.e. one that lives after the death of the application)
but it should be possible to have a transient one.  A simple use case
would be integration into the Linux inotify/dnotify mechanism (and
equivalent for OS/X, Solaris) for desktop updates, Spotlight on OS/X,
Google Desktop search, etc.  It would of course only be possible to
receive a feed for files that a particular user already had access to.

For applications like backup/sync it is also undesirable that the operator
not need full system privileges in order to start the backup.  I suppose
unprivileged access might be possible by having the privileged feed be
sent to a secondary userspace process like the dbus-daemon on Linux...
This also implies that the feed needs to be filterable for a given user.


For consumer feed restart, how does the consumer know where the first
uncancelled entry begins?  Assuming this is a linear stream of records
the file offsets can become very large quite quickly.  A mechanism like
SEEK_DATA would be useful, as would adding some parameters to the
llapi_audit_getinfo() data structure to return the first and available
record offset.  Also, there is the risk of 2^64-byte offset overflow
if this is presented as a regular file to userspace.  It would make more
sense to present this as a FIFO or socket.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
