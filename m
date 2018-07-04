From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 03/11] lustre: llite: replace several
 GFP_NOFS with GFP_KERNEL
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943065.30111.11608217600471180041.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

GFP_KERNEL should be used preferentially unless there is
good reason to use something else.

GFP_NOFS is appropriate when the code holds some resource
that could blocks writeout triggered by memory reclaim.
So it is appropriate to us it in the writeout path, or anything
that could interact with the writeout paths.

The memory allocations affected here are either ioctl, or open/close
handling.  These can never block writeout, so GFP_NOFS is not needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/file.c |   32 ++++++++++++++--------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 614588c365df..54da6f19da21 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -64,7 +64,7 @@ static struct ll_file_data *ll_file_data_get(void)
 {
 	struct ll_file_data *fd;
 
-	fd = kmem_cache_zalloc(ll_file_data_slab, GFP_NOFS);
+	fd = kmem_cache_zalloc(ll_file_data_slab, GFP_KERNEL);
 	if (!fd)
 		return NULL;
 	fd->fd_write_failed = false;
@@ -137,7 +137,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		goto out;
 	}
 
-	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
+	op_data = kzalloc(sizeof(*op_data), GFP_KERNEL);
 	/*
 	 * We leak openhandle and request here on error, but not much to be
 	 * done in OOM case since app won't retry close on error either.
@@ -615,7 +615,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 
 			goto restart;
 		}
-		*och_p = kzalloc(sizeof(struct obd_client_handle), GFP_NOFS);
+		*och_p = kzalloc(sizeof(struct obd_client_handle), GFP_KERNEL);
 		if (!*och_p) {
 			rc = -ENOMEM;
 			goto out_och_free;
@@ -823,7 +823,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 			return ERR_PTR(rc);
 	}
 
-	och = kzalloc(sizeof(*och), GFP_NOFS);
+	och = kzalloc(sizeof(*och), GFP_KERNEL);
 	if (!och)
 		return ERR_PTR(-ENOMEM);
 
@@ -1470,7 +1470,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	lump = kzalloc(lum_size, GFP_NOFS);
+	lump = kzalloc(lum_size, GFP_KERNEL);
 	if (!lump)
 		return -ENOMEM;
 
@@ -1637,7 +1637,7 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
 
 	LASSERT(it_open_error(DISP_OPEN_OPEN, it) == 0);
 
-	och = kzalloc(sizeof(*och), GFP_NOFS);
+	och = kzalloc(sizeof(*och), GFP_KERNEL);
 	if (!och) {
 		rc = -ENOMEM;
 		goto out;
@@ -1735,7 +1735,7 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 
 	outsize = sizeof(*gfout) + pathlen;
 
-	gfout = kzalloc(outsize, GFP_NOFS);
+	gfout = kzalloc(outsize, GFP_KERNEL);
 	if (!gfout)
 		return -ENOMEM;
 
@@ -1885,7 +1885,7 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 	struct ll_swap_stack	*llss = NULL;
 	int			 rc;
 
-	llss = kzalloc(sizeof(*llss), GFP_NOFS);
+	llss = kzalloc(sizeof(*llss), GFP_KERNEL);
 	if (!llss)
 		return -ENOMEM;
 
@@ -2031,7 +2031,7 @@ static int ll_hsm_import(struct inode *inode, struct file *file,
 		return -EINVAL;
 
 	/* set HSM flags */
-	hss = kzalloc(sizeof(*hss), GFP_NOFS);
+	hss = kzalloc(sizeof(*hss), GFP_KERNEL);
 	if (!hss)
 		return -ENOMEM;
 
@@ -2042,7 +2042,7 @@ static int ll_hsm_import(struct inode *inode, struct file *file,
 	if (rc != 0)
 		goto free_hss;
 
-	attr = kzalloc(sizeof(*attr), GFP_NOFS);
+	attr = kzalloc(sizeof(*attr), GFP_KERNEL);
 	if (!attr) {
 		rc = -ENOMEM;
 		goto free_hss;
@@ -2298,7 +2298,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct hsm_user_state	*hus;
 		int			 rc;
 
-		hus = kzalloc(sizeof(*hus), GFP_NOFS);
+		hus = kzalloc(sizeof(*hus), GFP_KERNEL);
 		if (!hus)
 			return -ENOMEM;
 
@@ -2337,7 +2337,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct hsm_current_action	*hca;
 		int				 rc;
 
-		hca = kzalloc(sizeof(*hca), GFP_NOFS);
+		hca = kzalloc(sizeof(*hca), GFP_KERNEL);
 		if (!hca)
 			return -ENOMEM;
 
@@ -2464,7 +2464,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int i;
 
 		rc = 0;
-		ladvise_hdr = kzalloc(alloc_size, GFP_NOFS);
+		ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
 		if (!ladvise_hdr)
 			return -ENOMEM;
 
@@ -2490,7 +2490,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(ladvise_hdr);
 		alloc_size = offsetof(typeof(*ladvise_hdr),
 				      lah_advise[num_advise]);
-		ladvise_hdr = kzalloc(alloc_size, GFP_NOFS);
+		ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
 		if (!ladvise_hdr)
 			return -ENOMEM;
 
@@ -3458,7 +3458,7 @@ void *ll_iocontrol_register(llioc_callback_t cb, int count, unsigned int *cmd)
 		return NULL;
 
 	size = sizeof(*in_data) + count * sizeof(unsigned int);
-	in_data = kzalloc(size, GFP_NOFS);
+	in_data = kzalloc(size, GFP_KERNEL);
 	if (!in_data)
 		return NULL;
 
@@ -3625,7 +3625,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 		goto out;
 	}
 
-	lvbdata = kvzalloc(lmmsize, GFP_NOFS);
+	lvbdata = kvzalloc(lmmsize, GFP_KERNEL);
 	if (!lvbdata) {
 		rc = -ENOMEM;
 		goto out;
