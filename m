From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 16 Apr 2018 16:51:57 +0300
Subject: [lustre-devel] [PATCH 03/25] staging: lustre: libcfs: implement
 cfs_cpt_cpumask for UMP case
In-Reply-To: <1523851807-16573-4-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-4-git-send-email-jsimmons@infradead.org>
Message-ID: <20180416135157.zg2jwmeutzid3pzn@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:45AM -0400, James Simmons wrote:
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> index 705abf2..5ea294f 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> @@ -54,6 +54,9 @@ struct cfs_cpt_table *
>  	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
>  	if (cptab) {
        ^^^^^^^^^^^^
Don't do "success handling", do "error handling".  Success handling
means we have to indent the code and it makes it more complicated to
read.  Ideally code would look like:

	do_this();
	do_that();
	do_the_next_thing();

But because of error handling then we have to add a bunch of if
statements.  It's better when those if statements are very quick and
we can move on.  The success path is all at indent level one still like
and ideal situation above and the the error paths are at indent level
two.

	if (!cptab)
		return NULL;


>  		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
> +		if (!zalloc_cpumask_var(&cptab->ctb_mask, GFP_NOFS))
> +			return NULL;

This leaks.  It should be:

	if (!zalloc_cpumask_var(&cptab->ctb_mask, GFP_NOFS)) {
		kfree(cptab);
		return NULL;
	}

> +		cpumask_set_cpu(0, cptab->ctb_mask);
>  		node_set(0, cptab->ctb_nodemask);
>  		cptab->ctb_nparts  = ncpt;
>  	}

regards,
dan carpenter
