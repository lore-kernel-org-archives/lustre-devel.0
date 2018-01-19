From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 19 Jan 2018 03:36:43 +0000
Subject: [lustre-devel] [PATCH 6/8] staging: lustre: Fix overlong lines
In-Reply-To: <1515691022-22729-7-git-send-email-fabian_huegel@web.de>
References: <1515691022-22729-1-git-send-email-fabian_huegel@web.de>
 <1515691022-22729-7-git-send-email-fabian_huegel@web.de>
Message-ID: <00C20AD1-618E-4F27-8DA1-4D6C4339CFFA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fabian Huegel <fabian_huegel@web.de>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, "Hammond, John" <john.hammond@intel.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Ben Evans <bevans@cray.com>, NeilBrown <neilb@suse.com>, Lustre Development List <lustre-devel@lists.lustre.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-kernel@i4.cs.fau.de" <linux-kernel@i4.cs.fau.de>, Christoph Volkert <linux@christoph-volkert.de>

On Jan 11, 2018, at 10:17, Fabian Huegel <fabian_huegel@web.de> wrote:
> 
> Fixed four lines that went over the 80 character limit
> to reduce checkpatch warnings.
> 
> Signed-off-by: Fabian Huegel <fabian_huegel@web.de>
> Signed-off-by: Christoph Volkert <linux@christoph-volkert.de>
> ---
> drivers/staging/lustre/lustre/include/obd_class.h | 14 ++++++++++----
> 1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index d195866..06f825b 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -850,7 +850,9 @@ static inline int obd_pool_del(struct obd_device *obd, char *poolname)
> 	return rc;
> }
> 
> -static inline int obd_pool_add(struct obd_device *obd, char *poolname, char *ostname)
> +static inline int obd_pool_add(struct obd_device *obd,
> +			       char *poolname,
> +			       char *ostname)

This only needs a single field moved onto the next line, like:

+static inline int obd_pool_add(struct obd_device *obd, char *poolname,
+			       char *ostname)


> @@ -861,7 +863,9 @@ static inline int obd_pool_add(struct obd_device *obd, char *poolname, char *ost
> 	return rc;
> }
> 
> -static inline int obd_pool_rem(struct obd_device *obd, char *poolname, char *ostname)
> +static inline int obd_pool_rem(struct obd_device *obd,
> +			       char *poolname,
> +			       char *ostname)

Same.

> @@ -997,7 +1001,8 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
> 			spin_unlock(&obd->obd_osfs_lock);
> 		}
> 	} else {
> -		CDEBUG(D_SUPER, "%s: use %p cache blocks %llu/%llu objects %llu/%llu\n",
> +		CDEBUG(D_SUPER,
> +		       "%s: use %p cache blocks %llu/%llu objects %llu/%llu\n",
> 		       obd->obd_name, &obd->obd_osfs,
> 		       obd->obd_osfs.os_bavail, obd->obd_osfs.os_blocks,
> 		       obd->obd_osfs.os_ffree, obd->obd_osfs.os_files);
> @@ -1579,7 +1584,8 @@ int class_procfs_init(void);
> int class_procfs_clean(void);
> 
> /* prng.c */
> -#define ll_generate_random_uuid(uuid_out) get_random_bytes(uuid_out, sizeof(class_uuid_t))
> +#define ll_generate_random_uuid(uuid_out) \
> +	get_random_bytes(uuid_out, sizeof(class_uuid_t))

This looks like it would be better to replace ll_generate_random_uuid()
callers with generate_random_uuid().

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
