From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Oct 2018 00:04:37 +0100 (BST)
Subject: [lustre-devel] [PATCH 01/10] lustre: lnd: set device
 capabilities
In-Reply-To: <87va5u8znw.fsf@notabene.neil.brown.name>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
 <1539543332-28679-2-git-send-email-jsimmons@infradead.org>
 <87efcpdsnz.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1810201748160.16676@casper.infradead.org>
 <87va5u8znw.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810240003090.25521@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> > index a4438d2..9f0a47d 100644
> >> > --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> >> > +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> >> > @@ -73,6 +73,10 @@
> >> >  #define IBLND_N_SCHED			2
> >> >  #define IBLND_N_SCHED_HIGH		4
> >> >  
> >> > +#define IBLND_DEV_CAPS_FASTREG_ENABLED		0x1
> >> > +#define IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	0x2
> >> > +#define IBLND_DEV_CAPS_FMR_ENABLED		0x4
> >> > +
> >> 
> >> BIT(0), BIT(1), .... ???
> >> 
> >> >  struct kib_tunables {
> >> >  	int *kib_dev_failover;           /* HCA failover */
> >> >  	unsigned int *kib_service;       /* IB service number */
> >> > @@ -162,6 +166,7 @@ struct kib_dev {
> >> >  	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
> >> >  	struct list_head   ibd_nets;
> >> >  	struct kib_hca_dev *ibd_hdev;
> >> > +	u32			ibd_dev_caps;
> >> 
> >> "unsigned int" would be better I think, but it isn't very important.
> >
> > Actually better yet it could be changed to an enum. Move the below to
> > just above struct kib_dev {
> >
> > enum ibd_dev_caps {
> > 	IBLND_DEV_CAPS_FASTREG_ENABLED		= BIT(0),
> > 	IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT	= BIT(1),
> > 	IBLND_DEV_CAPS_FMR_ENABLED		= BIT(2),
> > }
> >
> > and change ibd_dev_caps from u32 to enum ibd_dev_caps.
> >
> > Do you mind if that is a follow on patch?
> >
> 
> Yes, that would be good, thanks.
> I'll apply this patch as it is.

New patch at https://review.whamcloud.com/#/c/33409
I will push shortly to linux client.
