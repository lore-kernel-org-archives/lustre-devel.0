From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 23 Dec 2008 09:44:27 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18767.58149.550264.505562@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com> <18767.58149.550264.505562@gargle.gargle.HOWL>
Message-ID: <495088CB.5070506@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> Any message is used as a transport for epochs, including any reply
> from a server. So a typical scenario would be

I agree, but I think there will be cases with no messages at all.
like WBC doing flush every few minutes and then going idle. depending
on workload this may introduce additional network overhead on any node.

> etc. Note, that nothing prevents server from increasing its local epoch
> before replying to every reintegration (this was mentioned in the
> original document as an "extreme case"). With this policy there is never
> more than one reintegration on a given client in a given epoch, and we
> can indeed implement stability algorithm without clients.

hmm? if it's client only who're aware of parts of distributed transaction,
how can we?


> DLM plays no special role in the epochs mechanism. All that it is used
> for is to guarantee that conflicting operations are executed in the
> proper order (i.e., an epoch of dependent operation is never less than
> an epoch of an operation it depends on), but this is what DLM is for,
> and this has be guaranteed anyway.

conflict resolution can be delegated to some different mechanism when STL takes place.

> last_committed can be and have to be used. When a client reintegrated
> operation OP = (U(0), ..., U(N)), it counts this operation as `volatile'
> until all N servers reported (through the usual last_committed
> mechanism, as it is used by Lustre currently) that all updates have
> committed.

yup. at some point I got to think you're going to use epochs instead of transno
in last_committed, which could be a problem.


just to list my observations about global epochs:
  * it's a problem to implement synchronous operations
  * network overhead even with local-only changes depending on workload
  * disk overhead even with local-only changes
  * SC is a single point of failure with any topology as it's the only place to
    find final minimum
  * tree reduction isn't obvious thing because client can't report its minimum
    to any node, instead tree is rather static thing and any change should be
    done very carefully. otherwise it's very easy to lose minimum



thanks, Alex
