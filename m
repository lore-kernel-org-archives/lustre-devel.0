From: Patrick Farrell <paf@cray.com>
Date: Thu, 27 Jul 2017 19:22:16 +0000
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <1501143960.3412.3.camel@informatik.uni-hamburg.de>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
	,<1500650130.3158.6.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1500992740.4728.5.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132DD0CCFF2F83BB3BE7F54CBB90@BN6PR1101MB2132.namprd11.prod.outlook.com>,
	<1501143960.3412.3.camel@informatik.uni-hamburg.de>
Message-ID: <BN6PR1101MB2132BBFB8979EA3FBFA4AE2DCBBE0@BN6PR1101MB2132.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ann,


I would be happy to help with review, etc, on this once it's ready to be posted.


In the meantime, I am curious about how you handled the compression and the discontiguous set of pages problem.  Did you use scatter-gather lists like the encryption code does, or some other solution?


Are you willing/able to share the current code, perhaps even off list?  I certainly understand if not, but I am curious to see how it will work and explore the performance implications.


- Patrick

________________________________
From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Sent: Thursday, July 27, 2017 3:26:00 AM
To: Patrick Farrell; Xiong, Jinshan
Cc: Matthew Ahrens; Zhuravlev, Alexey; lustre-devel
Subject: Re: [lustre-devel] Design proposal for client-side compression

Patrick,

> Having reread your LAD presentation (I was there, but it's been a
> while...), I think you've got a good architecture.

There have been some changes since that, but the general things should
be the same.

> A few thoughts.
>
> 1. Jinshan was just suggesting including in the code a switch to
> enable/disable the feature at runtime, for an example, see his fast
> read patch:
> https://review.whamcloud.com/#/c/20255/
> Especially the proc section:
> https://review.whamcloud.com/#/c/20255/7/lustre/llite/lproc_llite.c
> The effect of that is a file in proc that one can use to
> disable/enable the feature by echoing 0 or 1.
> (I think there is probably a place for tuning beyond that, but that's
> separate.)
> This is great for features that may have complex impacts, and also
> for people who want to test a feature to see how it changes things.

Oh, I misunderstood Jinshan last time, sorry. Yes, it would be much
easier for users and should be possible. Thank you for references!

> 2. Lustre clients iterate over the stripes, basically.
>
> Here's an explanation of the write path on the client that should
> help.  This explanation is heavily simplified and incorrect in some
> of the details, but should be accurate enough for your question.
> The I/O model on the client (for buffered I/O, direct I/O is
> different) is that the writing process (userspace process) starts an
> I/O, then identifies which parts of the I/O go to which stripes, gets
> the locks it needs, then copies the data through the page cache...
> Once the data is copied to the page cache, Lustre then works on
> writing out that data.  In general, it does it asynchronously, where
> the userspace process returns and then data write-out is handled by
> the ptlrpcd (daemon) threads, but in various exceptional conditions
> it may do the write-out in the userspace process.
>
> In general, the write out is going to happen in parallel (to
> different OSTs) with different ptlrpcd threads taking different
> chunks of data and putting them on the wire, and sometimes the
> userspace thread doing that work for some of the data as well.
>
> So "How much memory do we need at most at the same time?" is not a
> question with an easy answer.  When doing a bulk RPC, generally, the
> sender sends an RPC announcing the bulk data is ready, then the
> recipient copies the data (RDMA) (or the sender sends it over to a
> buffer if no RDMA) and announces to the client it has done so.  I'm
> not 100% clear on the sequencing here, but the key thing is there's a
> time where we've sent the RPC but we aren't done with the buffer.  So
> we can send another RPC before that buffer is retired.  (If I've got
> this badly wrong, I hope someone will correct me.
>
> So the total amount of memory required to do this is going to depend
> on how fast data is being sent, rather than on the # of OSTs or any
> other constant.
>
> There *is* a per OST limit to how many RPCs a client can have in
> flight at once, but it's generally set so the client can get good
> performance to one OST.  Allocating data for max_rpcs_in_flight*num
> OSTs would be far too much, because in the 1000 OST case, a client
> can probably only have a few hundred RPCs in flight (if that...) at
> once on a normal network.
>
> But if we are writing from one client to many OSTs, how many RPCs are
> in flight at once is going to depend more on how fast our network is
> (or, possibly, CPU on the client if the network is fast and/or CPU is
> slow) than any explicit limits.  The explicit limits are much higher
> than we will hit in practice.
>
> Does that make sense?  It doesn't make your problem any easier...

Totally, and you are right, it is more complex than I hoped.

>
> It actually seems like maybe a global pool of pages *is* the right
> answer.  The question is how big to make it...
> What about making it grow on demand up to a configurable upper limit?
>
> The allocation code for encryption is here (it's pretty complicated
> and it works on the assumption that it must get pages or return
> ENOMEM - The compression code doesn't absolutely have to get pages,
> so it could be changed):
> sptlrpc_enc_pool_get_pages
>
> It seems like maybe that code could be adjusted to serve both the
> encryption case (must not fail, if it can't get memory, return
> -ENOMEM to cause retries), and the compression case (can fail, if it
> fails, should not do compression...  Maybe should consume less
> memory)

Currently we are not very close to the sptlrpc layer and do not use any
of the encryption structures (it was initially planned, but turned out
differently). But we have already looked at those pools.

>
> About thread counts:
> Encryption is handled in the ptlrpc code, and your presentation noted
> the plan is to mimic that, which sounds good to me.  That means
> there's no reason for you to explicitly control the number of threads
> doing compression, the same number of threads doing sending will be
> doing compression, which seems fine.  (Unless there's some point of
> contention in the compression code, but that seems unlikely...)

We currently intervene before the request is created
(osc_brw_prep_request) but still we don't do anything explicitly with
threads, just put some more tasks to the existing ones. Limited
resources is more the later part where we will optimize, tune and
introduce the adaptive part.

>
> Hope that helps a bit.

It helps a lot! Thank you!

Anna
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170727/4cbace68/attachment.htm>
