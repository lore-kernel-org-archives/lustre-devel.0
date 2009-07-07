From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Tue, 7 Jul 2009 11:14:27 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <op.uwpaclw3atmt0c@garden>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <op.uwpaclw3atmt0c@garden>
Message-ID: <20090707161427.GE15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 07, 2009 at 05:56:36PM +0400, Mikhail Pershin wrote:
> What will we get for this? Sorry for my annoyance, but it looks for me  
> that it can be solved in simpler ways. E.g. you can add MGS_OPEN_REPLAY  
> flag to such requests, so it will be also different in wire from  
> transaction replays. Or we could re-use lock replay functionality somehow.  

Making the open replays look different on the wire is exactly what this
is about.  They'll look different from other replays in that they will
not have a replay signature.  But replay signatures are a PTLRPC layer
feature, so how should PTLRPC know whether to allow such a replay to
pass through?  One way is to let it pass through replays with valid
signatures and non-replays, and then let the MDT have non-replay
handlers only for anon open by FID during recovery.  Then the client
might as well not bother caching open RPCs forever, just until they
commit -- it can re-construct open RPCs from in-core state (vnode, ...)
anytime it needs to.

Using DLM locks to represent open state is interesting.  It would
require either recovering those first or deferring final unlinks at
transaction recover time.

Another problem with using locks for open state is that establishing the
lock atomically with an open w/ create won't be easy.  The MDT would
have to enqueue a lock for itself atomically with the create, then the
client would have to enquee its lock, then the MDT would have to drop
its lock.  Would this not be much more complex that open RPC
reconstruction?

> The locks are not kept as saved RPC too but enqueued as new requests. The  
> open is very close to this, I agree with idea that open handle has all  
> needed info and no need to keep original RPC in this case.

Yes.

Nico
-- 
