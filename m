From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 31 Jan 2008 14:22:45 -0800
Subject: [Lustre-devel] tunables
In-Reply-To: <20080131213234.GA3419@webber.adilger.int>
References: <0d7401c86229$d2ef52e0$0281a8c0@ebpc>
	<20080129095301.GI18433@webber.adilger.int> <47A225EB.5010301@sun.com>
	<20080131213234.GA3419@webber.adilger.int>
Message-ID: <47A24A35.1000300@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Jan 31, 2008  11:47 -0800, Nathaniel Rutman wrote:
>   
>> 'Andreas Dilger' wrote:
>>     
>>> The patch as it stands now will set any tunables in
>>> /proc/{fs,sys}/{lustre,lnet}/ that match the path regexp supplied.
>>>
>>> This works on both clients and servers.  On 1.6 it just creates a
>>> path regexp to find the various files.  On 1.8 it will eventually
>>> communicate with the uOSS/uMDS process via a socket or something,
>>> but the goal right now is putting an interface in place with the
>>> existing release so that scripts/documentation can be compatible.
>>>
>>> It doesn't necessarily have anything to do with a mountpoint, but it
>>> does require the Lustre devices (that need to be tuned) to be set up.
>>>       
>>   
>> When I originally filed 14471, it was a grand plan of getting rid of /proc/ 
>> and other Linuxisms by putting everything under Lustre control in a special
>> <lustremountpt>/.lustre/param directory.  14471 has now morphed into 
>> "implement lctl {get,set}_param", which, along with 14691, allows a
>> consistent way of accessing the items formerly under proc.  This is fine
>> for a first step, but I still think it doesn't go far enough. We'll
>> eventually need  snapshots: <mntpt>/.lustre/snapshot/ and sooner feeds:
>> <mntpt>/.lustre/feed/
>>     
>
> The "move everything to .../.lustre/param" functionality was moved to
> bug 14687 "Move /proc/{fs,sys}/{lustre,lnet} to /mntpt/.lustre" in
> order to make the separate tasks more manageable.  The work in bug
> 14471 and 14691 are required for userspace servers, and as such for
> the 1.8 release, while 14687 is a "nice to have" and doesn't really
> bear any relationship to snapshots and feeds except that they share
> the ".lustre" virtual directory.
>
> The "lctl {get,set}_param" interfaces are intended to provide a common
> userland interface to tunables and stats regardless of whether the
> servers are running in userspace or the kernel.  I think similar changes
> can easily be made to llstat and collectl to extract stats directly
> from the userspace server processes as well.
>
>   
>> This idea works fine for current clients and servers (which all use 
>> mountpoints), but not for userspace servers.  I don't think we have come
>> up with a good answer for that.
>>     
>
> In fact, the move of the parameters to the lustre mountpoint is
> irrelevant for userspace servers, because they won't have any mountpoint.
> The work in bug 14691 will address the getting and setting of Lustre
> tunables for userspace servers, and access to stats.
>
>   
>> For params that are shared between all mounts, I think its fine to have 
>> access to them from each one; a change anywhere is reflected server-wide.
>>     
>
> This might be considered a security risk, as any malicious client could
> change parameters for the whole system.
>
>   
>> For tunables "relevant without anything at all mounted" say e.g. LNET,
>> or uOSS: I don't know.  Also for tunables that must be set before
>> services are started: I don't know.  FWIW, right now, servers get
>> permanent params out of their config files, but those are read while
>> the services are starting (not before).  Module parameters are used to
>> set pre-startup params. I really don't like the idea of using modules
>> params either (does Solaris use the same API?).  Maybe we need a plain
>> old text config file for portability.
>>     
>
>   
>> Really, I want something contained entirely within Lustre, but I don't see 
>> how to do that unless Lustre is running.
>>
>> I do think the uOSS somehow needs to have a mountpoint.  How is a uOSS 
>> started?
>> Maybe by mounting a stub Lustre client that just provides access to 
>> /.lustre?
>>     
>
> That's just the point - I think you are putting extra requirements in
> place to handle the change to move tunables into .../.lustre.  With
> the work in bug 14691 to communicate directly with the userspace server
> over a socket (a natural process-to-process communication method) there
> is no need to have a mountpoint.  Otherwise, we get into some overly
> complex framework like FUSE to have a userspace process providing services
> to the kernel to provide a mechanism for another userspace process to
> talk to it.  Ugh.
>   
I agree with everything above.
But I was trying to get across a grand unified vision.  If we're going 
to need
snapshots: <mntpt>/.lustre/snapshot/
feeds: <mntpt>/.lustre/feed/
then we may as well have
params: <mntpt>/.lustre/param/

Using lctl {get,set}_param is fine if all we have is params, but what
do we do about snapshots, feeds, etc?  Snapshots in particular
need a real file tree, but I suppose you could argue they only need to
exist on clients.  And I'll have to come up with yet a third interface for
feeds.  I just really like the idea of presenting all of our filesystem
"periphery" stuff in a single, consistent manner.
