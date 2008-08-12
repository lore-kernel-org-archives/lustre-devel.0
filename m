From: Eric Barton <eeb@sun.com>
Date: Tue, 12 Aug 2008 19:05:01 +0100
Subject: [Lustre-devel] Completion callbacks
Message-ID: <7B72F4D61F2D44C6ADCCF1BC952B9365@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I've been discussing how to improve LNET performance on multi-core
nodes with the Lustre networking team.  The current code uses a single
spinlock for almost everything - this has the advantage of simplicity
but at the obvious expense of serialising everything.

Where usage is simply to safeguard global table handling (e.g. to add
an MD to the global MD hash table), we're inclined to stick with the
single global lock.  In such cases, it's not clear concurrency gains
will justify additional code complication.  So we're really focussing
on the 2 main issues where the global lock can potentially be held for
extended periods.

1. ME matching.

When an LNET GET or PUT arrives, it must be matched against an ME
queued on its destination portal.  There can potentially be many
thousands of these and they can potentially be searched sequentially
with the global lock held.

In fact, Lustre uses MEs in only 2 ways - (a) match-any for incoming
RPC requests and (b) match-unique for everything else.  (a) is
effectively the only place Lustre does actual message queueing - (b)
is used for everything else (i.e. bulk data and RPC replies) and I
think of it as an RDMA, where the matchbits+peerid is the RDMA
descriptor.

(a) always matches the first entry in the list of MEs, so even though
we post 1,000s of request buffers on a server, we never search the
whole list. (b) can potentially lead to a full list search.

The change we're considering is to detect when a portal is used
exclusively for match-unique MEs (situation (b) - we already use
different portals for (a) and (b)) and match using a hash table rather
than a list search.

2. EQ callbacks.

EQ callbacks are currently serialised by the single global LNET lock.
Holding the lock for the duration of the callback greatly simplifies
the LNET event handling code, but unfortunately is open to abuse by
the handler itself (see below).  

The change we're considering is to use one lock per EQ so that we
get better concurrency by using many EQs.  This avoids complicating
the existing EQ locking code, but it does require Lustre changes.  
However making Lustre use a pool of EQs (say 1 per CPU) should be a
very simple and self-contained change.

I'd appreciate any feedback on these suggested changes.

--

While I'm talking about EQ callbacks, I _do_ think there is still a
need to restructure some of Lustre's event handlers.  EQ callbacks are
meant to provide notification and nothing else.  Originally they could
even be called in interrupt context, so all you are supposed to do in
them is update status and schedule anything significant for later.
Nowadays, EQ callbacks are only called in thread context, but the
general guidance on doing very little apart from notification remains.

Except things are never quite as black-and-white as that.  For
example, request_out_callback() has always called
ptlrpc_req_finished() - and whereas this most usually decrements a
refcount and maybe frees the request, during shutdown this can
actually recurse into a complete import cleanup.

This blatant flouting of the EQ callback rules has never been fixed
since it didn't actually break anything and didn't hurt performance
during normal operation.  However problems like this can be compounded
as new features are developed (e.g. additional code in these callbacks
to support secure ptlrpc).  So I think it's time to review what can
happen inside the lustre event handlers and consider what might need
to be restructured.  Even with improved EQ handler concurrency, you're
still tying down an LNET thread for the duration of the EQ callback
with possible unforseen consequences.

For example, some LNDs use a pool of worker threads - one thread per
CPU.  If the LND assigns particular connections to particular worker
threads (e.g. socklnd), none of these connections can make progress
while the worker thread is executing the event callback handler.

    Cheers,
              Eric
