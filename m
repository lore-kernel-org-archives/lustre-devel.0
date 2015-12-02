From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 15:00:56 +0300
Subject: [lustre-devel] [PATCH 13/40] staging: lustre: Dynamic LNet
 Configuration (DLC) show command
In-Reply-To: <1448062576-23757-14-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-14-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202120056.GO18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 20, 2015 at 06:35:49PM -0500, James Simmons wrote:
> +int lnet_get_peers(int count, __u64 *nid, char *aliveness,
> +		   int *ncpt, int *refcount,
> +		   int *ni_peer_tx_credits, int *peer_tx_credits,
> +		   int *peer_rtr_credits, int *peer_min_rtr_credits,
> +		   int *peer_tx_qnob)
> +{
> +	struct lnet_peer_table *peer_table;
> +	lnet_peer_t *lp;
> +	int j;
> +	int lncpt, found = 0;
> +
> +	/* get the number of CPTs */
> +	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
> +
> +	/*
> +	 * if the cpt number to be examined is >= the number of cpts in
> +	 * the system then indicate that there are no more cpts to examin
> +	 */
> +	if (*ncpt > lncpt)
> +		return -1;


The comment is correct but the code is off by one.

	if (*ncpt >= lncpt)
		return -EINVAL;

Also not a correct error code.  I assume that you will review the whole
patchset again and fix all the -1 returns, of course.

regards,
dan carpenter
