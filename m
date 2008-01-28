From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 28 Jan 2008 10:02:06 -0800
Subject: [Lustre-devel] Feed API draft for comment
In-Reply-To: <20080126002051.GQ18433@webber.adilger.int>
References: <479A487D.8020602@sun.com>
	<20080126002051.GQ18433@webber.adilger.int>
Message-ID: <479E189E.8090106@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Jan 25, 2008  12:37 -0800, Nathaniel Rutman wrote:
>   
>> This is draft proposal API for the user-level interface for feeds.  (This 
>> does not describe changelogs in general).
>>
>> Feeds would generally be used for two things: creating audit logs, and 
>> driving a database watching for filesystem changes.
>>     
>
> 2.1.1
> The type-specific data struct looks awfully like an MDS_REINT record...
> It would be highly convenient if it were exactly the same.  That would
> make it possible, for example, to implement a mechanism like the ZFS
> "send" and "receive" functionality (at the Lustre level) to clone one
> filesystem onto another by "simply" taking the feed from the parent
> filesystem and driving it directly into the batch reintegration mechanism
> being planned for client-side metadata cache.
>   
That's where I took it from.  You're right, I should include all the 
MDS_REINT fields.
> Is there a benefit to having the clientname as an ASCII string, instead
> of the more compact NID value?  This could be expanded in userspace via
> a library call if needed, but avoids server overhead if it isn't needed.
>   
Good point.  We need a translator to human-readable form anyhow; may as 
well have it
decode the nid as well.
> 2.1.2
> One aspect of the design that is troubling is the guarantee that a
> feed will be persistent once created.  It seems entirely probable that
> some feed would be set up for a particular task, the task completed, and
> then the userspace consumer being stopped without being destroyed, and
> never restarted again.  This would result in a boundless growth of the
> feed "backlog" as there is no longer a consumer.
>   
Here is where the abort_timeout would come in handy.  Maybe I should 
default that to
some large size, or instead have a default abort_size that assumes the 
consumer is
dead when the log grows beyond some number of unconsumed entries.
> 2.1.3
> I'm assuming that the actual kernel implementation of the feed stream
> will allow a "poll" mechanisms (sys_poll, sys_epoll, etc.) to notify
> the consumer, instead of having it e.g. busy wait on the feed size?
> There are a wide variety of services that already function in a similar
> way (e.g. ftp and http servers), and having them efficiently process
> their requests is important.
>   
Consumers would generally blocking wait (not busy wait) on the 
filedescriptor.  
Or use select(2) or poll(2).
> Also, the requirement that a process be privileged to start a feed
> is a bit unfortunate.  I can imagine that it isn't possible to start a
> _persistent_ feed (i.e. one that lives after the death of the application)
> but it should be possible to have a transient one.  A simple use case
> would be integration into the Linux inotify/dnotify mechanism (and
> equivalent for OS/X, Solaris) for desktop updates, Spotlight on OS/X,
> Google Desktop search, etc.  It would of course only be possible to
> receive a feed for files that a particular user already had access to.
>   
the point is security - you don't want joe user to be able to be able to 
log what
every other user is doing to the filesystem.  One might argue, however, 
that
since you're doing this on the server anyhow (not a client), that the server
itself should be secured and we don't bother here...
> For applications like backup/sync it is also undesirable that the operator
> not need full system privileges in order to start the backup.  I suppose
> unprivileged access might be possible by having the privileged feed be
> sent to a secondary userspace process like the dbus-daemon on Linux...
> This also implies that the feed needs to be filterable for a given user.
>
>
> For consumer feed restart, how does the consumer know where the first
> uncancelled entry begins?  Assuming this is a linear stream of records
> the file offsets can become very large quite quickly.  A mechanism like
> SEEK_DATA would be useful, as would adding some parameters to the
> llapi_audit_getinfo() data structure to return the first and available
> record offset.  Also, there is the risk of 2^64-byte offset overflow
> if this is presented as a regular file to userspace.  It would make more
> sense to present this as a FIFO or socket.
>   
The consumer doesn't know, the feed does.  It has retained all 
uncanceled entries
persistently, so it just starts playing back from the first uncanceled 
one.  The consumers
were given sequence numbers in each log entry; it is up to them to 
ignore repeated
records that they already processed (but did not cancel from the feed). 
Ah yes, I get what you are saying now; it's not really a file that you 
can see the beginning of
at any point - the beginning disappears as entries are consumed.  So 
yes, a FIFO. 
That implies a single consumer per FIFO, but I think that's fine.  We'll 
restrict ourselves
to the AC_ONESHOT case, and drop AC_BATCH, which I was unsure was useful 
anyhow.
And yes, getinfo returning max number of available records would be 
useful too.  I'll
still use the next read() as an indicator that the previous batch of 
records read can now
be canceled.
