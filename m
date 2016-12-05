From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 5 Dec 2016 17:50:21 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: Fix function
	declaration/definition mismatch
In-Reply-To: <1480907197-23201-1-git-send-email-sandeepjain.linux@gmail.com>
References: <1480907197-23201-1-git-send-email-sandeepjain.linux@gmail.com>
Message-ID: <B164B906-4CF5-4619-AFE4-A074289A183C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "<sandeepjain.linux@gmail.com>" <sandeepjain.linux@gmail.com>
Cc: andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


On Dec 4, 2016, at 10:06 PM, <sandeepjain.linux@gmail.com> <sandeepjain.linux@gmail.com> wrote:

> From: Sandeep Jain <sandeepjain.linux@gmail.com>
> 
> Fixes following Sparse errors.
> lprocfs_status.c:1568:5: error: symbol 'lprocfs_wr_root_squash'
> redeclared with different type...
> lprocfs_status.c:1632:5: error: symbol 'lprocfs_wr_nosquash_nids'
> redeclared with different type...
> 
> Signed-off-by: Sandeep Jain <sandeepjain.linux@gmail.com>

Acked-by: Oleg Drokin <oleg.drokin@intel.com>

> ---
> drivers/staging/lustre/lustre/include/lprocfs_status.h | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> index cc0713e..b5c24ca 100644
> --- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
> +++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> @@ -701,9 +701,9 @@ static struct lustre_attr lustre_attr_##name = __ATTR(name, mode, show, store)
> extern const struct sysfs_ops lustre_sysfs_ops;
> 
> struct root_squash_info;
> -int lprocfs_wr_root_squash(const char *buffer, unsigned long count,
> +int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
> 			   struct root_squash_info *squash, char *name);
> -int lprocfs_wr_nosquash_nids(const char *buffer, unsigned long count,
> +int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
> 			     struct root_squash_info *squash, char *name);
> 
> /* all quota proc functions */
> -- 
> 2.7.4
