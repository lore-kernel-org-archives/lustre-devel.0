From: Johann Lombardi <johann@sun.com>
Date: Fri, 19 Jun 2009 23:18:41 +0200
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
 stop blocking
In-Reply-To: <4A3AC95A.10302@cray.com>
References: <4A3AC95A.10302@cray.com>
Message-ID: <447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 19, 2009, at 1:10 AM, Chris Horn wrote:
> Since backup servers immediately begin replay once all clients have
> reconnected we only care about the case where we have dead/dying
> clients, or maybe when clients are "too slow".

Actually, the problem is that all the clients can be considered as "too
slow". Before reconnecting to the failover partner, a client will
first wait for a request to timeout, then it will retry to connect to  
the
same server (for flappy network) and only after those 2 timeouts,
the client will attempt to connect to the the backup server.
This means that the server has to extend the recovery window
accordingly to make sure that all clients can join recovery.
The situation is even worst if you do failover with N servers or
if each target can be reached via several nids on the same host.

The idea of imperative recovery is to tell the clients to reconnect
immediately to the failover partner. This should reduce the overall
recovery time.

> In these cases we are seeking the ability to short circuit the  
> recovery window,
> however this is equivalent to simply having a short(er) recovery  
> window in the first
> place.

Well, if we just reduce the recovery window, some clients will not
join recovery which cannot fully completed (= everything is replayed).

> It seems as though an ability to short circuit is only going to be
> useful if we can distinguish between the case where we only need a  
> short
> recovery window vs. the case where we need that extra time.  My  
> question
> is, what are the use cases where this applies?
>
> My intuition is the following:
> Case 1:  x/y clients which are dead, (y-x)/y clients connected to the
> backup server (all clients that can connect have done so).  We want to
> go ahead and short circuit.

That's the 2nd aspect of imperative recovery. We want to notify the
server when all clients that were supposed to reconnect should
have done so already. Basically, the idea is to tell the server that
no new clients will reconnect now and that it is not needed to wait
any longer for new clients to join (the x clients).

> Case 2:  x/y clients which are dead, (y-x-z)/y clients connected to  
> the
> backup server (z slow clients).  We want more time for the z slow
> clients to connect.

In fact, with imperative recovery, we should no longer have slow
clients since a client no longer needs to detect the server failure
by itself, but instead will be told explicitly to reconnect to the
failover partner w/o any delay.

HTH

Cheers,
Johann
