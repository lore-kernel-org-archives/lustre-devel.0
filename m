From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 26 May 2011 11:19:24 -0600
Subject: [Lustre-devel] Understanding of LDLM SLV, CLV correct?
In-Reply-To: <1305710949.8503.95.camel@sys367.ldn.framestore.com>
References: <1305710949.8503.95.camel@sys367.ldn.framestore.com>
Message-ID: <74A4CB65-C9AF-4A3E-8932-5AD0434BD945@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-05-18, at 3:29 AM, Jim Vanns <james.vanns@framestore.com> wrote:

> Hi, this is my first post to the list and sadly I've had to resort to
> the developer list because I can't find much detailed info about the
> LDLM intrinsics other than the comments in the source code (which I've
> read).

Hi Jim,
This is the right place for your question. I was hoping someone else would chime in on this topic, but it's been sitting unanswered for too long. 

There should be a design doc for this work in bugzilla that may be of help. 

> OS: Linux 2.6
> Client-side version: 1.8.x
> Server-side version: 1.6.x
> Configuration: 4 nodes (each w/ 4G RAM, 4 CPUs) make up 12 OSSs, 1 MDS
> 
> This is an old and perhaps odd configuration that I've been trying to
> get my head around!
> 
> I'm helping our sysadmins get to the bottom of poor client-side
> performance where the client is evicting pages from it's cache before a
> process has finished with them essentially causing a reread from disk,
> network and back into the cache! Repeat ad infinitum.
> 
> As I understand it this boils down to the server lock volume remaining
> almost constantly as 1 and certainly never greater than the client lock
> volume causing a quicker than normal expiry of the lock(s) the client
> had been granted and when these locks are released so are the pages
> flushed from the cache.

As I recall, there were a number of problems with the DLM automated LRU sizing that were fixed later on. it may be that this problem is resolved in a later version of Lustre, so it would be good to try and find a reproducer with 1.8.5 to verify it still exists, as well as to let others help debug the problem. It would make sense to go through the Lustre/ChangeLog to see when the last fixes were made to this code. 

That said, I'm still not convinced that the behavior of this code and/or its interaction with the VM is what it is supposed to be, so I welcome your investigation into this behavior.

This is one of those situations where it works "well enough" for most users so it hasn't gotten any investigation. Occasionally, however, I notice on my home Lustre system that locks do not remain in the client cache as long as I would expect them to, but have chalked this up to running too many services (MDT + 5 OSTs) on a node with too little RAM (only 2GB). 

> We're using, on the client-side, the dynamic calculation of the LDLM LRU
> size which is based on the numbers I mentioned above - the SLV and CLV.
> Sure enough if I overwrite every OSC lru_size on a single client node to
> NR_CPU*100 (using lctl set_param or /proc) then the LRU size dynamic
> calculation is disabled and we can see our pages remain in RAM (in the
> page cache).
> 
> Conversely if I get clients that have had several large files open for
> some time to kill-off the processes that had them open, the lock grant
> does not go down and neither does the page cache. This is a little
> ironic because this is what we want other clients to do! Is there some
> sort of (resource/lock) contention here?

Closing files or killing the processes that previously read or wrote pages has nothing to do with whether the pages remain on cache or not. Lustre at least partly uses the Linux VM To manage pages in cache, and it tries to keep pages in cache unless there is something else to take it's place.

Processes only hold references on locks while inside a syscall, but if they are frequently accessing files those locks are moved to the head of the DLM LRU list. 

> It seems that there is a correlation between the SLV and the number of
> current granted locks? As I said the SLV on every OSS is more-or-less 1
> all the time.

The "lock volume" is intended to represent (number of locks * lock age) on the server and client. Since the server can't determine which locks on the client are the oldest, it only sends "pressure" to the client to reduce its lock volume instead of canceling specific locks, and the client decides which locks to cancel itself. 

> The #locks granted is quite high - in the order of 10s to
> 100s of thousands per OSS. The number of client nodes is approximately
> 1000 with God knows how many millions of files!

It would be interesting to determine why the OSS is trying to shrink the lock volume. Is it because of memory pressure or normal cache shrinking via the shrinker callbacks? Internal lock volume reduction?

> Am I correct in my assumption that on any individual client node that
> the following files:
> 
> cat /proc/fs/lustre/ldlm/namespaces/<OSCs>/lock_count
> 
> contain the number of locks granted from each OSS to that client only?

Correct. 

> Is there a cancel/evict/expiry timeout attributed to each of these
> locks?

It is possible to dump the internal lock state to the Lustre internal debug log, and then dump the debug log to a file. I'm not sure this will contain all if the data you are looking for, but it is a start. 

Now I just need to recall how that is done...

> As I hinted in the previous paragraph on machines that have
> closed files their lock_count does not decrease and therefore(?) neither
> does their page cache (until pressure to remove them comes from
> elsewhere in the OS).

Unused locks should age and drop off the LRU, but I wonder if there is a problem that these clients are granted a lot of locks and it takes too long to age the locks?

> The problem is, is that I think this is preventing other nodes in the
> cluster from being able to retain any pages in their cache for a decent
> amount of time (i.e. when they are still processing data from open
> files).

There isn't a limit to the number of pages that can be cached under a single lock, so this would only be a problem if these clients are trying to access a large number of different files. 

> I guess what I am asking is for confirmation on all of the above. I'm
> pretty new to Lustre diagnosis! If this was ever a bug (the calculation
> of the SLV never changing for instance or simply not being granular
> enough) then it is probably fixed by now - 2.0 is the current release
> right?

Well, very few sites are using 2.0.  Most are on 1.8, and many are waiting for 2.1 to be released before upgrading. 

> Are there any configuration parameters that may help in this instance,
> however? Could setting the following:
> 
> options ost oss_num_threads=384
> 
> per *server* be a little over zealous considering each server acts as 4
> OSSs and it only has 4G of RAM? This is how it is set at the moment.

No, this is pretty typical, and shouldn't affect the locking too much. I was going to ask about disabling the read cache in the OSS, but that doesn't exist in 1.6 servers yet. 

Cheers, Andreas
