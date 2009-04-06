From: di wang <di.wang@sun.com>
Date: Mon, 06 Apr 2009 18:02:14 -0400
Subject: [Lustre-devel] [RFC] two ideas for Meta Data Write Back Cache
In-Reply-To: <m3zleu5b8f.fsf@bzzz.home.net>
References: <200904061339.02850.alexander.zarochentsev@sun.com>
	<20090406100345.GO3199@webber.adilger.int>
	<m3zleu5b8f.fsf@bzzz.home.net>
Message-ID: <49DA7BE6.6070006@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> 2) "create w/o name" (this is what MDT accepts these days) isn't operation,
>    it's partial operation. but for partial operations we already have OSD
>    - clear, simple and generic. having one more "partial operations" adds
>    nothing besides confusion, IMHO
>   
I am not sure you can( or should) translate all the MD partial 
operation  into object  RPC for these partial
MD operation.  For example rename,  (a/b  ---> c/d,  a/b in MDS1, c/d in 
MDS2).

     RPC goes to MDS1.

     1) delete d (entry and object) from c in MDS2.
     2) create b entry under c in MDS2.
     3) delete b entry under a in MDS1.

So if you do 1) and 2) by object rpc (skip mdd), then you might need 
create create all 4 objects
(a and b are local object, c and d are remote object),  and permission 
check locally (whether
you can delete d under c). Not sure it is a good way.  And also some 
quota stuff are handled
in these partial operation in remote MDD, so I am not sure we should 
skip mdd totally here.
Am I miss sth?

Thanks
WangDi
