From: Joe Perches <joe@perches.com>
Date: Fri, 22 May 2015 08:24:34 -0700
Subject: [lustre-devel] [PATCH 2/3] staging:lustre: remove kernel
 defines in userland headers
In-Reply-To: <b5d34de937b54607b8c8f715bfade82a@EXCHCS32.ornl.gov>
References: <uja.ornl@gmail.com>
	<1432248378-28912-3-git-send-email-jsimmons@infradead.org>
	<20150522130019.GN4150@mwanda>
	<b5d34de937b54607b8c8f715bfade82a@EXCHCS32.ornl.gov>
Message-ID: <1432308274.29657.15.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2015-05-22 at 15:12 +0000, Simmons, James A. wrote:
> >>  typedef struct lnet_peer {
> >> -	struct list_head	lp_hashlist;	  /* chain on peer hash */
> >> -	struct list_head	lp_txq;	       /* messages blocking for tx credits */
> >> -	struct list_head	lp_rtrq;	      /* messages blocking for router credits */
> >> -	struct list_head	lp_rtr_list;	  /* chain on router list */
> >> -	int	       lp_txcredits;	 /* # tx credits available */
> >> -	int	       lp_mintxcredits;      /* low water mark */
> >> -	int	       lp_rtrcredits;	/* # router credits */
> >> -	int	       lp_minrtrcredits;     /* low water mark */
> >> -	unsigned int      lp_alive:1;	   /* alive/dead? */
> >> -	unsigned int      lp_notify:1;	  /* notification outstanding? */
> >> -	unsigned int      lp_notifylnd:1;       /* outstanding notification for LND? */
> >> -	unsigned int      lp_notifying:1;       /* some thread is handling notification */
> >> -	unsigned int      lp_ping_notsent;      /* SEND event outstanding from ping */
> >> -	int	       lp_alive_count;       /* # times router went dead<->alive */
> >> -	long	      lp_txqnob;	    /* bytes queued for sending */
> >> -	unsigned long	lp_timestamp;	 /* time of last aliveness news */
> >> -	unsigned long	lp_ping_timestamp;    /* time of last ping attempt */
> >> -	unsigned long	lp_ping_deadline;     /* != 0 if ping reply expected */
> >> -	unsigned long	lp_last_alive;	/* when I was last alive */
> >> -	unsigned long	lp_last_query;	/* when lp_ni was queried last time */
> >> -	lnet_ni_t	*lp_ni;		/* interface peer is on */
> >> -	lnet_nid_t	lp_nid;	       /* peer's NID */
> >> -	int	       lp_refcount;	  /* # refs */
> >> -	int			lp_cpt;		/* CPT this peer attached on */
> >> +	/* chain on peer hash */
> >> +	struct list_head	lp_hashlist;
> >> +	/* messages blocking for tx credits */
> >> +	struct list_head	lp_txq;
> >> +	/* messages blocking for router credits */
> >> +	struct list_head	lp_rtrq;
> >> +	/* chain on router list */
> >> +	struct list_head	lp_rtr_list;
> >> +	/* # tx credits available */
> >> +	int			lp_txcredits;
> >> +	/* low water mark */
> >> +	int			lp_mintxcredits;
> >> +	/* # router credits */
> >> +	int			lp_rtrcredits;
> >> +	/* low water mark */
> >> +	int			lp_minrtrcredits;
> >> +	/* alive/dead? */
> >> +	unsigned int		lp_alive:1;
> >> +	/* notification outstanding? */
> >> +	unsigned int		lp_notify:1;
> >> +	/* outstanding notification for LND? */
> >> +	unsigned int		lp_notifylnd:1;
> >
> >This new block of declarations is uglier than the original.  Don't make
> >things uglier.
> 
> Might be ugly but it makes checkpatch.pl happy.  So it is a choice between
> making checkpatch.pl happy about staying in the 80 character limit or looking
> nice and chekpatch.pl being unhappy.

I would choose looking nice every time.

checkpatch is stupid.  Please don't let it control you.

Maybe it'd be better to add another --ignore type just for
comments that extend longer than the maximum line length to
checkpatch.
