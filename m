From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 18 May 2017 08:30:36 +0000
Subject: [lustre-devel] [PATCH 6/6] staging/lustre: Use generic range
	rwlock
In-Reply-To: <20170515090725.27055-7-dave@stgolabs.net>
References: <20170515090725.27055-1-dave@stgolabs.net>
	<20170515090725.27055-7-dave@stgolabs.net>
Message-ID: <907C3F64-C3AF-4027-98F2-58877E650368@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jack@suse.cz" <jack@suse.cz>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "mhocko@suse.com" <mhocko@suse.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, Davidlohr Bueso <dbueso@suse.de>

On May 15, 2017, at 11:07, Davidlohr Bueso <dave@stgolabs.net> wrote:
> 
> This replaces the in-house version, which is also derived
> from Jan's interval tree implementation.
> 
> Cc: oleg.drokin at intel.com
> Cc: andreas.dilger at intel.com
> Cc: jsimmons at infradead.org
> Cc: lustre-devel at lists.lustre.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Repeating my request that the whole patch series should be CC'd to the linux-fsdevel list,
since I only got this last patch and this makes it difficult to review the whole series.

> ---
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index 67c4b9cc6e75..bd020bdaf85d 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -1083,10 +1083,10 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
> 		if (((iot == CIT_WRITE) ||
> 		     (iot == CIT_READ && (file->f_flags & O_DIRECT))) &&
> 		    !(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
> -			CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
> -			       range.rl_node.in_extent.start,
> -			       range.rl_node.in_extent.end);
> -			rc = range_lock(&lli->lli_write_tree, &range);
> +			CDEBUG(D_VFSTRACE, "Range lock [%lu, %lu]\n",
> +			       range.node.start,
> +			       range.node.last);
> +			rc = range_write_lock_interruptible(&lli->lli_write_tree, &range);
> 			if (rc < 0)
> 				goto out;
> 
> @@ -1096,10 +1096,10 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
> 		rc = cl_io_loop(env, io);
> 		ll_cl_remove(file, env);
> 		if (range_locked) {
> -			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
> -			       range.rl_node.in_extent.start,
> -			       range.rl_node.in_extent.end);
> -			range_unlock(&lli->lli_write_tree, &range);
> +			CDEBUG(D_VFSTRACE, "Range unlock [%lu, %lu]\n",
> +			       range.node.start,
> +			       range.node.last);
> +			range_write_unlock(&lli->lli_write_tree, &range);
> 		}
> 	} else {
> 		/* cl_io_rw_init() handled IO */

I'm not against this patch, but it does expose an implementation difference between the
Lustre version of this code and the in-tree version.  Preferred kernel coding style is to
have a struct-unique prefix for struct members (e.g. using "rl_" for struct range_lock,
using "in_" for struct interval_tree_node).  That allows tags to work properly, instead
of trying to locate generic struct names like "start", "node" etc.

In an unexpected twist of fate, the Lustre version of this code is following preferred
coding style and the in-tree (interval_tree) and submitted (range_rwlock) code does not.

Cheers, Andreas
