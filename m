From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Wed, 6 Jan 2010 11:28:13 -0600
Subject: [Lustre-devel] SOM safety
In-Reply-To: <4B44C3D5.8060701@sun.com>
References: <079601ca8e36$70c5f480$5251dd80$@com> <4B44C3D5.8060701@sun.com>
Message-ID: <20100106172812.GO1516@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jan 06, 2010 at 12:09:41PM -0500, Aleksandr Guzovskiy wrote:
> Eric Barton wrote:
> > 2. OST eviction
> > 
> >    An alternative to timeouts is to evict clients from the OSTs when
> >    they are evicted from the MDS.
> 
> This would be a step towards adding a notion of cluster membership to 
> Lustre. Wouldn't there be other benefits from that in solving other 
> races when client is evicted from one of the servers but is not evicted 
> from others?

The health network will allow for eviction notices to be spread around
the cluster quickly.

I think we'll need a separate cluster membership capability for reasons
having to do with optimizing the health network: if you see a peer C
that's got a membership capability issued at time T_a and you're a
server S_n that's been in the cluster since before T_a and you've not
heard any eviction notices for C, then C is still a member of the
cluster.  Without a cluster membership capability we'd need to ask the
health network if C is a member, and while that can happen quickly, in a
mostly-stateless health network (the current design) having every server
ask about the membership/liveness status of every peer client could
result in a load spike.

Nico
-- 
