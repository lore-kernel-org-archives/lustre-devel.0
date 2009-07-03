From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Fri, 03 Jul 2009 23:02:16 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090702223944.GR15302@Sun.COM>
References: <20090702223944.GR15302@Sun.COM>
Message-ID: <op.uwh9t2mnatmt0c@garden>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 03 Jul 2009 02:39:45 +0400, Nicolas Williams  
<Nicolas.Williams@sun.com> wrote:

> We're working on adding replay RPC signatures, so that clients may only
> replay RPCs that have been seen by the server (thus signed).

Could you explain that more? All replays have been seen by server just by  
definition because client got reply from server, so what is purpose of  
such signing?

> I've been researching this (and talking to Eric B. and Oleg about this).
> Several possible solutions are evident.  I'll describe the one that
> seems most elegant to me (and, I think, Oleg), namely separate open
> state recovery from transaction recovery.
>
> Server-side high-level description:
>
>  - during recovery the MDS will first process anonymous open by FID RPCs
>    from new clients (these open RPCs will not have transaction IDs
>    assigned to them as they imply no actual transactions)
>
>  - then the MDS will accept replays from all clients, new and old

It is not clear what do 'new' and 'old' mean here? If both 'new' and 'old'  
have requests to replay so they were active in previous server boot, so  
what is the difference between them?

>
>  - followed by lock recovery as usual
>
> Client-side high-level description:
>
>  - open processing will begin by sending an RPC as usual...,
> - ... but on commit the md_open_data will be added to a doubly-linked
>    list of opens and the RPC will be removed from the PTLRPC replay
>    queue
>
>  - during recovery the client will begin by traversing the list of
>    md_open_data (open state), reconstruct an anonymous open by FID RPC
>    and send it to the MDS, and after that the client will replay
>    outstanding transactions' RPCs, followed by lock recovery

Hmm, but currently it works exactly like this, the committed open replay  
are sent first followed by normal replays. So you propose to separate them  
just because they are not 'pure' replays as you described below?

>
> Old clients would recover as usual.
>
> Security is provided by the capabilities used in the anonymous open by
> FID RPCs and transport security.
>
> The general principle then would be:
>
>    RPC replaying is to be used only for recovering _transactions that
>    should not be outstanding for very long.
>
> Where "very long" is relative to the replay signature crypto key
> lifecycle, which will be on the order of days.
>
> Since opens are not transactions[*] and can stay "outstanding" forever,
> opens would not be suitable for recovery by replay under that principle.
> Open state is much more similar to DLM locks than transactions.
>
> Open recovery must precede uncommitted transaction recovery so as to
> ensure that open state is re-established before unlinks can be replayed
> that would cause the file to be destroyed.

That requires the server shouldn't start replays from all clients until  
'open recovery' is finished from all of them. In fact there is another  
solution for open-unlink problem that was implemented in 1.8. During  
recovery the unlink replay doesn't delete file but makes it orphan even if  
open count is 0. After recovery orphans are cleaned up already, so open  
replay after unlink will find orphan and open it.


-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
