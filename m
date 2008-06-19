From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 19 Jun 2008 13:24:42 -0700
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <067b01c8c7c6$530dbb40$0281a8c0@ebpc>
References: <2D6B10E2-7BED-4390-A241-7E3D57C0CDF5@Sun.COM>
	<C46DFFAB.5883%peter.braam@sun.com>
	<20080606044135.GJ2961@webber.adilger.int>
	<067b01c8c7c6$530dbb40$0281a8c0@ebpc>
Message-ID: <485AC08A.7070907@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> Oleg's comments about congestion and the ORNL discussions I've been
> involved in are effectively presenting arguments for allowing
> expedited communications.  This is possible but comes at a cost.
>   
> The "proper" implementation effectively holds an uncongested network
> in reserve for expedited communications.  That's a high price to pay
> because it pretty well means doubling up all the LNET state - twice
> the number of queues/sockets/queuepairs/connections.  That's
> unavoidable since we're using these structures for backpressure and
> once they're "full" you can only bypass with an additional connection.
>   
That's assuming network congestion is the cause of the lock timeout.  
What if the server disk is busy doing who knows what, the client's cache 
flush RPCs are all sitting on the server in the request queue just 
waiting for some disk time.  Furthermore assume that a bunch of other 
clients are all doing the same thing, so that we can't simply prioritize 
this clients RPCs over everybody else's. 

I think the method suggested by Oleg has the most potential in this 
case: "sniff" the incoming RPCs to see if they are cache flushes, and do 
not decide to evict those clients until after those RPCs have been 
processed.  As mentioned, we already do sniff the incoming reqs to check 
adaptive timeout deadlines (ptlrpc_server_handle_req_in).

One further thing I would like to do is respond to "easy" RPCs 
immediately (in a reserved thread).  "Easy" would certainly include 
pings, maybe others that have no disk access.  This would allow us to 
free up LNET buffers and other resources, prevent us from evicting 
clients "we haven't heard from in X seconds" (although I just realized 
we could fix that right now in ptlrpc_server_handle_req_in), and more 
quickly determine network and server loading remotely.
