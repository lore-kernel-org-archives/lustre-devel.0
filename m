From: Eric Barton <eeb@sun.com>
Date: Fri, 10 Oct 2008 00:21:52 +0100
Subject: [Lustre-devel] Simplified Interoperation
In-Reply-To: <68D776E8-A7E1-45D5-8F06-C6A92418454C@sun.com>
References: <0EA267EF312B4BFA837511EFD41F4E6E@ebpc>
	<68D776E8-A7E1-45D5-8F06-C6A92418454C@sun.com>
Message-ID: <AF70C16AF3AF481287E4EBB781837B39@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> Thanks for summarizing this, comments inline.
> 
> > Description
> > At the start of a controlled shutdown, the server notifies all its  
> > connected clients that it is shutting down and refuses connection  
> > requests from new (but not currently connected) clients.
> >
> 
> Why refuse connections to new clients? Now that we are adding a  
> quiescent mode to the client, we can use that instead of failing new  
> mounts. (We could do the same thing when we receive new connection  
> during recovery, too, for that matter.)  I'd just hate to add another  
> source of mount failures when it seems we can avoid it.

Just to prevent new clients connecting to it as if it wasn't there at
all - it's about to go in any case and a new server is about to start
up in its place, which these clients should shortly succeed in
connecting to.

> > The clients prepare for shutdown by ensuring at a minimum that no  
> > further requests are sent to the server and they have cleaned and  
> > evicted all cached server state.
> >
> 
> Clients need to notify the server when they are finished flushing state.

Yes indeed - e.g. releasing the lock used for the shutdown notification
BAST.

> > The server notifies all clients when all outstanding requests have  
> > been committed.
> >
> There is already a mechanism in place for the server to notify the  
> clients of the last committed, so we don't need to add anything for  
> this. I'm not convinced the server needs to do anything here except  
> failover, but we could withhold the reply to the clients' "i'm done"  
> request mentioned above until the server is ready to shutdown. That  
> reply would have the current last committed and as a side-effect would  
> cause the clients to flush their replay queues. The same thing will  
> happen when the clients reconnect, though, so I'm not sure it's worth  
> adding another special reply.

I really want the replay queue to be empty when the client disconnects.

> > The clients may then disconnect and the server can halt when all  
> > clients have disconnected.
> >
> > When the server restarts, clients reconnect, replay open files and  
> > proceed.
> 
> If the clients disconnect right away, then they will have no way of  
> knowing when they need to reconnect. They need to remain connected and  
> continue pinging so they will detect when the server has failed and  
> recover normally.

What's the difference between remaining connected and pinging, and
disconnecting and attempting reconnection?

> One last thing - the clients need to know when it is safe to being  
> sending new requests again. Do we do this automatically after  
> recovery?  

Yes.

> Or is this an explicit operation done by the admin? 

No.

> Also,  
> the admin might decide the cancel the upgrade before failing the  
> server, so we'll need a way to resume normal operations without going  
> through recovery.

We're not actually failing the server - we're just doing an orderly
shutdown that guarantees to minimize client state and simplify recovery
on reconnection.  Nothing bad happens if the server reboots with the
same version - the client just does the same minimal recovery it would
do with a version-upped server.

    Cheers,
              Eric
