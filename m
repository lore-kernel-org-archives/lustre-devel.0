From: Steve Wise <swise@opengridcomputing.com>
Date: Thu, 24 Jul 2014 09:22:17 -0500
Subject: [Lustre-devel] lustre-1.8.8: rdma_listen() backlog 0 breaks
	iWARP
In-Reply-To: <CFF56046.B2EDD%andreas.dilger@intel.com>
References: <005801cfa68d$00d607e0$028217a0$@opengridcomputing.com>
	<CFF56046.B2EDD%andreas.dilger@intel.com>
Message-ID: <001801cfa74a$ac57fde0$0507f9a0$@opengridcomputing.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> >Hello,
> >
> >I'm trying to get lustre-1.8.8/RHEL6 running over Chelsio iWARP RNICs and
> >connection setup
> >is failing at the server due to kiblnd_startup() calling rdma_listen()
> >with a backlog of
> >0.  This effectively rejects all incoming connection requests.   I looked
> >at lustre-1.8.7,
> >and the backlog was 256 in that release.
> >
> >Q:  Why was it changed to 0?
> 
> Since I'm not familiar with the LNET code myself, I'd recommend to check
> the
> commit messages in Git to see if there is an explanation, or in the linked
> Jira/Bugzilla ticket.
> 
> You may also want to see if this is fixed with the 1.8.9 release.
> 

+ sean hefty
+ Isaac Huang

This commit changed the backlog to 0:

commit 7b442f1a43714455fad06c527b6fbc10f82af857
Author: Isaac Huang <he.h.huang@oracle.com>
Date:   Wed Nov 17 07:14:46 2010 -0700

    b=20153 add IB bonding failover support to o2iblnd

    O2iblnd changes to support failover events from an IB
    bonding IPoIB interface. Mostly to recreate device
    specific resources, e.g. listener CMID.

    i=isaac
    i=liang

Bug: https://projectlava.xyratex.com/show_bug.cgi?id=20153

I'm not sure why it was changed to 0 though.  It definitely breaks iwarp support.  I'm not
yet sure what the semantics are for creating a listening cm_id with a backlog of 0.  Was
the assumption that 0 means "let the system choose" or "max supported backlog"?  The iwarp
CM interprets 0 to mean no connection requests allowed. :)  

Isaac, can you explain?

Thanks,

Steve.
