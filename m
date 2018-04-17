From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 Apr 2018 10:34:42 +0300
Subject: [lustre-devel] [PATCH 17/25] staging: lustre: libcfs: rename
 goto label in cfs_cpt_table_print
In-Reply-To: <1523851807-16573-18-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-18-git-send-email-jsimmons@infradead.org>
Message-ID: <20180417073442.5i3h4wz3gvjcnqti@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

> diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> index ae5ff58..435ee8e 100644
> --- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
> @@ -161,20 +161,20 @@ int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
>  
>  	for (i = 0; i < cptab->ctb_nparts; i++) {
>  		if (len <= 0)
> -			goto out;
> +			goto err;
>  
>  		rc = snprintf(tmp, len, "%d\t:", i);
>  		len -= rc;
>  
>  		if (len <= 0)
> -			goto out;
> +			goto err;

Labels should say what the goto does.  In this case, it's a do-nothing
goto with a "forgot to set the error code" bug.

regards,
dan carpenter
