From: Joe Perches <joe@perches.com>
Date: Sat, 22 Jul 2017 10:00:24 -0700
Subject: [lustre-devel] [PATCH] Staging: lustre: Place the open brace on
	previous line.
In-Reply-To: <1500742601-10733-1-git-send-email-shreeya.patel23498@gmail.com>
References: <1500742601-10733-1-git-send-email-shreeya.patel23498@gmail.com>
Message-ID: <1500742824.14415.37.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shreeya Patel <shreeya.patel23498@gmail.com>, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Sat, 2017-07-22 at 22:26 +0530, Shreeya Patel wrote:
> Remove errors by placing the open braces on previous line.
> This saves the vertical space of the code.
> 
> Problem found by checkpatch.

No.  These are checkpatch false positives.

> diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
[]
> @@ -1348,8 +1348,7 @@ cfs_hash_lookup(struct cfs_hash *hs, const void *key)
>  EXPORT_SYMBOL(cfs_hash_lookup);
>  
>  static void
> -cfs_hash_for_each_enter(struct cfs_hash *hs)
> -{
> +cfs_hash_for_each_enter(struct cfs_hash *hs) {
>  	LASSERT(!cfs_hash_is_exiting(hs));
>  
>  	if (!cfs_hash_with_rehash(hs))

etc...

These are correctly written function definitions.
