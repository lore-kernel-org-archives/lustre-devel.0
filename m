From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 23 Dec 2008 13:21:49 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18768.46808.716111.644627@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com> <18767.58149.550264.505562@gargle.gargle.HOWL>
	<495088CB.5070506@sun.com>
	<18768.46808.716111.644627@gargle.gargle.HOWL>
Message-ID: <4950BBBD.4030405@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> If we have no more than 1 reintegration in a given epoch on a given
> client, then the server that received an OP = (U(0), ..., U(N)) in epoch
> E from a client, can send to SC a message telling it that this client
> contains N volatile updates in epoch E, and whenever some server commits
> one of U's it sends to SC a message asking it to decrease a counter for
> this client. Most obvious implementation will batch these notification,
> i.e., when a server commits a transaction group it notifies SC about all
> changes in one message. I personally don't think that is the best
> approach.

essentially this is very similar to dependency-based recovery, but with
no it's advantages and with SC tracking all states and being single point
of failure. I think we need more scalable solution.

> Yes, and this mechanism (if it is correct at all) will guarantee that an
> epoch cannot depend on a future epoch.

again, it's not about dependency, it's about network overhead of global epochs.

>  > just to list my observations about global epochs:
>  >   * it's a problem to implement synchronous operations
>  >   * network overhead even with local-only changes depending on workload
>  >   * disk overhead even with local-only changes
>  >   * SC is a single point of failure with any topology as it's the only place to
>  >     find final minimum
>  >   * tree reduction isn't obvious thing because client can't report its minimum
>  >     to any node, instead tree is rather static thing and any change should be
>  >     done very carefully. otherwise it's very easy to lose minimum
> 
> Unfortunately, as far as I know, no other solution was described with a
> level of detail sufficient to compare. :-)

I could say the same about tree reduction, for example ;)

dependency-based recovery was discussed with many details I think. and benefits are
very clear, IMHO. as well as overall simplicity due to local implementation (compared
with implementation involving all nodes in a cluster).

thanks, Alex
