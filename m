From: dzogin <Dmitri.Zoguine@Sun.COM>
Date: Wed, 06 Jan 2010 13:10:40 -0500
Subject: [Lustre-devel] SOM safety
In-Reply-To: <20100106172812.GO1516@Sun.COM>
References: <079601ca8e36$70c5f480$5251dd80$@com> <4B44C3D5.8060701@sun.com>
	<20100106172812.GO1516@Sun.COM>
Message-ID: <4B44D220.7070906@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nicolas Williams wrote:
> The health network will allow for eviction notices to be spread around
> the cluster quickly.
>
> I think we'll need a separate cluster membership capability for reasons
> having to do with optimizing the health network: if you see a peer C
> that's got a membership capability issued at time T_a and you're a
> server S_n that's been in the cluster since before T_a and you've not
> heard any eviction notices for C, then C is still a member of the
> cluster.  Without a cluster membership capability we'd need to ask the
> health network if C is a member, and while that can happen quickly, in a
> mostly-stateless health network (the current design) having every server
> ask about the membership/liveness status of every peer client could
> result in a load spike.
>   
I think this can be easily implemented as a bitmap on every server (both 
OSS and MDS) that keeps track of the alive and evicted clients. Once you 
have processed all the amount of work that needs to be done for the 
client that has been evicted, that bit in the evicted clients map is 
cleared. Instead of sending the information about every client, servers 
can exchange the bitmaps, and doing XOR on bitmaps would allow you to 
easily see the discrepancies in client evictions.

I think the same idea of bitmaps can be implemented for objects, if we 
want to track which client is updating the object/stripe.

Dmitry
