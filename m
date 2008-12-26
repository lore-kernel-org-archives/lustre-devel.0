From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 26 Dec 2008 12:01:43 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18770.7925.787506.291696@gargle.gargle.HOWL>
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
	<4950CC18.1090005@sun.com>
	<18768.56976.692985.84810@gargle.gargle.HOWL>
	<49520FD3.6040007@sun.com>
	<18770.7925.787506.291696@gargle.gargle.HOWL>
Message-ID: <49549D77.509@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> ... and all updates of the operation itself are committed on the
> respective servers.

yes

>  > (2) if update U1 executed before update U2 and U2 is committed, then U1 must be committed
> 
> I think this is only valid when U1 and U2 are on the same server. And
> even in this case this is probably required only when U1 and U2 are
> conflicting.

agree about same server. i think this is model used by ext3 and DMU.

>  > (3) requirement: if operation O2 depends on operation O1, then O1 has conflicting
>  >      update on same server with O2
> 
> Agree, provided that `depends' means `directly depends', i.e., not
> through some intermediate operation.

yes

>  > (4) operation is globally committed if all updates this operation consists of are
>  >      committed and everything it depends on is committed as well
> 
> I think this is wrong. Everything it depends on must be _globally_
> (recursively) committed as well. Otherwise in the following scenario

OK
additional clarification: "all updates this operation consists of are globally committed"

> As a note, I tried very hard to avoid confusion by using different
> terms: operations (a distributed state update) vs. transaction (a group
> of updates on a given server that reaches persistent storage
> atomically), and `stabilizes' vs. `commits' respectively.
> 

I like the terms.

> Err.. what if U3 and U4 are committed on S1 and S2, but S0 hasn't
> received U1 at all (e.g., U1 is an inode creation, that was executed
> without a lock and client failed), or U1 was executed, but not committed
> and S0 failed? It seems that OP0 will have to be rolled back, and hence
> OP1 and OP2 cannot be considered globally committed^W^Weverywhere
> stable?

with fixed definition i think it's correct.

> I was more interested in how batching is implemented and, specifically,
> at what moment server can actually remove at entry from an undo log
> (i.e., before or after it sends a batch, etc.), because it looks to me
> that server agreement on what operations are everywhere stable requires,
> in a general case, a two phase commit, or some other atomic commitment
> protocol.

then a bit more words.

I think the following statement is still true: when any operation is being
executed (updates are being executed on target servers), all updates it
depends on are already executed. let's fix server's state at time our updates
begin to execute: S1 is a state on server 1, S2 is a state on server 2,,,,
Sn is a state on server N. due to (2) once all states S1..Sn are committed,
all dependency our updates might have are resolved and they can't be aborted
due to abort of some previous operation.

in practice this mean that having series of updates on some server:
U1, U2, U3, U4,,,,, Un, Un+1 we can choose some N, ask all servers for their
last generated transno (not last committed transno) and assign set of transno
to point N. once all servers have reported corresponded transno committed,
we know that all dependency updates U1..Un might have are resolved and U1..Un
can't be aborted.  (5)

of course, this is true only for operations with number of updates = 1 (iirc,
we call them local operations in contrast with distributed where number of
updates > 1). for distributed operations we also need to make sure all updates
are committed.

when some server commits update and corresponded operation has 2 or more updates,
then server reports this to other servers involved in the operation. in practice,
server doesn't report immediately, instead it put transaction id into some batch
(batches) which will be fired later.  (6)

now back to series updates on server: U1, U2, U3, U4,,,, Un, Un+1. in general,
each update has own undo record in the log. record for any local update at the
beginning of the series can be cancelled once corresponded update is locally
committed. record for any distributed operation's update can be removed from the
series so that it doesn't hold remaining records, but not cancelled.

In order to cancel undo record for a distributed operation we need to make sure
that during recovery none of undo record of this operation can be used, otherwise
recovery can be confused finding record on one server, but not on another one.

this can be done with llog-like protocol: for any distributed operation, server
with minimal id cancel own undo record and generates another record M marking
operation globally committed. then server notifies other servers involved in the
operation, their cancel own undo records, once cancels are committed, record M
can be cancelled.  (7)


now let's consider that example:

      S0   S1   S2   S3
OP0  U1   U2
OP1       U3   U4
OP2            U5   U6

le's redraw it a bit ....

undo series of S0:  U1
undo series of S1:  U2  U3
undo series of S2:      U4  U5
undo series of S3:          U6


S0 reports committness of U1 in transno T01 (OP1) to S1, now S1 knows U2 depends on S0/T01
S1 reports committness of U2 in transno T11 (OP1) to S0, now S0 knows U1 depends on S1/T11
S1 reports committness of U3 in transno T12 (OP2) to S2, now S2 knows U4 depends on S1/T12
S2 reports committness of U4 in transno T21 (OP2) to S1, now S1 knows U3 depends on S2/T21
S2 reports committness of U5 in transno T22 (OP3) to S3, now S3 knows U6 depends on S2/T22
S3 reports committness of U6 in transno T31 (OP3) to S2, now S2 knows U5 depends on S3/T31

now each server knows direct dependency. then all them have to resolve global dependency:
S0 requests current state from S1,S2,S3 - they return last generated transno
S1 requests current state from S0,S2,S3 --//--
S2 requests current state from S0,S1,S3 --//--
S3 requests current state from S0,S1,S2 --//--

at some point all servers report collected transno committed. given all updates belong to
distributed transactions, servers can remove them from series so that they don't hold
dependency for anyone, but not cancel. as noted in (7) we can use llog-like protocol to
cancel undo records for distributed operations. as they don't block any operation we can
postpone cancel for very long to improve bandwidth usage.


I think this *oversimplified* approach demonstrates that we can do "stabilization" with
anywhere-generated-id operations.

messages reporting committness can be batched. we can even use bi-directional protocol
when S0 reporting committness of U1 to S1 gets a reply claiming committness of U2 back.

any message can carry "last generated transno" along with "last committed", making
"request current state" not needed.

One of important advantages such approach has is ability to implement fsync(2)
more optimal way, without involving whole cluster.

The simplest optimization could be to omit requests for other server's state
(see (5)) and undo records, for all local operations if there is undo log is
empty. so, as long as server doesn't execute global operations all local
operations are executed with zero "epoch overhead", like today.

More advanced approach could include propagation of involved servers when they
exchange committness of distributed operations (see (6)). Say, if server S1
has no other distributed operations (thus doesn't depend on other servers), then
reporting commit of update U1 (part of operation O1) to server S2 it tells
dependency of itself on S1,S2. when S2 reports committness of some other operation
O2 to server S3, it tells dependency on S1,S2. now, when S3 resolves global
dependency (see (5)), it doesn't requests state from all the servers, but only
from S1 and S2. We can go further even and include last generated transno along
with server into report. Then other servers don't need to request states even,
just wait till servers have those transno committed.

even more advanced approach could be to track precise dependency for any operation.
this is not very useful for ldiskfs as fsync(2) flushes all pending updates, but
with DMU we could use zlog and flush only really required bits.


thanks, Alex
