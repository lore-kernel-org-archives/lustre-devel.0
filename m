From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 5 Jun 2015 12:02:00 +0300
Subject: [lustre-devel] [PATCH v3 1/8] staging:lustre: assume a kernel
	build
In-Reply-To: <1433364207-14307-2-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
	<1433364207-14307-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20150605090200.GL28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This whole patchset looks find to me.

Some tips for the future.

On Wed, Jun 03, 2015 at 04:43:20PM -0400, James Simmons wrote:
> From: John L. Hammond <john.hammond@intel.com>
> 
> In lnet/lnet/ and lnet/selftest/ assume a kernel build (assume that
> __KERNEL__ is defined). Remove some common code only needed for user
> space LNet.
> 

> -	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME, LNET_FL_MAX_MES,
> -					  sizeof(lnet_me_t));
> +	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME, 0, 0);

When I'm reviewing "delete code" patches, I pretty much focus on the
plus lines like this one.  Obviously, I can figure out why we changed
the parameters to zero but it saves me time if it's spelled out in the
changelog.

regards,
dan carpenter
