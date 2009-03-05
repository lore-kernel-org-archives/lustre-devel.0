From: Andreas Dilger <adilger@sun.com>
Date: Thu, 05 Mar 2009 13:00:36 -0700
Subject: [Lustre-devel] Fast checkpoints in Lustre today,
 at	essentially zero cost.
In-Reply-To: <7636AEA6-3D56-491E-A085-C85CA4D96020@sun.com>
References: <7636AEA6-3D56-491E-A085-C85CA4D96020@sun.com>
Message-ID: <20090305200035.GF3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 04, 2009  12:14 -0500, Oleg Drokin wrote:
>     It now suddenly appeared to me (duh!) that we can get that all for  
> free with buffer cache right now. We are artificially limiting our  
> dirty memory to 32M/osc on every node (which is probably way to low
> today too), but if we lift the limit significantly (or remove it
> altogether) such checkpointing applications (and I verified that many
> of them use 10-20% of RAM for checkpointing) would benefit tremendously
> (as long as they do not do fsync at the end of checkpoint, of course).

> Currently there is a way to achieve this same goal, but to do this
> we essentially need to select a very suboptimal stripe pattern  
> (essentially drag your file to be striped across as many OSTs as  
> possible with small stripe size to maximize allowed dirty memory cache
> in use at the expense of a lot of seeking at the OSTs since that would
> essentially mean every client would be writing to every OST).

We don't need to go to the sub-optimal striping to get this result,
as that causes not only lots of seeking on the OSTs, but also requires
the clients to get locks on every OST.  Instead it is possible today
to just increase this limit to be much larger via /proc tunings on
the client for testing (assume 1/2 of RAM is large enough):

client# lctl set_param osc.*.max_dirty_mb=${ramsize/2}

or the cache limit can be increased permanently on all of the clients
via conf_param (sorry, syntax may not be 100% correct):

mgs# lctl --device ${mgsdevno} conf_param fsname.osc.max_dirty_mb=${ramsize/2}

>     The old justification for the small dirty memory limit was to do  
> with lock timeouts and stuff, but now that we have lock prolonging and  
> indefinite waiting for locks on clients on the other, there is no reason
> to limit ourselves anymore, I think.

You are probably correct.  At times we have discussed using the client
grant to manage the amount of dirty data that clients can have, so that
we don't get 5TB of dirty data on the clients for a single 100MB/s OST
before trying to flush the data.  You may be right that with lock extension
and glimpse ASTs we may just be better off to allow the clients to fill
the cache as needed.

One possible downfall is that when multiple clients are writing to the
same file, if the first client to get the lock (full [0-EOF] lock) can
dump a huge amount of dirty data under the lock, all of the other clients
will not even be able to get a lock and start writing until the first
client is finished.

I think this shows up in SSF IOR testing today when the write chunk size
is 4MB being slower than when it is 1MB, because the clients need to flush
4MB of data before their lock can be revoked and split, instead of just 1MB.
Having lock conversion allow the client to shrink or split the lock would
avoid this contention.

>     At the same time Mike is doing a test right now with some real  
> world applications + the above-mentioned suboptimal striping pattern  
> to see the effects as well.
> 
>     I think that allows us to take advantage of huge amounts of wasted  
> memory on compute nodes today for this caching and benefit many  
> application with this checkpointing model (essentially superseding
> old "flash-cache" idea at a fraction of the cost and effort).

Sure, as long as apps are not impacted by the increased memory usage,
since client nodes generally do not have swap, nor would we want to
swap out the application to cache the checkpoint data.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
