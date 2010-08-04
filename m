From: Ben Evans <Ben.Evans@terascala.com>
Date: Wed, 4 Aug 2010 11:39:24 -0400
Subject: [Lustre-devel] Lnet routing preferences
In-Reply-To: <43C8BB69-F815-47AD-80D5-028D44098EF7@llnl.gov>
References: <2C7DE72B9BD00F44BAECA5B0CBB87395C3F4A6@hermes.terascala.com>
	<007b01cb3396$3ae07290$b0a157b0$@com>
	<43C8BB69-F815-47AD-80D5-028D44098EF7@llnl.gov>
Message-ID: <2C7DE72B9BD00F44BAECA5B0CBB87395CD80B0@hermes.terascala.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes, this is exactly what I'm looking at.  From the hints that Eric
provided, and from my digging, it looks like there is a quick check to
see which connection has the shortest queue (along with the number of
hops and a few other things) and uses that one.  If they're equal it
prefers the first connection in the list.

-----Original Message-----
From: D. Marc Stearman [mailto:marc at llnl.gov] 
Sent: Wednesday, August 04, 2010 11:25 AM
To: Eric Barton
Cc: Ben Evans; 'lustre-devel'
Subject: Re: [Lustre-devel] Lnet routing preferences

I think what Ben is trying to say is something like this:

You have a small gigabit management network for your server cluster,  
say tcp0 that would be used just for server to server communication.   
ie precreate requests from the MDS to the OSS nodes.  You want all of  
your clients to mount and pass data over your o2ib0 network.   
Presumably you create your file system with NIDs on both tcp0 and  
o2ib0.  Clients would mount using mdsnid at o2ib0:/fsname which would  
force the client traffic to use the IB network since that is all they  
are connected to.  How does LNET decide which network, tcp0 or o2ib0,  
to communicate for server traffic.  My understanding is that  
connections will be setup on both networks since the servers have NIDS  
on both, so does LNET use the local network with the shortest queue,  
or does it round robin between them?

-Marc

----
D. Marc Stearman
Lustre Operations Lead
marc at llnl.gov
925.423.9670
Pager: 1.888.203.0641




On Aug 3, 2010, at 10:30 PM, Eric Barton wrote:

> Ben,
>
>> From: lustre-devel-bounces at lists.lustre.org
[mailto:lustre-devel-bounces at lists.lustre.org 
>> ] On Behalf Of Ben Evans
>> Sent: 27 July 2010 11:04 AM
>>
>> I've been poking around and experimenting with the luster internals
>> on my own, and ran into a question that I haven't been able to track
>> down.
>>
>
>> For MDS/OSS communications, where there are multiple possible paths
>> (Ethernet, IB, etc.) how does LNET (or Lustre) decide which
>> interface to send messages?
>
> First a bit of explanation...
>
> LNET node addressing is driven by the idea that since an arbitrary
> network topology requires O(n**2) routing tables, it would be good to
> limit the 'n' as much as possible :-)
>
> When Peter Braam and I were discussing how to finesse this issue in
> early implementations of LNET routing, we observed that since Lustre
> is a cluster file system spanning compute clusters, storage clusters
> and mixtures of both, a 2-level addressing scheme which assumes flat
> connectivity within clusters but arbitrary connectivity between
> clusters, limits the 'n' to the number of clusters rather than the
> total number of nodes.  That's why an LNET NID is the concatenation of
> the network and the node-within-network.
>
> Now to your question...
>
> When LNET routes a message, it first checks whether the destination
> NID is in a local network.  If so, it passes the message to the local
> interface on that network.
>
> If the destination is not local, LNET looks up the destination network
> in its route table.  The route table lists all the NIDs of LNET
> routers on local networks that could forward the message to its
> eventual destination with a minimum number of hops.  LNET then chooses
> the router with the shortest queue.
>
>> Ideally, I'd like to send server-to-server messages over a private
>> network and let the clients communicate over the public network
>
> Note that the choice of destination NID is in itself a routing
> decision if there are potentially several to choose from.  For
> example, if I have NIDs x1 at o2ib0 and y1 at tcp0 and you have NIDs
> x2 at 02ib0 and y2 at o2ib0, then whether communications between us are
> routed over o2ib0 or tcp0 is completely determined by the choice of
> NID handed to LNET, not by LNET itself.
>
> So if you want to communicate over a server-only network, you just
> need to use server-only NIDs.
>
> Note however that this requirement may conflict with the desire to do
> link aggregation for performance/failover.  We've been considering
> using NIDs in a way which is much more like conventional IP networks -
> i.e. where the upper levels can specify any destination NID and LNET
> takes a bigger part in the decision about which network to use.
>
> Isaac Huang has been thinking about link aggregation for a while and
> may care to comment on whether he has considered private networks like
> this.
>
>> I'm interested in finding out if there are any gains to be made from
>> a setup like this.
>
> Yes, you could benefit from avoiding any congestion created by client
> communications.
>
> But I must ask - what is it that you want to communicate between
> servers like this and are you sure you're not introducing a scaling or
> deadlock issue?
>
>                Cheers,
>                        Eric
>
> Eric Barton
> CTO Whamcloud Inc.
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://*lists.lustre.org/mailman/listinfo/lustre-devel
>
