From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 25 Nov 2016 15:17:37 +0300
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: libcfs: remove
 NULL comparisons in headers
In-Reply-To: <1479487724-20386-9-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
	<1479487724-20386-9-git-send-email-jsimmons@infradead.org>
Message-ID: <20161125120841.GC6266@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Nov 18, 2016 at 11:48:42AM -0500, James Simmons wrote:
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index 93bff1b..fc180b8 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -96,7 +96,7 @@
>  
>  #define LIBCFS_ALLOC_POST(ptr, size)					    \
>  do {									    \
> -	if (unlikely((ptr) == NULL)) {					    \
> +	if (!unlikely((ptr))) {						    \

Argh....  No.  You did this with a Perl script?

This should be:

	if (unlikely(!ptr)) { ...

>  		CERROR("LNET: out of memory at %s:%d (tried to alloc '"	    \
>  		       #ptr "' = %d)\n", __FILE__, __LINE__, (int)(size));  \
>  	} else {							    \
> @@ -147,7 +147,7 @@
>  
>  #define LIBCFS_FREE(ptr, size)					  \
>  do {								    \
> -	if (unlikely((ptr) == NULL)) {				  \
> +	if (!unlikely((ptr))) {						\

Same.

Otherwise the unlikely hint is reversed from what we want.

regards,
dan carpenter
