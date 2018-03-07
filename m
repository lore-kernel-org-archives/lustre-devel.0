From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 7 Mar 2018 20:49:03 +0000
Subject: [lustre-devel] [PATCH 01/17] staging: lustre: obd_mount: use
 correct niduuid suffix.
In-Reply-To: <151994708505.7628.14486515694497834046.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708505.7628.14486515694497834046.stgit@noble>
Message-ID: <4F9BD297-F7B5-4F10-B700-2806FAEA9359@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> Commit 4f016420d368 ("Staging: lustre: obdclass: Use kasprintf") moved
> some sprintf() calls earlier in the code to combine them with
> memory allocation and create kasprintf() calls.
> 
> In one case, this code movement moved the sprintf to a location where the
> values being formatter were different.
> In particular
>       sprintf(niduuid, "%s_%x", mgcname, i);
> was move from *after* the line
>        i = 0;
> to a location where the value of 'i' was at least 1.
> 
> This cause the wrong name to be formatted, and triggers
> 
>       CERROR("del MDC UUID %s failed: rc = %d\n",
>              niduuid, rc);
> 
> at unmount time.
> 
> So use '0' instead of 'i'.
> 
> Fixes: 4f016420d368 ("Staging: lustre: obdclass: Use kasprintf")
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> index acc1ea773c9c..f5e8214ac37b 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> @@ -243,7 +243,7 @@ int lustre_start_mgc(struct super_block *sb)
> 	libcfs_nid2str_r(nid, nidstr, sizeof(nidstr));
> 	mgcname = kasprintf(GFP_NOFS,
> 			    "%s%s", LUSTRE_MGC_OBDNAME, nidstr);
> -	niduuid = kasprintf(GFP_NOFS, "%s_%x", mgcname, i);
> +	niduuid = kasprintf(GFP_NOFS, "%s_%x", mgcname, 0);
> 	if (!mgcname || !niduuid) {
> 		rc = -ENOMEM;
> 		goto out_free;
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
