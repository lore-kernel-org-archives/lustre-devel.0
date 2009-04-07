From: Alex Zhuravlev <bzzz@sun.com>
Date: Tue, 07 Apr 2009 08:27:05 +0400
Subject: [Lustre-devel] [RFC] two ideas for Meta Data Write Back Cache
In-Reply-To: <49DA7BE6.6070006@sun.com>
References: <200904061339.02850.alexander.zarochentsev@sun.com>
	<20090406100345.GO3199@webber.adilger.int>
	<m3zleu5b8f.fsf@bzzz.home.net> <49DA7BE6.6070006@sun.com>
Message-ID: <m3y6ud3x7q.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> di wang (dw) writes:

 dw> I am not sure you can( or should) translate all the MD partial 
 dw> operation  into object  RPC for these partial
 dw> MD operation.  For example rename,  (a/b  ---> c/d,  a/b in MDS1, c/d in 
 dw> MDS2).

 dw>      RPC goes to MDS1.

 dw>      1) delete d (entry and object) from c in MDS2.
 dw>      2) create b entry under c in MDS2.
 dw>      3) delete b entry under a in MDS1.

 dw> So if you do 1) and 2) by object rpc (skip mdd), then you might need 
 dw> create create all 4 objects
 dw> (a and b are local object, c and d are remote object),  and permission 
 dw> check locally (whether
 dw> you can delete d under c). Not sure it is a good way.  

sorry, I don't quite understand what you mean. for this rename you'd need to:

if you're worried about additional RPCs, then we can (should) optimize this
with intents-like mechanism: mdd_rename() (or caller initialize intent
describing rename in terms of fids and names), then network-aware layer
(something like current MDC accepting OSD API) can put additional osd calls
into enqueue RPC.

for example, when it finds enqueue on c, it can form compound RPC consisting
of: enqueue itself, osd's attr_get(c), osd's lookup(c, d)

also notice, for such rename you need to check that you won't create
disconnected subtree, which is much worse than just few additional RPCs.

 dw> And also some quota stuff are handled
 dw> in these partial operation in remote MDD, so I am not sure we should 
 dw> skip mdd totally here.
 dw> Am I miss sth?

can you explain why do we need MDD on a server for quota?

given we're about to use OSD for data and metadata I'd think that:
1) for chown/chgrp MDD (wherever it runs) finds LOV EA and uses epoch
   (for example) to change uid/gid on MDS and all OSTs in atomical manner
2) quota code isn't part of data or metadata stack, rather it's side
   service like ldlm
3) quota code register hooks (or probably adds very small module right
   above OSD) to see all quota-related activity: attr_set, write,
   index insert, etc

also I think we still don't have proper design for quota, this is yet to be
done to implement quota for DMU.


thanks, Alex
