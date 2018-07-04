From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 12:17:06 +1000
Subject: [lustre-devel] [PATCH 00/10] lustre: libcfs: fix libcfs debugfs
 bugs
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87y3erzqvx.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> The original port to sysfs / debugfs was done in haste without any
> testing so many bugs were introduced. This patch set resolves the
> bugs found in the libcfs code when it was reviewed.
>
> James Simmons (10):
>   lustre: libcfs: rename lustre_*_debugfs to lnet_*_debugfs
>   lustre: libcfs: rename *_debugmb to *_debug_mb
>   lustre: libcfs: make lnet_debugfs_symlink_def fields const
>   lustre: libcfs: fix module loading and sysfs setting race
>   lustre: libcfs: fix wrong debugfs symlink name
>   lustre: libcfs: don't assume sysfs mount point
>   lustre: libcfs: properly initialize lnet_debugfs_symlink_def
>   lustre: libcfs: test if table is NULL for lnet_insert_debugfs
>   lustre: libcfs: return ssize_t for lnet_debugfs_*
>   lustre: libcfs: small cleanups for debugfs code
>
>  .../staging/lustre/include/linux/libcfs/libcfs.h   |  2 +-
>  drivers/staging/lustre/lnet/libcfs/debug.c         | 28 ++++----
>  drivers/staging/lustre/lnet/libcfs/module.c        | 78 +++++++++++-----------
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |  2 +-
>  4 files changed, 57 insertions(+), 53 deletions(-)
>
> -- 
> 1.8.3.1

These all look good to me, so I've (provisionally) applied them.
I didn't know about kernel_param_lock() before. I wonder if it
would make sense to use that to protect updates to sbi->ll_flags???

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180704/9f21b8eb/attachment.sig>
