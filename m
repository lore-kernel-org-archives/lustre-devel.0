From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 22 May 2015 16:00:19 +0300
Subject: [lustre-devel] [PATCH 2/3] staging:lustre: remove kernel
 defines in userland headers
In-Reply-To: <1432248378-28912-3-git-send-email-jsimmons@infradead.org>
References: <uja.ornl@gmail.com>
	<1432248378-28912-3-git-send-email-jsimmons@infradead.org>
Message-ID: <20150522130019.GN4150@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch seems fine but it would also be better if it were broken up
into easy to review patches.

[patch 1] delete LNET_USE_LIB_FREELIST code
	This is theortetically what this patch does except it does tons
	of other things as well.

Patches which delete whole functions, #defines or from #ifdef to #endif
are normally easy to review.  When there are + lines it is hard.

[patch 2] move things around (i guess)?
[patch 3] white space fixes
[patch 4] get rid of lnet_eq_free_locked() and macro friends.
[patch 5] rename CamelCase functions
[patch 6] clean up lnet_msg_container_setup()

>  typedef struct lnet_peer {
> -	struct list_head	lp_hashlist;	  /* chain on peer hash */
> -	struct list_head	lp_txq;	       /* messages blocking for tx credits */
> -	struct list_head	lp_rtrq;	      /* messages blocking for router credits */
> -	struct list_head	lp_rtr_list;	  /* chain on router list */
> -	int	       lp_txcredits;	 /* # tx credits available */
> -	int	       lp_mintxcredits;      /* low water mark */
> -	int	       lp_rtrcredits;	/* # router credits */
> -	int	       lp_minrtrcredits;     /* low water mark */
> -	unsigned int      lp_alive:1;	   /* alive/dead? */
> -	unsigned int      lp_notify:1;	  /* notification outstanding? */
> -	unsigned int      lp_notifylnd:1;       /* outstanding notification for LND? */
> -	unsigned int      lp_notifying:1;       /* some thread is handling notification */
> -	unsigned int      lp_ping_notsent;      /* SEND event outstanding from ping */
> -	int	       lp_alive_count;       /* # times router went dead<->alive */
> -	long	      lp_txqnob;	    /* bytes queued for sending */
> -	unsigned long	lp_timestamp;	 /* time of last aliveness news */
> -	unsigned long	lp_ping_timestamp;    /* time of last ping attempt */
> -	unsigned long	lp_ping_deadline;     /* != 0 if ping reply expected */
> -	unsigned long	lp_last_alive;	/* when I was last alive */
> -	unsigned long	lp_last_query;	/* when lp_ni was queried last time */
> -	lnet_ni_t	*lp_ni;		/* interface peer is on */
> -	lnet_nid_t	lp_nid;	       /* peer's NID */
> -	int	       lp_refcount;	  /* # refs */
> -	int			lp_cpt;		/* CPT this peer attached on */
> +	/* chain on peer hash */
> +	struct list_head	lp_hashlist;
> +	/* messages blocking for tx credits */
> +	struct list_head	lp_txq;
> +	/* messages blocking for router credits */
> +	struct list_head	lp_rtrq;
> +	/* chain on router list */
> +	struct list_head	lp_rtr_list;
> +	/* # tx credits available */
> +	int			lp_txcredits;
> +	/* low water mark */
> +	int			lp_mintxcredits;
> +	/* # router credits */
> +	int			lp_rtrcredits;
> +	/* low water mark */
> +	int			lp_minrtrcredits;
> +	/* alive/dead? */
> +	unsigned int		lp_alive:1;
> +	/* notification outstanding? */
> +	unsigned int		lp_notify:1;
> +	/* outstanding notification for LND? */
> +	unsigned int		lp_notifylnd:1;
> +	/* some thread is handling notification */
> +	unsigned int		lp_notifying:1;
> +	/* SEND event outstanding from ping */
> +	unsigned int		lp_ping_notsent;
> +	/* # times router went dead<->alive */
> +	int			lp_alive_count;
> +	/* bytes queued for sending */
> +	long			lp_txqnob;
> +	/* time of last aliveness news */
> +	unsigned long		lp_timestamp;
> +	/* time of last ping attempt */
> +	unsigned long		lp_ping_timestamp;
> +	/* != 0 if ping reply expected */
> +	unsigned long		lp_ping_deadline;
> +	/* when I was last alive */
> +	unsigned long		lp_last_alive;
> +	/* when lp_ni was queried last time */
> +	unsigned long		lp_last_query;
> +	/* interface peer is on */
> +	lnet_ni_t		*lp_ni;
> +	/* peer's NID */
> +	lnet_nid_t		lp_nid;
> +	/* # refs */
> +	int			lp_refcount;
> +	/* CPT this peer attached on */
> +	int			lp_cpt;

This new block of declarations is uglier than the original.  Don't make
things uglier.

regards,
dan carpenter
