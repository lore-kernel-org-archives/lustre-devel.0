From: Andreas Dilger <adilger@sun.com>
Date: Fri, 26 Sep 2008 13:51:30 -0600
Subject: [Lustre-devel] Simpifying Interoperation
In-Reply-To: <CF0D4EA95C1945F18F74426BB95008CE@ebpc>
References: <CF0D4EA95C1945F18F74426BB95008CE@ebpc>
Message-ID: <20080926195130.GE10950@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sep 25, 2008  16:54 +0100, Eric Barton wrote:
> 1. This scheme should not interfere with upgrade via failover pairs,
>    and it must also allow the MDS to be upgraded separately from the
>    OSSs.  I think this means in general that we have to allow
>    piecemeal server upgrades.
> 
> 2. This scheme need a mechanism that...
> 
>    a) notifies clients when a particular server is about to upgrade so
>       that update operations are blocked until the upgrade completes
>       and the client reconnects to the upgraded (and/or failed over)
>       server.
> 
>    b) notifies the server when all clients have completed preparation
>       for the upgrade so that no further requests require resend.
> 
>    c) notifies clients when all outstanding updates have been
>       committed.  If the server crashes before this point, client
>       replay is still required.  Clients must not poll for this since
>       the server is shutting down.
> 
>    The DLM seems the right basic mechanism to notify clients, however
>    current assumptions about acquisition timeouts might be an issue.
> 
>    We must also ensure that the race between this server upgrade
>    process and connection establishment (including any new
>    notification locks) by new clients is handled consistently.

Having the MGS handle the locking here seems like the right thing.
Something like a persistent "all access" lock that is held by the
client in the MGS namespace indefinitely, but if the MGS ever revokes
it the client must block all operations until it can re-get it.

> 3. It's not clear to me that we need to evict, or even clean the
>    client cache provided the client doesn't attempt any more writes
>    until it has connected to the failover server.  The client can
>    re-acquire all the locks covering its cache during recovery after
>    the upgrade - and there is no need for request refomatting here
>    since locks are replayed explicitly (i.e. new requests are
>    formatted from scratch using the correct protocol version).
> 
>    It does seem advisable however to clean the cache before such a
>    significant system incident.

Definitely, yes, flushing the client's dirty data to disk is a good
idea.  That would also minimize the number and type of things that
can go wrong during an upgrade.  I wouldn't totally be against the
server cancelling all of the client locks during an upgrade.  The
frequency of upgrades is low enough that the cost of repopulating
the cache is reasonable.  This may also simplify locking changes in
the future (e.g. if extra data is needed in the LVB or new flags).

> 4. We can avoid reformatting requests during open replay if this is
>    also done explicity.

No, open replay is done by replaying the original open RPC, which is
kept indefinitely using the original transaction number.

> 5. This scheme prevents recovery on clients that were disconnected
>    when the upgrade began.  Such clients will simply be evicted when
>    they reconnect even though the server should actually have
>    committed all their replayable requests.
> 
>    If this can be prevented, we can probably also dispense with much
>    of the notification described in (2) above.  However it would
>    require (a) a change in the connection protocol to get clients to
>    purge their own replay queue and (b) changes to ensure resent
>    requests can be reconstructed from scratch (but maybe (b) is just
>    another way of saying "request reformatting").
> 
>    If this is doable - it further begs the question of whether simply
>    making all server requests synchronous during upgrades is enough to
>    simply most interoperation issues.
> 
> 6. This is all about client/server communications. Are there any
>    issues for inter-server interoperation?

The current 2.0 update does not change the MDS->OSS protocol in any
way (AFAIK).  Changes like CROW and FID-on-OST are not yet implemented.

> 7. Clients and servers may have to run with different versions for
>    extended periods (one customer ran like this for months).  Does
>    this raise any issues with this scheme?

I don't think so, because the need to interoperate for even a minute
is no different than a month, once the support is there.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
