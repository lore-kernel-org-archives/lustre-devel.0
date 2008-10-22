From: Andreas Dilger <adilger@sun.com>
Date: Wed, 22 Oct 2008 11:21:40 -0600
Subject: [Lustre-devel] Simpifying Interoperation
In-Reply-To: <48FEBDA6.4070200@sun.com>
References: <CF0D4EA95C1945F18F74426BB95008CE@ebpc> <48FEBDA6.4070200@sun.com>
Message-ID: <20081022172139.GI3184@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 22, 2008  13:44 +0800, Huang Hua wrote:
> 1. I have implemented a "Barrier" on client, (by a read write semaphore,
> but Andreas suggests to use mutex).
> Before upgrade the MDS/OSS, we setup barrier on all clients, stopping
> new requests being sent to MDS and OSS.
> Currently, this will be done manually, e.g. run a command on all clients
> to barrier them.
> And then, user can explicitly sync lustre from clients, MDS and OSS, to
> insure that no outstanding requests are there.

I don't think that "sync" will cause existing RPCs to be sent.  Not a bad
idea, but I don't think it is implemented.

> And then, cancel all mdc and osc locks on clients manually. Maybe this
> step is optional. I will do more testing.
> 
> 2. User can upgrade MDS now. In this step, we need to "tunefs.lustre
> --write_conf" to erase all configuration, because these
> configuration can not be recognized by 2.0 MDS.

Can you explain why this is necessary?  Is this only for the MDT and OST
configurations, or the client configuration also?  The only change I was
aware of with the configuration log was for sptlrpc and that has been
fixed by Eric Mei to use a separate log.  Rewriting the client config
log while the clients are mounted would cause problems later on the client.

> 3. User has to upgrade OSS, or restart OSS to re-generate the configuration.
> Both are OK.

I didn't think the configured devices on the OSS were changed (e.g. OSD
is not yet in use), so what is the reason to rewrite the config there?

> 4. After that, we can cleanup the barrier on client manually. Client
> will reconnect to server, recover, and continue to run seamlessly.
> 
> 
> The problems here is that we have to setup and cleanup barrier on all
> clients by hand.
> Ideally, we should do it on a MDS/MGS by DLM lock, or something similar.
> If this is strongly required, I will implement this later.

In some customer configurations there is no easy mechanism for running
e.g. pdsh on all of the clients in advance of the upgrade.

> Till now, preliminary upgrade/downgrade tests passed. More testing are
> underway.
> 
> I will answer some of your questions inlinely. Please see the followings.
> 
> 
> 
> 
> Eric Barton wrote:
> > Here are some first thoughts on Huang Hua's idea to simplify version
> > interoperation, and an invitation for further comments...
> >
> > 1. This scheme should not interfere with upgrade via failover pairs,
> >    and it must also allow the MDS to be upgraded separately from the
> >    OSSs.  I think this means in general that we have to allow
> >    piecemeal server upgrades.
> >
> > 2. This scheme need a mechanism that...
> >
> >    a) notifies clients when a particular server is about to upgrade so
> >       that update operations are blocked until the upgrade completes
> >       and the client reconnects to the upgraded (and/or failed over)
> >       server.
> >   
> Now, this notification is done on every client, manually, by a command.
> 
> >    b) notifies the server when all clients have completed preparation
> >       for the upgrade so that no further requests require resend.
>
> This is done when barriers have been setup on all clients, and sync have
> been run on clients.

Even with the current manual operation, the MDS itself doesn't know when
the clients have all been updated.  There should be some mechanism by
which the MDS knows for sure that the clients have done their barrier,
and clients which have not responded should be evicted.

This is easily done by having a DLM read lock that all clients hold all of
the time.  It should not be put on the LRU, and the only reason it should
conflict is if the server is doing a shutdown.  The server would revoke
that lock (by enqueueing a conflicting lock) and then setting a local
flag which ensures that no more RPCs will be processed by the server.

> >    c) notifies clients when all outstanding updates have been
> >       committed.  If the server crashes before this point, client
> >       replay is still required.  Clients must not poll for this since
> >       the server is shutting down.
> >
> >    The DLM seems the right basic mechanism to notify clients, however
> >    current assumptions about acquisition timeouts might be an issue.
> >
> >    We must also ensure that the race between this server upgrade
> >    process and connection establishment (including any new
> >    notification locks) by new clients is handled consistently.
> >   
> I think these races should be avoided by user.
> 
> 
> >    
> > 3. It's not clear to me that we need to evict, or even clean the
> >    client cache provided the client doesn't attempt any more writes
> >    until it has connected to the failover server. 
> While upgrade, we do not need to evict the clients.
> but, in downgrade, we have to evict clients, because
> the 1.8 mds server does not understand FIDs, it only knows inode number.
> But while 1.8 client is talking to 2.0 MDS, they talk in FIDs, and know
> nothing about real inode numbers.

Yes, this is to be expected, and in that case the server should be
unmounted with "-f" or recovery aborted when 1.8 is restarted.

> >  The client can
> >    re-acquire all the locks covering its cache during recovery after
> >    the upgrade - and there is no need for request refomatting here
> >    since locks are replayed explicitly (i.e. new requests are
> >    formatted from scratch using the correct protocol version).
> >
> >    It does seem advisable however to clean the cache before such a
> >    significant system incident.
> >
> > 4. We can avoid reformatting requests during open replay if this is
> >    also done explicity.
> >   
> while upgrading, the client will do open replay.
> The server has already committed this open.
> So, 2.0 MDS only need to "open" that file, and return handle back to client.

Does the 2.0 MDS have support for handling the 1.8 MDS RPC open request
format?

> > 5. This scheme prevents recovery on clients that were disconnected
> >    when the upgrade began.  Such clients will simply be evicted when
> >    they reconnect even though the server should actually have
> >    committed all their replayable requests.
> >
> >    If this can be prevented, we can probably also dispense with much
> >    of the notification described in (2) above.  However it would
> >    require (a) a change in the connection protocol to get clients to
> >    purge their own replay queue and (b) changes to ensure resent
> >    requests can be reconstructed from scratch (but maybe (b) is just
> >    another way of saying "request reformatting").
> >
> >    If this is doable - it further begs the question of whether simply
> >    making all server requests synchronous during upgrades is enough to
> >    simply most interoperation issues.
> >
> > 6. This is all about client/server communications. Are there any
> >    issues for inter-server interoperation?
> 
> The protocol for mds-oss does not change much.
> As I tested, there is no inter-server interop issues.
> 
> > 7. Clients and servers may have to run with different versions for
> >    extended periods (one customer ran like this for months).  Does
> >    this raise any issues with this scheme?
>
> I do not see any issues.
> More testing is needed.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
