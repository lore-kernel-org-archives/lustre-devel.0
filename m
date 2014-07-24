From: Steve Wise <swise@opengridcomputing.com>
Date: Thu, 24 Jul 2014 10:13:50 -0500
Subject: [Lustre-devel] lustre-1.8.8: rdma_listen() backlog 0 breaks
	iWARP
In-Reply-To: <1828884A29C6694DAF28B7E6B8A823739935485C@ORSMSX110.amr.corp.intel.com>
References: <005801cfa68d$00d607e0$028217a0$@opengridcomputing.com>
	<CFF56046.B2EDD%andreas.dilger@intel.com>
	<001801cfa74a$ac57fde0$0507f9a0$@opengridcomputing.com>
	<1828884A29C6694DAF28B7E6B8A823739935485C@ORSMSX110.amr.corp.intel.com>
Message-ID: <002601cfa751$dfe01d30$9fa05790$@opengridcomputing.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > I'm not sure why it was changed to 0 though.  It definitely breaks iwarp
> > support.  I'm not
> > yet sure what the semantics are for creating a listening cm_id with a
> > backlog of 0.  Was
> > the assumption that 0 means "let the system choose" or "max supported
> > backlog"?  The iwarp
> > CM interprets 0 to mean no connection requests allowed. :)
> 
> 0 should mean let the system choose.  Interpreting 0 as no connections allowed doesn't
> really make sense, since the app can get that by not calling listen at all.

Ok then we can fix this in the iwcm.  I'll post a patch to Linux-rdma soon. 

Thanks,

Steve.
