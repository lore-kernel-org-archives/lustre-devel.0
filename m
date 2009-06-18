From: Chris Horn <hornc@cray.com>
Date: Thu, 18 Jun 2009 18:10:18 -0500
Subject: [Lustre-devel] Imperative Recovery - forcing failover server stop
	blocking
Message-ID: <4A3AC95A.10302@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello lustre-devel,

Some thoughts/questions on one aspect of Imperative Recovery.

Via Eric Barton:

"Actually imperative recovery is just explicit notification of clients
to reconnect and explicit notification of the failover server not to
block for any more clients to reconnect."

Since backup servers immediately begin replay once all clients have
reconnected we only care about the case where we have dead/dying
clients, or maybe when clients are "too slow".  In these cases we are
seeking the ability to short circuit the recovery window, however this
is equivalent to simply having a short(er) recovery window in the first
place. 

It seems as though an ability to short circuit is only going to be
useful if we can distinguish between the case where we only need a short
recovery window vs. the case where we need that extra time.  My question
is, what are the use cases where this applies?

My intuition is the following:
Case 1:  x/y clients which are dead, (y-x)/y clients connected to the
backup server (all clients that can connect have done so).  We want to
go ahead and short circuit. 

Case 2:  x/y clients which are dead, (y-x-z)/y clients connected to the
backup server (z slow clients).  We want more time for the z slow
clients to connect.

Am I missing a use case?  If not then my next question is, do we want to
distinguish between these two cases?  If we do want to distinguish
between these two cases, then imperative recovery needs a mechanism to
distinguish between them in addition to the explicit notification of
clients and explicit notification of the failover server. 

If we want to treat these cases the same then imperative recovery
reduces to allowing the recovery window timeout to be tunable (if it
isn't already), and the explicit notification of clients to reconnect
(which still nets a huge improvement over the current implementation). 
I can imagine having an ability to end a server's recovery window early
might be useful to system admins in some circumstances, but I don't see
its utility in an automated failover solution.

Chris Horn
