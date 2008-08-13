From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 12 Aug 2008 21:24:33 -0600
Subject: [Lustre-devel] Completion callbacks
In-Reply-To: <7B72F4D61F2D44C6ADCCF1BC952B9365@ebpc>
Message-ID: <C4C7B011.6C9B%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

...snip....
> 2. EQ callbacks.
> 
> EQ callbacks are currently serialised by the single global LNET lock.
> Holding the lock for the duration of the callback greatly simplifies
> the LNET event handling code, but unfortunately is open to abuse by
> the handler itself (see below).
> 
> The change we're considering is to use one lock per EQ so that we
> get better concurrency by using many EQs.  This avoids complicating
> the existing EQ locking code, but it does require Lustre changes.
> However making Lustre use a pool of EQs (say 1 per CPU) should be a
> very simple and self-contained change.

This doesn't sound so attractive.  Isn't it possible to hide this under the
LNET API?

Peter


> I'd appreciate any feedback on these suggested changes.
> 
> --
> 
> While I'm talking about EQ callbacks, I _do_ think there is still a
> need to restructure some of Lustre's event handlers.  EQ callbacks are
> meant to provide notification and nothing else.  Originally they could
> even be called in interrupt context, so all you are supposed to do in
> them is update status and schedule anything significant for later.
> Nowadays, EQ callbacks are only called in thread context, but the
> general guidance on doing very little apart from notification remains.
> 
> Except things are never quite as black-and-white as that.  For
> example, request_out_callback() has always called
> ptlrpc_req_finished() - and whereas this most usually decrements a
> refcount and maybe frees the request, during shutdown this can
> actually recurse into a complete import cleanup.
> 
> This blatant flouting of the EQ callback rules has never been fixed
> since it didn't actually break anything and didn't hurt performance
> during normal operation.  However problems like this can be compounded
> as new features are developed (e.g. additional code in these callbacks
> to support secure ptlrpc).  So I think it's time to review what can
> happen inside the lustre event handlers and consider what might need
> to be restructured.  Even with improved EQ handler concurrency, you're
> still tying down an LNET thread for the duration of the EQ callback
> with possible unforseen consequences.
> 
> For example, some LNDs use a pool of worker threads - one thread per
> CPU.  If the LND assigns particular connections to particular worker
> threads (e.g. socklnd), none of these connections can make progress
> while the worker thread is executing the event callback handler.
> 
>     Cheers,
>               Eric
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
