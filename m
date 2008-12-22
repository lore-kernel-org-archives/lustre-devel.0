From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Mon, 22 Dec 2008 16:48:18 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
 long and dry].
In-Reply-To: <18767.35839.133024.625896@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
Message-ID: <200812221648.19278.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 22 December 2008 15:45:51 Nikita Danilov wrote:
> Alex Zhuravlev writes:
>  > Hello,
>
>  > I'm not sure it scales well as any failed node may cause global
>  > stuck in undo/redo pruning.
>
> Only until this node is evicted, and I think that no matter what is
> the pattern of failures, a single level of `tree reduction', can be
> delayed by no more than a single eviction timeout.

It introduces unneeded dependency between nodes, any node cannot prune 
its own undo logs if all nodes have an agreement that the epoch can be 
pruned. IMO it is what scalable system should avoid. 

If we would have a disaster in a part of the cluster, client nodes would 
disconnect and reconnect often, the undo logs will be overloaded, and 
the cluster will stop, no?

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
