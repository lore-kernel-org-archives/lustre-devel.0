From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 24 Dec 2008 13:32:51 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18768.56976.692985.84810@gargle.gargle.HOWL>
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
Message-ID: <49520FD3.6040007@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

Nikita Danilov wrote:
> So let's suppose we have four servers and three operations:
> 
>      S0   S1   S2   S3
> OP0  U1   U2
> OP1       U3   U4
> OP2            U5   U6
> 
> Where `U?' means that a given operation sent an update to a given
> server, and all updates happen to be conflicting.
> 
> Suppose that transaction groups with these updates commit at the same
> time and servers are ready to send information to each other. What
> information each server sends and where?

instead of digging right into details, let's agree about few simple statements
the idea is based on ?


(0) operation is globally committed if no operation it depends on can be aborted

(1) some external mechanism order operations and updates (e.g. LDLM, local locking, etc)

(2) if update U1 executed before update U2 and U2 is committed, then U1 must be committed

(3) requirement: if operation O2 depends on operation O1, then O1 has conflicting
     update on same server with O2

     example 1: mkdir /a; touch /a/b
      mkdir consists of two updates: U1 - create object on mds1, U2 - creates dir
      entry on mds2. touch consists of single update: U3 - to create object on mds1
      and directory entry in a on mds1. U1 and U3 will be conflicting as they touch
      same object

(4) operation is globally committed if all updates this operation consists of are
     committed and everything it depends on is committed as well

     explanation: say, operation O consists of two updates U1 (server S1) and U2
     (server S2). let's say U1 depends on Ua on server S1 and U2 depends on Ub on
     server S2. we stated that any update O can depend on are already executed due
     to (1). thus Ua is already executed and Ub is already executed as well. due to
     (2) commit of U1 means commit of Ua and commit of U2 means commit of Ub.

     thus direct dependency is resolved.

     if there is any indirect dependency, it's resolved same way due to (4)


In the example above, commit of U5 means commit of U4, same for U3 and U2. IOW,
when U3 and U4 are committed, then we can consider OP1 is globally committed
(won't be aborted).

any objections?


thanks, Alex
