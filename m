From: James Simmons <jsimmons@infradead.org>
Date: Thu, 25 Jul 2019 19:46:14 +0100 (BST)
Subject: [lustre-devel] [PATCH] lustre: lnet: fix needed headers for
 lnet headers
In-Reply-To: <87k1c6n28p.fsf@notabene.neil.brown.name>
References: <1564001154-2944-1-git-send-email-jsimmons@infradead.org>
 <87k1c6n28p.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1907251944560.19654@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Wed, Jul 24 2019, James Simmons wrote:
> 
> > The linux kernel now has a sanity check for the global headers and
> > LNet are missing a few headers to allow them to build properly.
> 
> Thanks.
> I've modified the above to:
> 
>     The linux kernel now has a sanity check for the global headers,
>     activated by  CONFIG_HEADER_TEST=y and CONFIG_KERNEL_HEADER_TEST=y.
>     Some LNet headers are missing a few headers to allow them to build properly.
> 
> and applied the patch.
> 

Acked-by: James Simmons <jsimmons@infradead.org>


> > ---
> >  include/linux/libcfs/libcfs_fail.h    | 1 +
> >  include/linux/libcfs/libcfs_private.h | 3 +++
> >  include/uapi/linux/lnet/lnetst.h      | 2 ++
> >  3 files changed, 6 insertions(+)
> >
> > diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
> > index 0e73eef..f52a82a 100644
> > --- a/include/linux/libcfs/libcfs_fail.h
> > +++ b/include/linux/libcfs/libcfs_fail.h
> > @@ -35,6 +35,7 @@
> >  
> >  #include <linux/sched.h>
> >  #include <linux/wait.h>
> > +#include <linux/libcfs/libcfs_debug.h>
> >  
> >  extern unsigned long cfs_fail_loc;
> >  extern unsigned int cfs_fail_val;
> > diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
> > index 515fd63..2e8cff6 100644
> > --- a/include/linux/libcfs/libcfs_private.h
> > +++ b/include/linux/libcfs/libcfs_private.h
> > @@ -39,6 +39,9 @@
> >  #ifndef __LIBCFS_PRIVATE_H__
> >  #define __LIBCFS_PRIVATE_H__
> >  
> > +#include <linux/sched.h>
> > +#include <linux/libcfs/libcfs_debug.h>
> > +
> >  #ifndef DEBUG_SUBSYSTEM
> >  # define DEBUG_SUBSYSTEM S_UNDEFINED
> >  #endif
> > diff --git a/include/uapi/linux/lnet/lnetst.h b/include/uapi/linux/lnet/lnetst.h
> > index 27fcd91..449c5e6 100644
> > --- a/include/uapi/linux/lnet/lnetst.h
> > +++ b/include/uapi/linux/lnet/lnetst.h
> > @@ -38,6 +38,8 @@
> >  #define __LNET_ST_H__
> >  
> >  #include <linux/types.h>
> > +#include <linux/time.h>
> > +#include <linux/lnet/lnet-types.h>
> >  
> >  #define LST_FEAT_NONE		(0)
> >  #define LST_FEAT_BULK_LEN	(1 << 0)	/* enable variable page size */
> > -- 
> > 1.8.3.1
> 
