From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Tue, 07 Jul 2009 17:56:36 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090706173441.GL15302@Sun.COM>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM>
Message-ID: <op.uwpaclw3atmt0c@garden>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 06 Jul 2009 21:34:41 +0400, Nicolas Williams  
<Nicolas.Williams@sun.com> wrote:

>
> In my proposal what would happen is that opens would only be recovered
> by _replay_ when the transaction had not yet been committed, otherwise
> the opens will be recovered by making a _new_ (non-replay) open RPC.
>

Yes, I understood that and agree that this looks like more clean  
implementation but I see the following problems so far:
  - two kinds of client - new and old that should be handled somehow
  - client code should be changed a lot
  - server need to understand and handle this too

What will we get for this? Sorry for my annoyance, but it looks for me  
that it can be solved in simpler ways. E.g. you can add MGS_OPEN_REPLAY  
flag to such requests, so it will be also different in wire from  
transaction replays. Or we could re-use lock replay functionality somehow.  
The locks are not kept as saved RPC too but enqueued as new requests. The  
open is very close to this, I agree with idea that open handle has all  
needed info and no need to keep original RPC in this case.

I mean that proposed solution looks overcomplicated just to solve  
signature problem though it makes sense in general. If we are going to  
re-organize open recovery and have time for this it would be better to  
move it from context of replay signature to separate task as it is quite  
complex.

>
> I'm not sure why a new stage would necessarily slow recovery in a
> significant way.  The new stage would not involve any writes to disk
> (though it would involve reads, reads which could then be cached and
> benefit the transaction recovery phase).

Not necessarily, but it can. It is not about open stage only, it is about  
the whole approach to do recovery by stages when all clients must wait for  
any other at each stage before they can continue recovery. We have already  
this in HEAD and it extends recovery window. Lustre 1.8 had only single  
timer for recovery, Lustre 2.0 has 3 stages and timer should be re-set  
after each one. If all clients are alive than the recovery time will be  
mostly the same, but if clients may gone during recovery then lustre 2.0  
recovery time can be three times longer already. Just imagine that at each  
stage one client is gone, then at each stage all clients will wait until  
timer expiration. And the bigger cluster we have the more clients can be  
lost during recovery so recovery time may differ significantly.
Also this means that server load is not well distributed over recovery  
time. It waits then start doing all requests at once then waits again on  
other stage, etc.

Another point here is the possible using the version recovery instead of  
transaction-based recovery. This will makes recovery based on versions of  
object and it makes just no sense to wait all clients at each recovery  
stage, because all dependencies should be clear from versions and clients  
may finish recovery independently. Currently the requests can be recovered  
by versions and there is work on lock replays using versions too.

>
> Suppose we recovered opens after transactions: we'd still have
> additional costs for last unlinks since we'd have to put the object on
> an on-disk queue of orpahsn until all open state is recovered.  See
> above.

There is no additional cost for pair of open-unlink because orphan is  
needed anyway after unlink. The only exception is replay of pure unlink.  
But we need to keep orphans after unlinks for other cases anyway, e.g.  
delayed recovery and such overhead is nothing compared with time that can  
be lost on waiting for everyone as described above.

In fact this is already slightly out of scope original idea about open  
replay organization. This is more related to server recovery handling,  
version recovery, delayed recovery and can be discussed later when open  
replay changes on client will be settled, it will be more clear in that  
time.

-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
