From: Eric Barton <eeb@sun.com>
Date: Fri, 04 Jan 2008 18:19:44 +0000
Subject: [Lustre-devel] 2 primitives for the NRS
In-Reply-To: <477E662E.30803@gmail.com>
References: <00d501c84ed6$e4fb2010$0281a8c0@ebpc> <477E662E.30803@gmail.com>
Message-ID: <002001c84efe$61cec660$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Wonderful questions! 

> I am trying to plug in an I/O request scheduler into OSS before
> read/write requests get dispatched to the obdfilter. 

If you base your code off b1_6, you can take a free ride on the initial
request processing done by Nathan's adaptive timeout code.

> What I am using
> is hashed bins with a basic rb tree, assuming it would be fairly
> reasonable to handle the number of I/O requests that can reach an
> OSS. My interface calls are very similar to yours, except the lack
> of plug-in comparison. I would not have more to suggest on this. 
> But I do have a couple of questions to check for possible thoughts if
> you have.
> 
> (1) How are you going to order the requests, say the read/write
> ones? I assume you made it flexible with a plug-in compare(). 

Yes - because I don't know yet what's going to work best.  And maybe
different services might want different orders.  And generalisation
when it doesn't hurt performance is a hard habit to break :)

My first thoughts are about fairness to all clients in the face of
unfairness elsewhere - e.g. a gridlocked network - so I'm thinking of
something that picks buffered RPC requests round-robin on client ID.

This is probably good for workloads of large numbers of single-client
jobs to ensure that no individual client can be starved.  However I
also suggest that it's good for I/O performed by a single job spread
over many clients.  

I base this on the idea that a good backend filesystem should and can
optimize disk utilisation.  When a file is written, the file<->disk
offset mapping is fixed for subsequent reads, so I want the NRS to
make I/O request execution order repeatable in the face of network
"noise" and races between clients.  Without this repeatability, we
have to fall back on the disk elevator to re-create the "good" disk
I/O stream on subsequent reads.  Surely it cannot do such a good job
as the NRS since it must have orders of magnitude fewer requests to
play with - bulk buffers must be allocated by the time it sees them.

See http://arch.lustre.org/index.php?title=Network_Request_Scheduler

I'm afraid I don't yet have anything even half backed to say on
write v. read order etc.  I'd still want some empirical evidence first.

> Would the order of the I/O requests based on object ID have some
> relevance to their locality on the disks?

I thinks it might make more sense for the backend F/S to use a job ID
to help it create sequential disk offsets for the whole I/O pattern
rather than anything coming from one individual client.

> I was assuming at least the requests
> can get smoothed out with the objID ordering.
> 
> (2) Have you checked the overhead when there are many concurrent
> threads competing for the locks associated with your heap?  The
> performance impact thereof?

I've only done sequential timings so far.  NRS ops could be "Amdhal
moments" for the whole server so fat SMPs might require some better
care.

> (3) Do you anticipate to merge the requests in any way, or possibly
> batch execute them?

Yes, but I'm such a lazy sod that I hope the disk elevator will smile
on me.  If not and I have to roll up my sleeves - so be it.

    Cheers,
              Eric
