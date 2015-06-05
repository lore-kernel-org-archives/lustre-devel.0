From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 5 Jun 2015 12:04:33 +0300
Subject: [lustre-devel] [PATCH v3 7/8] staging:lustre: style cleanups
	for LNet headers
In-Reply-To: <1433364207-14307-8-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
	<1433364207-14307-8-git-send-email-jsimmons@infradead.org>
Message-ID: <20150605090433.GO28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm fine with merging this patch as is.

On Wed, Jun 03, 2015 at 04:43:26PM -0400, James Simmons wrote:
> +	struct lnet_peer	*msg_txpeer;	 /* peer I'm sending to */
> +	struct lnet_peer	*msg_rxpeer;	 /* peer I received from */
> +
> +	void			*msg_private;
> +	struct lnet_libmd	*msg_md;
> +
> +	unsigned int		msg_len;
> +	unsigned int		msg_wanted;
> +	unsigned int		msg_offset;
> +	unsigned int		msg_niov;
> +	struct kvec		*msg_iov;
> +	lnet_kiov_t		*msg_kiov;
> +
> +	lnet_event_t		msg_ev;
> +	lnet_hdr_t		msg_hdr;

These aren't in "lustre style".  Lustre style is more like:

	unsigned int		msg_len;
	unsigned int		msg_wanted;
	unsigned int		msg_offset;
	unsigned int		msg_niov;
	struct kvec	       *msg_iov;
	lnet_kiov_t	       *msg_kiov;


We're going through and re-indenting things.  I think just one space
between type and name is the right thing for .c files but you guys
really should figure out what style you're using for your header files.

regards,
dan carpenter
