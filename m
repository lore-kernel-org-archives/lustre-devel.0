From: Eric Barton <eeb@sun.com>
Date: Mon, 15 Dec 2008 20:32:02 +0000
Subject: [Lustre-devel] imperative recovery
In-Reply-To: <1906DB02-F9DF-4F49-9A9A-23FE7E799EA8@sun.com>
References: <1906DB02-F9DF-4F49-9A9A-23FE7E799EA8@sun.com>
Message-ID: <046101c95ef4$2fe3a8d0$8faafa70$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Robert,

Comments inline

> -----Original Message-----
> From: Robert.Read at Sun.COM [mailto:Robert.Read at Sun.COM] On Behalf Of Robert Read
> Sent: 11 December 2008 12:25 AM
> To: Eric Barton
> Subject: imperative recovery
> 
> Earlier today you suggested that the server could ping the clients
> after it restarts. Assuming the server had the nids, how would that
> actually work? Clients don't have any services (or even an acceptor
> for the socklnd case), so how would a server initiate communication
> with the client?  We could add a new kind of RPC that doesn't
> require a ptlrpc connection (much like connect itself doesn't
> require a connection), but it seems at least with socklnd there is
> no way to send that message.

Indeed - this overturns the precedent that Lustre servers don't send
unsolicited RPCs to clients.  This is a nod towards network security
so that client firewalls can trivially block incoming connection
requests.  But this precedent is only assured at the lustre RPC level
- with redundantly routed networks, connections can be established in
either direction at the LND level.  An RPC reply will most probably
follow a different path back through the network to the request sender
and establish new LND connections as required.  This is fine for
kernel LNDs which both create and accept connections - but userspace
LNDs typically don't run acceptors, so userspace LNET specifically
establishes connections to all known routers on startup to avoid this
issue.

Ignoring this precedent for now - one could argue that when a
rebooting server sees info about a client in the on-disk export, it
could have some expectation that the client is waiting for recovery.
Some way of alerting the client that now is a good time to try to
reconnect therefore seems reasonable.  However I think there is a
wider issue to consider first.

Q. Why can't clients reconnect immediately the server restarts?

A. Because they may not know yet that the server died.

Q. Why don't clients know that the server died?

A. Because server death is not detected until RPCs time out.

Q. Why is the RPC timeout so long?

A. Because server death and congestion are easily confused.

This seems to me to get at some fundamental issues about recovery
handling that not even adaptive timeouts has solved for us...

1. Server failover/recovery should complete in 10s of seconds, not
   minutes or hours.

   . Clients must detect server death promptly - much faster than
     normal RPC latency on a congested cluster

   . Servers must detect client death/absence promptly to ensure
     recovery isn't blocked too long by a client crash.

   . To prevent unrelated traffic from being blocked unduly,
     communications associated with a failed client or server must be
     removed from the network promptly, as if the failing node were
     still responsive.

2. Peer failure must be detected with reasonably accuracy in the
   presence of server congestion, LNET router congestion, and LNET
   router failure.

   . Router failure can cause large numbers of RPCs to fail or time
     out.

   . Mis-diagnosing server death is inefficient but the client can
     reconnect harmlessly.

   . Mis-diagnosing client death can cause lost updates when the
     server evicts the client.

> Other options I've thought of to explore this idea:
> 
> - MGS notifies clients (somehow) after a server has restarted.
> 
> - A new tcp socket (possibly in userspace) that can receive
> administrative messages like this (messages can be sent from the
> server, from master admin node, etc). Perhaps related to new lproc
> replacement? Updates could be sent from servers themselves or from
> "god" appliance that was keeping track of server nodes.
> 
> - Use "pdsh lctl" to notify all clients a failover has occurred.
> Ugly, but it would allow us to test the basic idea quickly.  (All we
> need is a new lctl command and changes in the ptlrpc client bits to
> support external initiation of recovery to a specific node, which
> we'll need anyway.)
> 
> 
> robert

I'm totally in favour of supporting additional notification methods
that can increase diagnostic accuracy or speed recovery.  However...

1. We can't rely purely on external notifications.  We need a portable
   baseline capability that works well with existing network
   infrastructure.

2. I'm extremely nervous of relying on notifications via 3rd parties
   unless the whole Lustre communications model is changed to
   accomodate them.  Network failures can be observed quite
   differently from different nodes, so I'd like to stick with methods
   that uses the same paths as regular communications.

I think some elements of the solution include...

0. Change the point-to-point LNET peer health model from one that
   times out individual messages to one that removes messages blocking
   for a failing peer aggressively.  This has already been
   demonstrated to work successfully to flush congested routers when a
   server dies (bug 16186)
 
1. Health related communications must not be affected by congested
   "normal" communications.  The obvious solution is to provide an
   additional virtual LNET just for this traffic - i.e. implement
   message priority - but this poses further questions...

   a. How much will this complicate the LNET/LND implementation -
      e.g. do _all_ connection-based LNDs have to double up their
      connections to ensure orthogonality or complicate existing
      credit protocols to account for priority messaging.

   b. Is 2 priority levels enough - maybe lock conflict resolution
      could/should benefit?

   c. What effect does this have on security/resilience to attack?

2. Aggregate health related communications between peers to minimize
   the number of health messages in the system.  Also ensure health
   related communications only occur when knowledge of peer health is
   actually required - e.g. a client with no locks on a given server
   doesn't have to be responsive.

   The implementation of these features is fundamental to scalability.
   They determine the level of background health "noise" and its
   effect on "real" traffic at a given client and server count given a
   required failure detection latency and limits (or lack thereof) on
   how much state on how many servers each client can cache.

    Cheers,
              Eric
