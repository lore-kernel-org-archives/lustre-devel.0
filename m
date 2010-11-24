From: Eric Barton <eeb@whamcloud.com>
Date: Wed, 24 Nov 2010 13:10:51 -0000
Subject: [Lustre-devel] extend lnet_notify to public LNet API
In-Reply-To: <4CEAA88B.4080406@cray.com>
References: <4CE2AAAA.3000508@cray.com> <4CEAA88B.4080406@cray.com>
Message-ID: <01a701cb8bd9$05b20cf0$111626d0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic,

There's no fundamental reason we wouldn't want to add the ability to
register callbacks to be called from lnet_notify().  But we should
take care of the following details...

0. You will never receive notifications about NIDs that you are not on
   your local LNDs.  For example, if you're a client on a routed
   network, you'll only find out about router health, never about
   server health.

1. Don't just assume only 1 callback can be registered - if this is
   generally useful, several LNET users might want such notification
   and so the API and implementation should allow for it.

2. lnet_notify_locked() is where all notifications arrive.  It's
   called (as the name suggests) holding LNET locks, so any callback
   handling must complete in very well bounded time just like event
   callbacks.

Shadow wrote...

> that idea discussed some time ago (as i remember with green and
> maxim), but have some objection.  Currently LNet hide from ptlrpc
> layer any network flaps, and LNet will resend request without notify
> ptlrpc about flap until ptlrpc request timeout.  

LNET does not resend.  LNet itself doesn't know about "network flaps"
- all it has to go on is whether communications with individual peer
nodes succeed or fail.  

Isaac (correct me if this is too broad brush) most recently worked on
fixing some pathalogical issues with dead peers to ensure that
communications with a _known_ dead peer complete quickly with failure.
Now, the only time communications can be blocked for the whole LND
timeout should be on initial connection establishment to a peer in an
unknown state, or at the point that the peer dies.

> But if ptlrpc will see node down event, ptlrpc will try reconnect -
> that will produce extra overhead, because need to resend too much
> requests from sending and delay lists instead of lots requests in
> network flap time.  

Ptlrpc reconnect to a know dead peer will fail immediately.  However
this communication attempt will cause the LND to attempt connection
re-establishment and if this is successful, LNET will mark the peer
alive.  Subsequent communication attempts should now succeed.

> So, you need separate network flap from node down situation - before
> implementing that.  currently node marked down if node don't respond
> for request in ptlrpc timeout, which include network transmit and
> processing times, but it different then LNet message timeout.

Indeed.  This is further complicated by LNET routing.  Communications
buffered in a router are lost when the router fails, so you have to
regard routed LNETs as potentially lossy.

Nic wrote...

> One oddity - if the LND has peer_health disabled (no ni_peertimeout 
> value), there doesn't seem to be anything that'd set the peer back to 
> 'up'. Am I missing something or is this as desired ?

Hmmm - I originally implemented peer aliveness only for LNET routers
to ensure known dead routers were avoided - so the status of
non-router peers was not used or maintained properly (mea maxima
culpa).

Isaac fixed this more generally as I mentioned above, but it looks
like only socklnd and o2iblnd have the support.  Shouldn't be too hard
to add for ptllnd though :)

-- 

                Cheers,
                        Eric
