From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 22 Dec 2008 17:21:26 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
 long and dry].
In-Reply-To: <200812221648.19278.alexander.zarochentsev@sun.com>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<200812221648.19278.alexander.zarochentsev@sun.com>
Message-ID: <18767.41574.948255.718042@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alexander Zarochentsev writes:
 > On 22 December 2008 15:45:51 Nikita Danilov wrote:
 > > Alex Zhuravlev writes:
 > >  > Hello,
 > >
 > >  > I'm not sure it scales well as any failed node may cause global
 > >  > stuck in undo/redo pruning.
 > >
 > > Only until this node is evicted, and I think that no matter what is
 > > the pattern of failures, a single level of `tree reduction', can be
 > > delayed by no more than a single eviction timeout.
 > 
 > It introduces unneeded dependency between nodes, any node cannot prune 
 > its own undo logs if all nodes have an agreement that the epoch can be 
 > pruned. IMO it is what scalable system should avoid. 

This is a price paid for the cheap introduction of new epochs. If epoch
scope is limited to a known group of nodes, then retiring such an epoch
requires consensus only between nodes of this group (cheaper than a
global consensus), but introduction of new epochs requires coordination
between groups. In various designs that we considered where epochs are
per-client this manifests itself as an absence of total ordering between
epochs that requires translation between client epochs and server
transaction identifiers.

All in all, I have a feeling that _all_ such algorithms have similar
communication overhead for the `usual' workload.

 > 
 > If we would have a disaster in a part of the cluster, client nodes would 
 > disconnect and reconnect often, the undo logs will be overloaded, and 
 > the cluster will stop, no?

Well it won't stop, because a node either manages to reconnect in time
(in which case it communicates its state to the superior), or it is
evicted on a timeout. In any case, stabilization algorithm progresses.

Then, I think that even the simplest global epoch based recovery is very
challenging to implement.

 > 
 > Thanks,
 > -- 
 > Alexander "Zam" Zarochentsev

Nikita.
