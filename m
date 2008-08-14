From: Eric Barton <eeb@sun.com>
Date: Thu, 14 Aug 2008 10:28:27 +0100
Subject: [Lustre-devel] Completion callbacks
In-Reply-To: <C4C8BC31.6CC1%peter.braam@sun.com>
References: <48A2BFD3.2070900@sun.com> <C4C8BC31.6CC1%peter.braam@sun.com>
Message-ID: <9D08414172D1491EA6948A37F3395FFE@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Thank you for all your feedback.

-- Braam wrote...

> > The change we're considering is to use one lock per EQ so that we
> > get better concurrency by using many EQs.  This avoids
> > complicating the existing EQ locking code, but it does require
> > Lustre changes.  However making Lustre use a pool of EQs (say 1
> > per CPU) should be a very simple and self-contained change.
> 
> This doesn't sound so attractive.  Isn't it possible to hide this
> under the LNET API?

Indeed, but it's not so simple - see Liang/Isaac's suggestion and my
comment below.

-- Nikita wrote...

> What about starting with a single lock for callbacks, _different_
> from the lock protecting ME matching? Also, what callbacks lock
> protects exactly? Maybe it can be replaced with a read-write lock?

Indeed - that would allow us to determine whether we really need to
work further of EQ callback concurrency.

-- Liang Zhan wrote...

> > The change we're considering is to detect when a portal is used
> > exclusively for match-unique MEs (situation (b) - we already use
> > different portals for (a) and (b)) and match using a hash table
> > rather than a list search.
> >   
> if we can always ignore "ignore_bits" of ME (never used by Lustre),
> we can hash MEs by match_bits, otherwise we can only hash NID of
> peer which is less reasonable to me.

The "ignore_bits" parameter _is_ used by lustre.  The 2 usages I
mentioned were "match any", where peer ID is don't care and
ignore_bits is -1, and "match unique", where peer ID is fully
specified and ignore_bits is 0.

> Isaac and I discussed about this and we think:
> 1. We can create an array of locks for each EQ (for example NCPUs
> locks for each EQ), and hash MD (i.e, by handle cookie) to these
> locks to get cocurrent of eq_callback without losing order of events
> for each MD, also, upper layers wouldn't see any change.

Yes, this ensures callbacks on each MD remain ordered - however the
current code also guarantees that the callback and any MD
auto-unlinking completes before LNetEQPoll() can return.  We have to
verify that relaxing ordering here is OK or else do some similar
lock-hashing, say on the EQ slot.

> We can even have an eq_callback_thread (or threads pool) in LNet,
> lnet_enq_event_locked() enqueue event and wakeup the
> callback_thread, so we don't need change ptlrpc at all.

That adds unnecessary context switching.  EQ callbacks may happen in
the context either of the thread doing a PUT or GET (PUT buffered
immediately or you're using the lolnd), or more normally, of an LND
worker thread.  That's plenty of potential concurrency we can
exploit.

    Cheers,
              Eric
