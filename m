From: Robert Read <rread@sun.com>
Date: Thu, 09 Oct 2008 15:57:20 -0700
Subject: [Lustre-devel] Simplified Interoperation
In-Reply-To: <0EA267EF312B4BFA837511EFD41F4E6E@ebpc>
References: <0EA267EF312B4BFA837511EFD41F4E6E@ebpc>
Message-ID: <68D776E8-A7E1-45D5-8F06-C6A92418454C@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Thanks for summarizing this, comments inline.

> Description
> At the start of a controlled shutdown, the server notifies all its  
> connected clients that it is shutting down and refuses connection  
> requests from new (but not currently connected) clients.
>

Why refuse connections to new clients? Now that we are adding a  
quiescent mode to the client, we can use that instead of failing new  
mounts. (We could do the same thing when we receive new connection  
during recovery, too, for that matter.)  I'd just hate to add another  
source of mount failures when it seems we can avoid it.

> The clients prepare for shutdown by ensuring at a minimum that no  
> further requests are sent to the server and they have cleaned and  
> evicted all cached server state.
>

Clients need to notify the server when they are finished flushing state.

> The server notifies all clients when all outstanding requests have  
> been committed.
>
There is already a mechanism in place for the server to notify the  
clients of the last committed, so we don't need to add anything for  
this. I'm not convinced the server needs to do anything here except  
failover, but we could withhold the reply to the clients' "i'm done"  
request mentioned above until the server is ready to shutdown. That  
reply would have the current last committed and as a side-effect would  
cause the clients to flush their replay queues. The same thing will  
happen when the clients reconnect, though, so I'm not sure it's worth  
adding another special reply.

> The clients may then disconnect and the server can halt when all  
> clients have disconnected.
>
> When the server restarts, clients reconnect, replay open files and  
> proceed.
>


If the clients disconnect right away, then they will have no way of  
knowing when they need to reconnect. They need to remain connected and  
continue pinging so they will detect when the server has failed and  
recover normally.

One last thing - the clients need to know when it is safe to being  
sending new requests again. Do we do this automatically after  
recovery?  Or is this an explicit operation done by the admin? Also,  
the admin might decide the cancel the upgrade before failing the  
server, so we'll need a way to resume normal operations without going  
through recovery.

robert


On Oct 9, 2008, at 14:54 , Eric Barton wrote:

> Hi,
>
> I've written some notes on simplified interoperation which
> you can find at...
>
> http://arch.lustre.org/index.php?title=Simplified_Interoperation
>
>
>    Cheers,
>              Eric
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
