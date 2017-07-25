From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Tue, 25 Jul 2017 16:25:40 +0200
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
	,<1500650130.3158.6.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
Message-ID: <1500992740.4728.5.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thank you for your responses. 

Patrick, 

On Fri, 2017-07-21 at 16:43 +0000, Patrick Farrell wrote:
> I think basing this on the maximum number of stripes it too simple,
> and maybe not necessary.
> 
> Apologies in advance if what I say below rests on a misunderstanding
> of the compression design, I should know it better than I do.

Probably I still don't get all the relevant internals of Lustre to
clearly describe what we are planning and what we need.

> About based on maximum stripe count, there are a number of 1000 OST
> systems in the world today.  Imagine one of them with 16 MiB stripes,
> that's ~16 GiB of memory for this.  I think that's clearly too
> large.  But a global (rather than per OSC) pool could be tricky too,
> leading to contention on getting and returning pages.

Well, does that mean that one Lustre client handles all the 16GiB of
stripes at the same time or does it somehow iterate over the stripes?
How much memory do we need at most at the same time? If the client
first processes 100 stripes, we need enough memory to compress 100
stripes at the same time. So the question is not about the maximum
stripe count, but the maximum, let me call it queue portion of stripes,
which can be processed at the same time within one client.

> 
> You mention later a 50 MiB pool per client.  As a per OST pre-
> allocated pool, that would likely be too large.  As a global pool, it
> seems small...
> 
> But why use a global pool?  It sounds like the compression would be
> handled by the thread putting the data on the wire (Sorry if I've got
> that wrong).  So - What about a per-thread block of pages, for each
> ptlrpcd thread?  If the idea is that this compressed data is not
> retained for replay (instead, you would re-compress), then we only
> need a block of max rpc size for each thread (You could just use the
> largest RPC size supported by the client), so it can send that
> compressed data.

Yes, we don't really need a very global pool, but still we need to
know, how many threads can there be at the same time? Is there one
thread per stripe or per RPC? And how many in total?

> 
> The overhead of compression for replay is probably not something we
> need to worry about.
> 
> Or even per-CPU blocks of pages.  That would probably be better still
> (less total memory if there are more ptlrpcds than CPUs), if we can
> guarantee not sleeping during the time the pool is in use.  (I'm not
> sure.)
> 
> Also, you mention limiting the # of threads.  Why is limiting the
> number of threads doing compression of interest?  What are you
> specifically trying to avoid with that?

I mean that the number of threads available for compression is somehow
limited. If we have 100 stripes at the same time, we still can compress
with #cores threads, which might be less than 100. So if there are more
stripes in flight than we have resources for compression (since it is
slower), we need to decide whether to slow down everything or to skip
compression of some stripes for overall better performance. 


Jinshan, 

> 
> Is it possible to enable this by writing to a sysfs or procfs entry?
> So that users can try this out without having to recompile Lustre.

The size should be controllable dynamically, but for the feature Lustre
has to be recompiled anyway. 


>   
> It?s not scalable to have a pool per OSC because Lustre can support
> up to 2000 stripes. However, we don?t need to worry about wide stripe
> problem because no one can write a full stripe with even 1MB stripe
> size, because that means application has to issue 2GB size of write.

Does that mean, we have 2000 stripes and we have 2000 messages/RPCs at
the same time? And we need to be able to compress all 2000 stripes at
the same time to avoid blocking? Is there not any limit how many one
client can have at one point of time? 

> Yes, it?s reasonable to have a global pool for each client node.
> Let?s start from this number but please make it adjustable via sysfs
> or procfs.

I am still not sure how large we can do it. Once we really need 16 GiB
for that pool to quickly serve the compression threads, it is not
doable and we have to think different. Once we have a smaller pool than
we need, we have to block or skip compression, which is undesirable.
But I don't know how to determine the required size. 

Thanks! 

Best regards,
Anna
