From: Joe Perches <joe@perches.com>
Date: Fri, 12 Feb 2016 09:35:03 -0800
Subject: [lustre-devel] [PATCH 06/11] staging: lustre: add missing
 spaces for LNet layer reported by checkpatch.pl
In-Reply-To: <1455296769-5481-7-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
	<1455296769-5481-7-git-send-email-jsimmons@infradead.org>
Message-ID: <1455298503.4235.4.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, 2016-02-12 at 12:06 -0500, James Simmons wrote:
> Add missing spaces in the code reported by checkpatch.pl.
[]
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
[]
> @@ -112,7 +112,7 @@ typedef struct lnet_libhandle {
> ?} lnet_libhandle_t;
> ?
> ?#define lh_entry(ptr, type, member) \
> -	((type *)((char *)(ptr)-(char *)(&((type *)0)->member)))
> +	((type *)((char *)(ptr) - (char *)(&((type *)0)->member)))

This could use offsetof(type, member)
