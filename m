From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Tue, 29 Jan 2008 07:30:08 +0900
Subject: [Lustre-devel] Feed API draft for comment
In-Reply-To: <479E189E.8090106@sun.com>
References: <479A487D.8020602@sun.com>
	<20080126002051.GQ18433@webber.adilger.int> <479E189E.8090106@sun.com>
Message-ID: <479E5770.5040303@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>> 2.1.2
>> One aspect of the design that is troubling is the guarantee that a
>> feed will be persistent once created.  It seems entirely probable that
>> some feed would be set up for a particular task, the task completed, and
>> then the userspace consumer being stopped without being destroyed, and
>> never restarted again.  This would result in a boundless growth of the
>> feed "backlog" as there is no longer a consumer.
>>   
> Here is where the abort_timeout would come in handy.  Maybe I should 
> default that to
> some large size, or instead have a default abort_size that assumes the 
> consumer is
> dead when the log grows beyond some number of unconsumed entries.

There are many feeds for which incurring ENOSPACE is the right answer.  
For example, searches have to be exact, and perhaps re-scanning the file 
system is not an option.  The only reason I know that you may want to 
truncate changelogs forcefully is for non-returning disconnected clients 
or proxies.

So there might be two refcounts (one for essential and one for less 
essential users) on a feed to accomplish this, but having refcounts may 
make it hard to track which consumers have consumed.


>> 2.1.3
>> I'm assuming that the actual kernel implementation of the feed stream
>> will allow a "poll" mechanisms (sys_poll, sys_epoll, etc.) to notify
>> the consumer, instead of having it e.g. busy wait on the feed size?
>> There are a wide variety of services that already function in a similar
>> way (e.g. ftp and http servers), and having them efficiently process
>> their requests is important.
>>   
> Consumers would generally blocking wait (not busy wait) on the 
> filedescriptor.  Or use select(2) or poll(2).
>> Also, the requirement that a process be privileged to start a feed
>> is a bit unfortunate.  I can imagine that it isn't possible to start a
>> _persistent_ feed (i.e. one that lives after the death of the 
>> application)
>> but it should be possible to have a transient one.  A simple use case
>> would be integration into the Linux inotify/dnotify mechanism (and
>> equivalent for OS/X, Solaris) for desktop updates, Spotlight on OS/X,
>> Google Desktop search, etc.  It would of course only be possible to
>> receive a feed for files that a particular user already had access to.
>>   
> the point is security - you don't want joe user to be able to be able 
> to log what
> every other user is doing to the filesystem.  One might argue, 
> however, that
> since you're doing this on the server anyhow (not a client), that the 
> server
> itself should be secured and we don't bother here...


>> For applications like backup/sync it is also undesirable that the 
>> operator
>> not need full system privileges in order to start the backup.  I suppose
>> unprivileged access might be possible by having the privileged feed be
>> sent to a secondary userspace process like the dbus-daemon on Linux...
>> This also implies that the feed needs to be filterable for a given user.
>>


The kerberos user should have FID access priviliges to use a feed. This 
is unrelated to the uid.

>>
>> For consumer feed restart, how does the consumer know where the first
>> uncancelled entry begins?

Usually the replicator reports this (e.g. the search engine says "last 
digested feed entry was....", similar for replicators)

- Peter -
