From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Fri, 3 Jul 2009 16:55:28 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <op.uwh9t2mnatmt0c@garden>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
Message-ID: <20090703215528.GY15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jul 03, 2009 at 11:02:16PM +0400, Mikhail Pershin wrote:
> On Fri, 03 Jul 2009 02:39:45 +0400, Nicolas Williams  
> <Nicolas.Williams@sun.com> wrote:
> >We're working on adding replay RPC signatures, so that clients may only
> >replay RPCs that have been seen by the server (thus signed).
> 
> Could you explain that more? All replays have been seen by server just by  
> definition because client got reply from server, so what is purpose of  
> such signing?

They've been seen, indeed, but when replayed not all the same
permissions checks may be done, so the server needs to know that the
replay is safe to process.  There's two ways to do that: never skip any
permissions checks when processing replayed RPCs, or have the server
sign replayable RPCs so the server can know validate any replays.  I've
not looked at a complete list of checks that are skipped on replays --
perhaps we should have such a list before we go down the replay
signature path.

> > [...]
> > - then the MDS will accept replays from all clients, new and old
> 
> It is not clear what do 'new' and 'old' mean here? If both 'new' and 'old'  
> have requests to replay so they were active in previous server boot, so  
> what is the difference between them?

Old clients would be clients that don't implement this new form of open
state recovery (e.g., 1.6, 1.8 clients).  New clients would be clients
that do implement this new form of open state recovery (2.x).

> > - followed by lock recovery as usual
> >
> >Client-side high-level description:
> >
> > [...]
> Hmm, but currently it works exactly like this, the committed open replay  
> are sent first followed by normal replays. So you propose to separate them  
> just because they are not 'pure' replays as you described below?

It doesn't work as I proposed: opens are currently recovered by
_replaying_ RPCs (which potentially had side-effects besides creating
open state).  Or at least that's my understanding.

In my proposal open state recovery for opens associated with completed
transactions would always be done by generating new anonymous open by
FID RPCs (not replayed ones).

> >The general principle then would be:
> >
> >   RPC replaying is to be used only for recovering _transactions that
> >   should not be outstanding for very long.
> >
> >Where "very long" is relative to the replay signature crypto key
> >lifecycle, which will be on the order of days.
> >
> >Since opens are not transactions[*] and can stay "outstanding" forever,
> >opens would not be suitable for recovery by replay under that principle.
> >Open state is much more similar to DLM locks than transactions.
> >
> >Open recovery must precede uncommitted transaction recovery so as to
> >ensure that open state is re-established before unlinks can be replayed
> >that would cause the file to be destroyed.
> 
> That requires the server shouldn't start replays from all clients until  
> 'open recovery' is finished from all of them. In fact there is another  

Correct.

> solution for open-unlink problem that was implemented in 1.8. During  
> recovery the unlink replay doesn't delete file but makes it orphan even if  
> open count is 0. After recovery orphans are cleaned up already, so open  
> replay after unlink will find orphan and open it.

That idea did cross my mind.  The MDS would have to keep a list of such
unlinks so it can drop their open count if they truly aren't open.  That
seems like a extra work that the MDS shouldn't have to do.

Nico
-- 
