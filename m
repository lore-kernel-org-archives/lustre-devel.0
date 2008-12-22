From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 22 Dec 2008 20:36:32 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18767.52005.485425.412677@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
Message-ID: <494FD020.70909@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
>  > well, I think it does as you don't want to use epoch received few minutes ago with lock.
> 
> What is the problem with this?

the problem is that this epoch may hold lots of other epochs? this may be especially
important for fsync(2) or any synchronous request.

> Any IO mechanism has to guarantee that operations are "serializable",
> that is, no circular dependencies exist. This is what global epochs
> need, they don't depend on DLM per se.

global epochs depend on DLM as a transport to refresh epochs. at least the idea, AFAIU,
is to use LDLM RPC to carry epoch protocol. otherwise it'd need separate RPC. I'm just
saying that there are case, probably important, when such explicit RPC will be needed,
probably in nearly-sync manner. I think this is also additional complexity.

>  > the problem is that with out-of-order epochs sent to different servers client can't
>  > use notion of "last_committed" anymore.
> 
> What do you mean by "out of order" here?

epoch N+1 can be committed by mds1 before epoch N is committed by mds2. each such
epoch is to be tracked separately and "last_committed" can't be used I think.
additional complexity in the protocol.

>  > the bad think, IMHO, in all this is that all nodes making decision must
>  > understand topology. server should separate epochs from different clients,
>  > it's hard to send batches via some intermediate server/node.
> 
> Hm.. I would think that this is very easy, thanks to the good properties
> of the minimum function (associativity, commutativity, etc.): client
> piggy-backs its earliest volatile epoch to any message it sends to any
> server, and server batches these data from clients and forwards them to
> SC.

1) if epoch isn't bound to some node, then it's also can be hard to push epochs
    to implement fsync(2)
2) batching means additional delay

> I agree with this, but I am not sure this is a problem. If client is
> idle for seconds, pinging is not a big deal.

I tend to think ping can be a problem at proper scale. I wouldn't rely on this.

> Presicely the contrary: MIN_VOLATILE message returns something
> equivalent to the cluster-wide global last_committed.

you meant "from sc" direction. but before that client has to track local committness
of each epoch to servers.

thanks, Alex
