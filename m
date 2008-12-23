From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 23 Dec 2008 14:31:36 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18768.50762.865900.238376@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com> <18767.58149.550264.505562@gargle.gargle.HOWL>
	<495088CB.5070506@sun.com>
	<18768.46808.716111.644627@gargle.gargle.HOWL>
	<4950BBBD.4030405@sun.com>
	<18768.50762.865900.238376@gargle.gargle.HOWL>
Message-ID: <4950CC18.1090005@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> We are talking about few megabytes of data in network or in memory. It's
> easy to replicate this state.

I disagree - whole state can be distributed over 100K and more nodes and
some operations many need all nodes to communicate their state. this is
especially problem with lossy network.

> Again, global epochs do not depend on DLM to propagate epochs. E.g.,
> lockless IO can be implemented without any additional rpcs.

sorry, I said nothing about DLM. I said "additional RPC", which is required
in some cases. ping, for example, can issue RPC once per 60s. more over,
ping also can use tree or some different topology making epoch refresh more
complex.

> Tree reduction is but an optimization. I am pretty convinced that core
> algorithm works, because this can be proved.

sorry, works doesn't always mean "meet requirements". in our case scalability
is the top one. in this regard I don't see how this model can work well with
synchronous operations. at same time it was stated that we have to support
such operations well, e.g. for nfs exports. I also tried to point out onto
few overheads in the algorithm.

>>   * once some distributed transaction is committed on all involved servers, we can prune
>>     it and all its local successors
> 
> Either I am misunderstanding this, or this is not correct, because not
> only a given operation, but also all operations it depends on have to be
> committed, and it is not clear how this is determined.

the algorithm works starting from oldest operations and discards them when there is no
undo before this one.

> One reason I wrote so lengthy a text was that I want to spell out
> everything explicitly and unambiguously (and obviously failed in the
> latter, as ensued discussion has shown).

yes, it's well written and proven thing. the point is different - if it's clear that
in some cases it doesn't work well (see sync requirement), what the proof does?

thanks, Alex
