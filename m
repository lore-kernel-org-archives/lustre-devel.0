From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:27:59 -0400
Subject: [lustre-devel] [PATCH 03/41] staging: lustre: llite: remove client
	Size on MDS support
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Size on MDS support have been in preview since at least 2.0.0. Remove
support for it from lustre/llite/.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6047
Reviewed-on: http://review.whamcloud.com/13126
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |   97 +-----
 drivers/staging/lustre/lustre/llite/glimpse.c      |  105 +++---
 drivers/staging/lustre/lustre/llite/llite_close.c  |  395 --------------------
 .../staging/lustre/lustre/llite/llite_internal.h   |   56 +---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  127 +------
 drivers/staging/lustre/lustre/llite/namei.c        |    8 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    3 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |   18 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   11 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    4 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   24 +--
 drivers/staging/lustre/lustre/llite/vvp_req.c      |   13 +-
 13 files changed, 89 insertions(+), 774 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/llite/llite_close.c

diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 1ac0940..3690bee 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
-lustre-y := dcache.o dir.o file.o llite_close.o llite_lib.o llite_nfs.o \
+lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    rw.o namei.o symlink.o llite_mmap.o range_lock.o \
 	    xattr.o xattr_cache.o rw26.o super25.o statahead.o \
 	    glimpse.o lcommon_cl.o lcommon_misc.o \
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 6e3a188..b2058c6 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -86,7 +86,6 @@ void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
 	op_data->op_attr.ia_size = i_size_read(inode);
 	op_data->op_attr_blocks = inode->i_blocks;
 	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
-	op_data->op_ioepoch = ll_i2info(inode)->lli_ioepoch;
 	if (fh)
 		op_data->op_handle = *fh;
 
@@ -95,8 +94,7 @@ void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
 }
 
 /**
- * Closes the IO epoch and packs all the attributes into @op_data for
- * the CLOSE rpc.
+ * Packs all the attributes into @op_data for the CLOSE rpc.
  */
 static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
 			     struct obd_client_handle *och)
@@ -108,11 +106,7 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
 	if (!(och->och_flags & FMODE_WRITE))
 		goto out;
 
-	if (!exp_connect_som(ll_i2mdexp(inode)) || !S_ISREG(inode->i_mode))
-		op_data->op_attr.ia_valid |= ATTR_SIZE | ATTR_BLOCKS;
-	else
-		ll_ioepoch_close(inode, op_data, &och, 0);
-
+	op_data->op_attr.ia_valid |= ATTR_SIZE | ATTR_BLOCKS;
 out:
 	ll_pack_inode2opdata(inode, op_data, &och->och_fh);
 	ll_prep_md_op_data(op_data, inode, NULL, NULL,
@@ -128,7 +122,6 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 	struct md_op_data *op_data;
 	struct ptlrpc_request *req = NULL;
 	struct obd_device *obd = class_exp2obd(exp);
-	int epoch_close = 1;
 	int rc;
 
 	if (!obd) {
@@ -157,22 +150,9 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 		op_data->op_lease_handle = och->och_lease_handle;
 		op_data->op_attr.ia_valid |= ATTR_SIZE | ATTR_BLOCKS;
 	}
-	epoch_close = op_data->op_flags & MF_EPOCH_CLOSE;
+
 	rc = md_close(md_exp, op_data, och->och_mod, &req);
-	if (rc == -EAGAIN) {
-		/* This close must have the epoch closed. */
-		LASSERT(epoch_close);
-		/* MDS has instructed us to obtain Size-on-MDS attribute from
-		 * OSTs and send setattr to back to MDS.
-		 */
-		rc = ll_som_update(inode, op_data);
-		if (rc) {
-			CERROR("%s: inode "DFID" mdc Size-on-MDS update failed: rc = %d\n",
-			       ll_i2mdexp(inode)->exp_obd->obd_name,
-			       PFID(ll_inode2fid(inode)), rc);
-			rc = 0;
-		}
-	} else if (rc) {
+	if (rc) {
 		CERROR("%s: inode "DFID" mdc close failed: rc = %d\n",
 		       ll_i2mdexp(inode)->exp_obd->obd_name,
 		       PFID(ll_inode2fid(inode)), rc);
@@ -200,15 +180,10 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 	ll_finish_md_op_data(op_data);
 
 out:
-	if (exp_connect_som(exp) && !epoch_close &&
-	    S_ISREG(inode->i_mode) && (och->och_flags & FMODE_WRITE)) {
-		ll_queue_done_writing(inode, LLIF_DONE_WRITING);
-	} else {
-		md_clear_open_replay_data(md_exp, och);
-		/* Free @och if it is not waiting for DONE_WRITING. */
-		och->och_fh.cookie = DEAD_HANDLE_MAGIC;
-		kfree(och);
-	}
+	md_clear_open_replay_data(md_exp, och);
+	och->och_fh.cookie = DEAD_HANDLE_MAGIC;
+	kfree(och);
+
 	if (req) /* This is close request */
 		ptlrpc_req_finished(req);
 	return rc;
@@ -437,20 +412,6 @@ out:
 	return rc;
 }
 
-/**
- * Assign an obtained @ioepoch to client's inode. No lock is needed, MDS does
- * not believe attributes if a few ioepoch holders exist. Attributes for
- * previous ioepoch if new one is opened are also skipped by MDS.
- */
-void ll_ioepoch_open(struct ll_inode_info *lli, __u64 ioepoch)
-{
-	if (ioepoch && lli->lli_ioepoch != ioepoch) {
-		lli->lli_ioepoch = ioepoch;
-		CDEBUG(D_INODE, "Epoch %llu opened on "DFID"\n",
-		       ioepoch, PFID(&lli->lli_fid));
-	}
-}
-
 static int ll_och_fill(struct obd_export *md_exp, struct lookup_intent *it,
 		       struct obd_client_handle *och)
 {
@@ -470,23 +431,17 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 			 struct ll_file_data *fd, struct obd_client_handle *och)
 {
 	struct inode *inode = file_inode(file);
-	struct ll_inode_info *lli = ll_i2info(inode);
 
 	LASSERT(!LUSTRE_FPRIVATE(file));
 
 	LASSERT(fd);
 
 	if (och) {
-		struct mdt_body *body;
 		int rc;
 
 		rc = ll_och_fill(ll_i2sbi(inode)->ll_md_exp, it, och);
 		if (rc != 0)
 			return rc;
-
-		body = req_capsule_server_get(&it->it_request->rq_pill,
-					      &RMF_MDT_BODY);
-		ll_ioepoch_open(lli, body->mbo_ioepoch);
 	}
 
 	LUSTRE_FPRIVATE(file) = fd;
@@ -912,7 +867,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 
 /* Fills the obdo with the attributes for the lsm */
 static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
-			  struct obdo *obdo, __u64 ioepoch, int dv_flags)
+			  struct obdo *obdo, int dv_flags)
 {
 	struct ptlrpc_request_set *set;
 	struct obd_info	    oinfo = { };
@@ -924,13 +879,11 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 	oinfo.oi_oa = obdo;
 	oinfo.oi_oa->o_oi = lsm->lsm_oi;
 	oinfo.oi_oa->o_mode = S_IFREG;
-	oinfo.oi_oa->o_ioepoch = ioepoch;
 	oinfo.oi_oa->o_valid = OBD_MD_FLID | OBD_MD_FLTYPE |
 			       OBD_MD_FLSIZE | OBD_MD_FLBLOCKS |
 			       OBD_MD_FLBLKSZ | OBD_MD_FLATIME |
 			       OBD_MD_FLMTIME | OBD_MD_FLCTIME |
-			       OBD_MD_FLGROUP | OBD_MD_FLEPOCH |
-			       OBD_MD_FLDATAVERSION;
+			       OBD_MD_FLGROUP | OBD_MD_FLDATAVERSION;
 	if (dv_flags & (LL_DV_WR_FLUSH | LL_DV_RD_FLUSH)) {
 		oinfo.oi_oa->o_valid |= OBD_MD_FLFLAGS;
 		oinfo.oi_oa->o_flags |= OBD_FL_SRVLOCK;
@@ -961,32 +914,6 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 	return rc;
 }
 
-/**
-  * Performs the getattr on the inode and updates its fields.
-  * If @sync != 0, perform the getattr under the server-side lock.
-  */
-int ll_inode_getattr(struct inode *inode, struct obdo *obdo,
-		     __u64 ioepoch, int sync)
-{
-	struct lov_stripe_md *lsm;
-	int rc;
-
-	lsm = ccc_inode_lsm_get(inode);
-	rc = ll_lsm_getattr(lsm, ll_i2dtexp(inode),
-			    obdo, ioepoch, sync ? LL_DV_RD_FLUSH : 0);
-	if (rc == 0) {
-		struct ost_id *oi = lsm ? &lsm->lsm_oi : &obdo->o_oi;
-
-		obdo_refresh_inode(inode, obdo, obdo->o_valid);
-		CDEBUG(D_INODE, "objid " DOSTID " size %llu, blocks %llu, blksize %lu\n",
-		       POSTID(oi), i_size_read(inode),
-		       (unsigned long long)inode->i_blocks,
-		       1UL << inode->i_blkbits);
-	}
-	ccc_inode_lsm_put(inode, lsm);
-	return rc;
-}
-
 int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1049,7 +976,7 @@ int ll_glimpse_ioctl(struct ll_sb_info *sbi, struct lov_stripe_md *lsm,
 	struct obdo obdo = { 0 };
 	int rc;
 
-	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, &obdo, 0, 0);
+	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, &obdo, 0);
 	if (rc == 0) {
 		st->st_size   = obdo.o_size;
 		st->st_blocks = obdo.o_blocks;
@@ -1823,7 +1750,7 @@ int ll_data_version(struct inode *inode, __u64 *data_version, int flags)
 		goto out;
 	}
 
-	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, obdo, 0, flags);
+	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, obdo, flags);
 	if (rc == 0) {
 		if (!(obdo->o_valid & OBD_MD_FLDATAVERSION))
 			rc = -EOPNOTSUPP;
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 22507b9..0d1ffad 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -82,65 +82,62 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 {
 	struct ll_inode_info *lli   = ll_i2info(inode);
 	const struct lu_fid  *fid   = lu_object_fid(&clob->co_lu);
-	int result;
+	int result = 0;
 
-	result = 0;
-	if (!(lli->lli_flags & LLIF_MDS_SIZE_LOCK)) {
-		CDEBUG(D_DLMTRACE, "Glimpsing inode " DFID "\n", PFID(fid));
-		if (lli->lli_has_smd) {
-			struct cl_lock *lock = vvp_env_lock(env);
-			struct cl_lock_descr *descr = &lock->cll_descr;
-
-			/* NOTE: this looks like DLM lock request, but it may
-			 *       not be one. Due to CEF_ASYNC flag (translated
-			 *       to LDLM_FL_HAS_INTENT by osc), this is
-			 *       glimpse request, that won't revoke any
-			 *       conflicting DLM locks held. Instead,
-			 *       ll_glimpse_callback() will be called on each
-			 *       client holding a DLM lock against this file,
-			 *       and resulting size will be returned for each
-			 *       stripe. DLM lock on [0, EOF] is acquired only
-			 *       if there were no conflicting locks. If there
-			 *       were conflicting locks, enqueuing or waiting
-			 *       fails with -ENAVAIL, but valid inode
-			 *       attributes are returned anyway.
-			 */
-			*descr = whole_file;
-			descr->cld_obj   = clob;
-			descr->cld_mode  = CLM_READ;
-			descr->cld_enq_flags = CEF_ASYNC | CEF_MUST;
-			if (agl)
-				descr->cld_enq_flags |= CEF_AGL;
-			/*
-			 * CEF_ASYNC is used because glimpse sub-locks cannot
-			 * deadlock (because they never conflict with other
-			 * locks) and, hence, can be enqueued out-of-order.
-			 *
-			 * CEF_MUST protects glimpse lock from conversion into
-			 * a lockless mode.
-			 */
-			result = cl_lock_request(env, io, lock);
-			if (result < 0)
-				return result;
-
-			if (!agl) {
-				ll_merge_attr(env, inode);
-				if (i_size_read(inode) > 0 &&
-				    inode->i_blocks == 0) {
-					/*
-					 * LU-417: Add dirty pages block count
-					 * lest i_blocks reports 0, some "cp" or
-					 * "tar" may think it's a completely
-					 * sparse file and skip it.
-					 */
-					inode->i_blocks = dirty_cnt(inode);
-				}
-			}
-			cl_lock_release(env, lock);
-		} else {
-			CDEBUG(D_DLMTRACE, "No objects for inode\n");
+	CDEBUG(D_DLMTRACE, "Glimpsing inode " DFID "\n", PFID(fid));
+	if (lli->lli_has_smd) {
+		struct cl_lock *lock = vvp_env_lock(env);
+		struct cl_lock_descr *descr = &lock->cll_descr;
+
+		/* NOTE: this looks like DLM lock request, but it may
+		 *       not be one. Due to CEF_ASYNC flag (translated
+		 *       to LDLM_FL_HAS_INTENT by osc), this is
+		 *       glimpse request, that won't revoke any
+		 *       conflicting DLM locks held. Instead,
+		 *       ll_glimpse_callback() will be called on each
+		 *       client holding a DLM lock against this file,
+		 *       and resulting size will be returned for each
+		 *       stripe. DLM lock on [0, EOF] is acquired only
+		 *       if there were no conflicting locks. If there
+		 *       were conflicting locks, enqueuing or waiting
+		 *       fails with -ENAVAIL, but valid inode
+		 *       attributes are returned anyway.
+		 */
+		*descr = whole_file;
+		descr->cld_obj = clob;
+		descr->cld_mode = CLM_READ;
+		descr->cld_enq_flags = CEF_ASYNC | CEF_MUST;
+		if (agl)
+			descr->cld_enq_flags |= CEF_AGL;
+		/*
+		 * CEF_ASYNC is used because glimpse sub-locks cannot
+		 * deadlock (because they never conflict with other
+		 * locks) and, hence, can be enqueued out-of-order.
+		 *
+		 * CEF_MUST protects glimpse lock from conversion into
+		 * a lockless mode.
+		 */
+		result = cl_lock_request(env, io, lock);
+		if (result < 0)
+			return result;
+
+		if (!agl) {
 			ll_merge_attr(env, inode);
+			if (i_size_read(inode) > 0 && !inode->i_blocks) {
+				/*
+				 * LU-417: Add dirty pages block count
+				 * lest i_blocks reports 0, some "cp" or
+				 * "tar" may think it's a completely
+				 * sparse file and skip it.
+				 */
+				inode->i_blocks = dirty_cnt(inode);
+			}
 		}
+
+		cl_lock_release(env, lock);
+	} else {
+		CDEBUG(D_DLMTRACE, "No objects for inode\n");
+		ll_merge_attr(env, inode);
 	}
 
 	return result;
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
deleted file mode 100644
index 8644631..0000000
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ /dev/null
@@ -1,395 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/llite/llite_close.c
- *
- * Lustre Lite routines to issue a secondary close after writeback
- */
-
-#include <linux/module.h>
-
-#define DEBUG_SUBSYSTEM S_LLITE
-
-#include "llite_internal.h"
-
-/** records that a write is in flight */
-void vvp_write_pending(struct vvp_object *club, struct vvp_page *page)
-{
-	struct ll_inode_info *lli = ll_i2info(club->vob_inode);
-
-	spin_lock(&lli->lli_lock);
-	lli->lli_flags |= LLIF_SOM_DIRTY;
-	if (page && list_empty(&page->vpg_pending_linkage))
-		list_add(&page->vpg_pending_linkage, &club->vob_pending_list);
-	spin_unlock(&lli->lli_lock);
-}
-
-/** records that a write has completed */
-void vvp_write_complete(struct vvp_object *club, struct vvp_page *page)
-{
-	struct ll_inode_info *lli = ll_i2info(club->vob_inode);
-	int rc = 0;
-
-	spin_lock(&lli->lli_lock);
-	if (page && !list_empty(&page->vpg_pending_linkage)) {
-		list_del_init(&page->vpg_pending_linkage);
-		rc = 1;
-	}
-	spin_unlock(&lli->lli_lock);
-	if (rc)
-		ll_queue_done_writing(club->vob_inode, 0);
-}
-
-/** Queues DONE_WRITING if
- * - done writing is allowed;
- * - inode has no no dirty pages;
- */
-void ll_queue_done_writing(struct inode *inode, unsigned long flags)
-{
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct vvp_object *club = cl2vvp(ll_i2info(inode)->lli_clob);
-
-	spin_lock(&lli->lli_lock);
-	lli->lli_flags |= flags;
-
-	if ((lli->lli_flags & LLIF_DONE_WRITING) &&
-	    list_empty(&club->vob_pending_list)) {
-		struct ll_close_queue *lcq = ll_i2sbi(inode)->ll_lcq;
-
-		if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
-			CWARN("%s: file "DFID"(flags %u) Size-on-MDS valid, done writing allowed and no diry pages\n",
-			      ll_get_fsname(inode->i_sb, NULL, 0),
-			      PFID(ll_inode2fid(inode)), lli->lli_flags);
-		/* DONE_WRITING is allowed and inode has no dirty page. */
-		spin_lock(&lcq->lcq_lock);
-
-		LASSERT(list_empty(&lli->lli_close_list));
-		CDEBUG(D_INODE, "adding inode "DFID" to close list\n",
-		       PFID(ll_inode2fid(inode)));
-		list_add_tail(&lli->lli_close_list, &lcq->lcq_head);
-
-		/* Avoid a concurrent insertion into the close thread queue:
-		 * an inode is already in the close thread, open(), write(),
-		 * close() happen, epoch is closed as the inode is marked as
-		 * LLIF_EPOCH_PENDING. When pages are written inode should not
-		 * be inserted into the queue again, clear this flag to avoid
-		 * it.
-		 */
-		lli->lli_flags &= ~LLIF_DONE_WRITING;
-
-		wake_up(&lcq->lcq_waitq);
-		spin_unlock(&lcq->lcq_lock);
-	}
-	spin_unlock(&lli->lli_lock);
-}
-
-/** Pack SOM attributes info @opdata for CLOSE, DONE_WRITING rpc. */
-void ll_done_writing_attr(struct inode *inode, struct md_op_data *op_data)
-{
-	struct ll_inode_info *lli = ll_i2info(inode);
-
-	op_data->op_flags |= MF_SOM_CHANGE;
-	/* Check if Size-on-MDS attributes are valid. */
-	if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
-		CERROR("%s: inode "DFID"(flags %u) MDS holds lock on Size-on-MDS attributes\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(inode)), lli->lli_flags);
-
-	if (!cl_local_size(inode)) {
-		/* Send Size-on-MDS Attributes if valid. */
-		op_data->op_attr.ia_valid |= ATTR_MTIME_SET | ATTR_CTIME_SET |
-				ATTR_ATIME_SET | ATTR_SIZE | ATTR_BLOCKS;
-	}
-}
-
-/** Closes ioepoch and packs Size-on-MDS attribute if needed into @op_data. */
-void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
-		      struct obd_client_handle **och, unsigned long flags)
-{
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct vvp_object *club = cl2vvp(ll_i2info(inode)->lli_clob);
-
-	spin_lock(&lli->lli_lock);
-	if (!(list_empty(&club->vob_pending_list))) {
-		if (!(lli->lli_flags & LLIF_EPOCH_PENDING)) {
-			LASSERT(*och);
-			LASSERT(!lli->lli_pending_och);
-			/* Inode is dirty and there is no pending write done
-			 * request yet, DONE_WRITE is to be sent later.
-			 */
-			lli->lli_flags |= LLIF_EPOCH_PENDING;
-			lli->lli_pending_och = *och;
-			spin_unlock(&lli->lli_lock);
-
-			inode = igrab(inode);
-			LASSERT(inode);
-			goto out;
-		}
-		if (flags & LLIF_DONE_WRITING) {
-			/* Some pages are still dirty, it is early to send
-			 * DONE_WRITE. Wait until all pages will be flushed
-			 * and try DONE_WRITE again later.
-			 */
-			LASSERT(!(lli->lli_flags & LLIF_DONE_WRITING));
-			lli->lli_flags |= LLIF_DONE_WRITING;
-			spin_unlock(&lli->lli_lock);
-
-			inode = igrab(inode);
-			LASSERT(inode);
-			goto out;
-		}
-	}
-	CDEBUG(D_INODE, "Epoch %llu closed on "DFID"\n",
-	       ll_i2info(inode)->lli_ioepoch, PFID(&lli->lli_fid));
-	op_data->op_flags |= MF_EPOCH_CLOSE;
-
-	if (flags & LLIF_DONE_WRITING) {
-		LASSERT(lli->lli_flags & LLIF_SOM_DIRTY);
-		LASSERT(!(lli->lli_flags & LLIF_DONE_WRITING));
-		*och = lli->lli_pending_och;
-		lli->lli_pending_och = NULL;
-		lli->lli_flags &= ~LLIF_EPOCH_PENDING;
-	} else {
-		/* Pack Size-on-MDS inode attributes only if they has changed */
-		if (!(lli->lli_flags & LLIF_SOM_DIRTY)) {
-			spin_unlock(&lli->lli_lock);
-			goto out;
-		}
-
-		/* There is a pending DONE_WRITE -- close epoch with no
-		 * attribute change.
-		 */
-		if (lli->lli_flags & LLIF_EPOCH_PENDING) {
-			spin_unlock(&lli->lli_lock);
-			goto out;
-		}
-	}
-
-	LASSERT(list_empty(&club->vob_pending_list));
-	lli->lli_flags &= ~LLIF_SOM_DIRTY;
-	spin_unlock(&lli->lli_lock);
-	ll_done_writing_attr(inode, op_data);
-
-out:
-	return;
-}
-
-/**
- * Cliens updates SOM attributes on MDS (including llog cookies):
- * obd_getattr with no lock and md_setattr.
- */
-int ll_som_update(struct inode *inode, struct md_op_data *op_data)
-{
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ptlrpc_request *request = NULL;
-	__u32 old_flags;
-	struct obdo *oa;
-	int rc;
-
-	LASSERT(op_data);
-	if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
-		CERROR("%s: inode "DFID"(flags %u) MDS holds lock on Size-on-MDS attributes\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(inode)), lli->lli_flags);
-
-	oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-	if (!oa) {
-		CERROR("can't allocate memory for Size-on-MDS update.\n");
-		return -ENOMEM;
-	}
-
-	old_flags = op_data->op_flags;
-	op_data->op_flags = MF_SOM_CHANGE;
-
-	/* If inode is already in another epoch, skip getattr from OSTs. */
-	if (lli->lli_ioepoch == op_data->op_ioepoch) {
-		rc = ll_inode_getattr(inode, oa, op_data->op_ioepoch,
-				      old_flags & MF_GETATTR_LOCK);
-		if (rc) {
-			oa->o_valid = 0;
-			if (rc != -ENOENT)
-				CERROR("%s: inode_getattr failed - unable to send a Size-on-MDS attribute update for inode "DFID": rc = %d\n",
-				       ll_get_fsname(inode->i_sb, NULL, 0),
-				       PFID(ll_inode2fid(inode)), rc);
-		} else {
-			CDEBUG(D_INODE, "Size-on-MDS update on "DFID"\n",
-			       PFID(&lli->lli_fid));
-		}
-		/* Install attributes into op_data. */
-		md_from_obdo(op_data, oa, oa->o_valid);
-	}
-
-	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data,
-			NULL, 0, NULL, 0, &request, NULL);
-	ptlrpc_req_finished(request);
-
-	kmem_cache_free(obdo_cachep, oa);
-	return rc;
-}
-
-/**
- * Closes the ioepoch and packs all the attributes into @op_data for
- * DONE_WRITING rpc.
- */
-static void ll_prepare_done_writing(struct inode *inode,
-				    struct md_op_data *op_data,
-				    struct obd_client_handle **och)
-{
-	ll_ioepoch_close(inode, op_data, och, LLIF_DONE_WRITING);
-	/* If there is no @och, we do not do D_W yet. */
-	if (!*och)
-		return;
-
-	ll_pack_inode2opdata(inode, op_data, &(*och)->och_fh);
-	ll_prep_md_op_data(op_data, inode, NULL, NULL,
-			   0, 0, LUSTRE_OPC_ANY, NULL);
-}
-
-/** Send a DONE_WRITING rpc. */
-static void ll_done_writing(struct inode *inode)
-{
-	struct obd_client_handle *och = NULL;
-	struct md_op_data *op_data;
-	int rc;
-
-	LASSERT(exp_connect_som(ll_i2mdexp(inode)));
-
-	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
-	if (!op_data)
-		return;
-
-	ll_prepare_done_writing(inode, op_data, &och);
-	/* If there is no @och, we do not do D_W yet. */
-	if (!och)
-		goto out;
-
-	rc = md_done_writing(ll_i2sbi(inode)->ll_md_exp, op_data, NULL);
-	if (rc == -EAGAIN)
-		/* MDS has instructed us to obtain Size-on-MDS attribute from
-		 * OSTs and send setattr to back to MDS.
-		 */
-		rc = ll_som_update(inode, op_data);
-	else if (rc) {
-		CERROR("%s: inode "DFID" mdc done_writing failed: rc = %d\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       PFID(ll_inode2fid(inode)), rc);
-	}
-out:
-	ll_finish_md_op_data(op_data);
-	if (och) {
-		md_clear_open_replay_data(ll_i2sbi(inode)->ll_md_exp, och);
-		kfree(och);
-	}
-}
-
-static struct ll_inode_info *ll_close_next_lli(struct ll_close_queue *lcq)
-{
-	struct ll_inode_info *lli = NULL;
-
-	spin_lock(&lcq->lcq_lock);
-
-	if (!list_empty(&lcq->lcq_head)) {
-		lli = list_entry(lcq->lcq_head.next, struct ll_inode_info,
-				 lli_close_list);
-		list_del_init(&lli->lli_close_list);
-	} else if (atomic_read(&lcq->lcq_stop)) {
-		lli = ERR_PTR(-EALREADY);
-	}
-
-	spin_unlock(&lcq->lcq_lock);
-	return lli;
-}
-
-static int ll_close_thread(void *arg)
-{
-	struct ll_close_queue *lcq = arg;
-
-	complete(&lcq->lcq_comp);
-
-	while (1) {
-		struct l_wait_info lwi = { 0 };
-		struct ll_inode_info *lli;
-		struct inode *inode;
-
-		l_wait_event_exclusive(lcq->lcq_waitq,
-				       (lli = ll_close_next_lli(lcq)) != NULL,
-				       &lwi);
-		if (IS_ERR(lli))
-			break;
-
-		inode = ll_info2i(lli);
-		CDEBUG(D_INFO, "done_writing for inode "DFID"\n",
-		       PFID(ll_inode2fid(inode)));
-		ll_done_writing(inode);
-		iput(inode);
-	}
-
-	CDEBUG(D_INFO, "ll_close exiting\n");
-	complete(&lcq->lcq_comp);
-	return 0;
-}
-
-int ll_close_thread_start(struct ll_close_queue **lcq_ret)
-{
-	struct ll_close_queue *lcq;
-	struct task_struct *task;
-
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CLOSE_THREAD))
-		return -EINTR;
-
-	lcq = kzalloc(sizeof(*lcq), GFP_NOFS);
-	if (!lcq)
-		return -ENOMEM;
-
-	spin_lock_init(&lcq->lcq_lock);
-	INIT_LIST_HEAD(&lcq->lcq_head);
-	init_waitqueue_head(&lcq->lcq_waitq);
-	init_completion(&lcq->lcq_comp);
-
-	task = kthread_run(ll_close_thread, lcq, "ll_close");
-	if (IS_ERR(task)) {
-		kfree(lcq);
-		return PTR_ERR(task);
-	}
-
-	wait_for_completion(&lcq->lcq_comp);
-	*lcq_ret = lcq;
-	return 0;
-}
-
-void ll_close_thread_shutdown(struct ll_close_queue *lcq)
-{
-	init_completion(&lcq->lcq_comp);
-	atomic_inc(&lcq->lcq_stop);
-	wake_up(&lcq->lcq_waitq);
-	wait_for_completion(&lcq->lcq_comp);
-	kfree(lcq);
-}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 3e98bd6..cd89926 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -98,28 +98,17 @@ struct ll_grouplock {
 };
 
 enum lli_flags {
-	/* MDS has an authority for the Size-on-MDS attributes. */
-	LLIF_MDS_SIZE_LOCK      = (1 << 0),
-	/* Epoch close is postponed. */
-	LLIF_EPOCH_PENDING      = (1 << 1),
-	/* DONE WRITING is allowed. */
-	LLIF_DONE_WRITING       = (1 << 2),
-	/* Sizeon-on-MDS attributes are changed. An attribute update needs to
-	 * be sent to MDS.
-	 */
-	LLIF_SOM_DIRTY	  = (1 << 3),
 	/* File data is modified. */
-	LLIF_DATA_MODIFIED      = (1 << 4),
+	LLIF_DATA_MODIFIED	= BIT(0),
 	/* File is being restored */
-	LLIF_FILE_RESTORING	= (1 << 5),
+	LLIF_FILE_RESTORING	= BIT(1),
 	/* Xattr cache is attached to the file */
-	LLIF_XATTR_CACHE	= (1 << 6),
+	LLIF_XATTR_CACHE	= BIT(2),
 };
 
 struct ll_inode_info {
 	__u32				lli_inode_magic;
 	__u32				lli_flags;
-	__u64				lli_ioepoch;
 
 	spinlock_t			lli_lock;
 	struct posix_acl		*lli_posix_acl;
@@ -129,14 +118,6 @@ struct ll_inode_info {
 	/* master inode fid for stripe directory */
 	struct lu_fid		   lli_pfid;
 
-	struct list_head	      lli_close_list;
-
-	/* handle is to be sent to MDS later on done_writing and setattr.
-	 * Open handle data are needed for the recovery to reconstruct
-	 * the inode state on the MDS. XXX: recovery is not ready yet.
-	 */
-	struct obd_client_handle       *lli_pending_och;
-
 	/* We need all three because every inode may be opened in different
 	 * modes
 	 */
@@ -400,7 +381,7 @@ enum stats_track_type {
 #define LL_SBI_LOCALFLOCK       0x200 /* Local flocks support by kernel */
 #define LL_SBI_LRU_RESIZE       0x400 /* lru resize support */
 #define LL_SBI_LAZYSTATFS       0x800 /* lazystatfs mount option */
-#define LL_SBI_SOM_PREVIEW     0x1000 /* SOM preview mount option */
+/*	LL_SBI_SOM_PREVIEW     0x1000    SOM preview mount option, obsolete */
 #define LL_SBI_32BIT_API       0x2000 /* generate 32 bit inodes. */
 #define LL_SBI_64BIT_HASH      0x4000 /* support 64-bits dir hash/offset */
 #define LL_SBI_AGL_ENABLED     0x8000 /* enable agl */
@@ -466,10 +447,10 @@ struct ll_sb_info {
 
 	int		       ll_flags;
 	unsigned int		  ll_umounting:1,
-				  ll_xattr_cache_enabled:1;
-	struct lustre_client_ocd  ll_lco;
+				  ll_xattr_cache_enabled:1,
+				  ll_client_common_fill_super_succeeded:1;
 
-	struct ll_close_queue    *ll_lcq;
+	struct lustre_client_ocd  ll_lco;
 
 	struct lprocfs_stats     *ll_stats; /* lprocfs stats counter */
 
@@ -764,15 +745,8 @@ int ll_file_open(struct inode *inode, struct file *file);
 int ll_file_release(struct inode *inode, struct file *file);
 int ll_glimpse_ioctl(struct ll_sb_info *sbi,
 		     struct lov_stripe_md *lsm, lstat_t *st);
-void ll_ioepoch_open(struct ll_inode_info *lli, __u64 ioepoch);
 int ll_release_openhandle(struct inode *, struct lookup_intent *);
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
-void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
-		      struct obd_client_handle **och, unsigned long flags);
-void ll_done_writing_attr(struct inode *inode, struct md_op_data *op_data);
-int ll_som_update(struct inode *inode, struct md_op_data *op_data);
-int ll_inode_getattr(struct inode *inode, struct obdo *obdo,
-		     __u64 ioepoch, int sync);
 void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
 			  struct lustre_handle *fh);
 int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat);
@@ -891,18 +865,6 @@ int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid);
 /* llite/symlink.c */
 extern const struct inode_operations ll_fast_symlink_inode_operations;
 
-/* llite/llite_close.c */
-struct ll_close_queue {
-	spinlock_t		lcq_lock;
-	struct list_head		lcq_head;
-	wait_queue_head_t		lcq_waitq;
-	struct completion	lcq_comp;
-	atomic_t		lcq_stop;
-};
-
-void vvp_write_pending(struct vvp_object *club, struct vvp_page *page);
-void vvp_write_complete(struct vvp_object *club, struct vvp_page *page);
-
 /**
  * IO arguments for various VFS I/O interfaces.
  */
@@ -956,10 +918,6 @@ static inline struct vvp_io_args *ll_env_args(const struct lu_env *env,
 	return via;
 }
 
-void ll_queue_done_writing(struct inode *inode, unsigned long flags);
-void ll_close_thread_shutdown(struct ll_close_queue *lcq);
-int ll_close_thread_start(struct ll_close_queue **lcq_ret);
-
 /* llite/llite_mmap.c */
 
 int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6bb41b0..4f83275 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -193,9 +193,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_OPEN_BY_FID |
 				  OBD_CONNECT_DIR_STRIPE;
 
-	if (sbi->ll_flags & LL_SBI_SOM_PREVIEW)
-		data->ocd_connect_flags |= OBD_CONNECT_SOM;
-
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 #ifdef CONFIG_FS_POSIX_ACL
@@ -357,9 +354,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_JOBSTATS | OBD_CONNECT_LVB_TYPE |
 				  OBD_CONNECT_LAYOUTLOCK | OBD_CONNECT_PINGLESS;
 
-	if (sbi->ll_flags & LL_SBI_SOM_PREVIEW)
-		data->ocd_connect_flags |= OBD_CONNECT_SOM;
-
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_CKSUM)) {
 		/* OBD_CONNECT_CKSUM should always be set, even if checksums are
 		 * disabled by default, because it can still be enabled on the
@@ -488,12 +482,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 		goto out_root;
 	}
 
-	err = ll_close_thread_start(&sbi->ll_lcq);
-	if (err) {
-		CERROR("cannot start close thread: rc %d\n", err);
-		goto out_root;
-	}
-
 	checksum = sbi->ll_flags & LL_SBI_CHECKSUM;
 	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
 				 KEY_CHECKSUM, sizeof(checksum), &checksum,
@@ -633,8 +621,6 @@ static void client_common_put_super(struct super_block *sb)
 {
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 
-	ll_close_thread_shutdown(sbi->ll_lcq);
-
 	cl_sb_fini(sb);
 
 	obd_fid_fini(sbi->ll_dt_exp->exp_obd);
@@ -766,11 +752,6 @@ static int ll_options(char *options, int *flags)
 			*flags &= ~tmp;
 			goto next;
 		}
-		tmp = ll_set_opt("som_preview", s1, LL_SBI_SOM_PREVIEW);
-		if (tmp) {
-			*flags |= tmp;
-			goto next;
-		}
 		tmp = ll_set_opt("32bitapi", s1, LL_SBI_32BIT_API);
 		if (tmp) {
 			*flags |= tmp;
@@ -804,14 +785,11 @@ void ll_lli_init(struct ll_inode_info *lli)
 {
 	lli->lli_inode_magic = LLI_INODE_MAGIC;
 	lli->lli_flags = 0;
-	lli->lli_ioepoch = 0;
 	lli->lli_maxbytes = MAX_LFS_FILESIZE;
 	spin_lock_init(&lli->lli_lock);
 	lli->lli_posix_acl = NULL;
 	/* Do not set lli_fid, it has been initialized already. */
 	fid_zero(&lli->lli_pfid);
-	INIT_LIST_HEAD(&lli->lli_close_list);
-	lli->lli_pending_och = NULL;
 	lli->lli_mds_read_och = NULL;
 	lli->lli_mds_write_och = NULL;
 	lli->lli_mds_exec_och = NULL;
@@ -941,6 +919,8 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 
 	/* connections, registrations, sb setup */
 	err = client_common_fill_super(sb, md, dt, mnt);
+	if (!err)
+		sbi->ll_client_common_fill_super_succeeded = 1;
 
 out_free:
 	kfree(md);
@@ -1002,7 +982,7 @@ void ll_put_super(struct super_block *sb)
 		}
 	}
 
-	if (sbi->ll_lcq) {
+	if (sbi->ll_client_common_fill_super_succeeded) {
 		/* Only if client_common_fill_super succeeded */
 		client_common_put_super(sb);
 	}
@@ -1272,9 +1252,6 @@ void ll_clear_inode(struct inode *inode)
 		LASSERT(lli->lli_opendir_pid == 0);
 	}
 
-	spin_lock(&lli->lli_lock);
-	ll_i2info(inode)->lli_flags &= ~LLIF_MDS_SIZE_LOCK;
-	spin_unlock(&lli->lli_lock);
 	md_null_inode(sbi->ll_md_exp, ll_inode2fid(inode));
 
 	LASSERT(!lli->lli_open_fd_write_count);
@@ -1369,48 +1346,12 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
 	rc = simple_setattr(dentry, &op_data->op_attr);
 	op_data->op_attr.ia_valid = ia_valid;
 
-	/* Extract epoch data if obtained. */
-	op_data->op_handle = md.body->mbo_handle;
-	op_data->op_ioepoch = md.body->mbo_ioepoch;
-
 	rc = ll_update_inode(inode, &md);
 	ptlrpc_req_finished(request);
 
 	return rc;
 }
 
-/* Close IO epoch and send Size-on-MDS attribute update. */
-static int ll_setattr_done_writing(struct inode *inode,
-				   struct md_op_data *op_data,
-				   struct md_open_data *mod)
-{
-	struct ll_inode_info *lli = ll_i2info(inode);
-	int rc = 0;
-
-	if (!S_ISREG(inode->i_mode))
-		return 0;
-
-	CDEBUG(D_INODE, "Epoch %llu closed on "DFID" for truncate\n",
-	       op_data->op_ioepoch, PFID(&lli->lli_fid));
-
-	op_data->op_flags = MF_EPOCH_CLOSE;
-	ll_done_writing_attr(inode, op_data);
-	ll_pack_inode2opdata(inode, op_data, NULL);
-
-	rc = md_done_writing(ll_i2sbi(inode)->ll_md_exp, op_data, mod);
-	if (rc == -EAGAIN)
-		/* MDS has instructed us to obtain Size-on-MDS attribute
-		 * from OSTs and send setattr to back to MDS.
-		 */
-		rc = ll_som_update(inode, op_data);
-	else if (rc) {
-		CERROR("%s: inode "DFID" mdc truncate failed: rc = %d\n",
-		       ll_i2sbi(inode)->ll_md_exp->exp_obd->obd_name,
-		       PFID(ll_inode2fid(inode)), rc);
-	}
-	return rc;
-}
-
 /* If this inode has objects allocated to it (lsm != NULL), then the OST
  * object(s) determine the file size and mtime.  Otherwise, the MDS will
  * keep these values until such a time that objects are allocated for it.
@@ -1433,7 +1374,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	struct md_op_data *op_data = NULL;
 	struct md_open_data *mod = NULL;
 	bool file_is_released = false;
-	int rc = 0, rc1 = 0;
+	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "%s: setattr inode "DFID"(%p) from %llu to %llu, valid %x, hsm_import %d\n",
 	       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid), inode,
@@ -1536,11 +1477,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 
 	memcpy(&op_data->op_attr, attr, sizeof(*attr));
 
-	/* Open epoch for truncate. */
-	if (exp_connect_som(ll_i2mdexp(inode)) && !hsm_import &&
-	    (attr->ia_valid & (ATTR_SIZE | ATTR_MTIME | ATTR_MTIME_SET)))
-		op_data->op_flags = MF_EPOCH_OPEN;
-
 	rc = ll_md_setattr(dentry, op_data, &mod);
 	if (rc)
 		goto out;
@@ -1552,7 +1488,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		spin_unlock(&lli->lli_lock);
 	}
 
-	ll_ioepoch_open(lli, op_data->op_ioepoch);
 	if (!S_ISREG(inode->i_mode) || file_is_released) {
 		rc = 0;
 		goto out;
@@ -1575,12 +1510,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 			up_write(&lli->lli_trunc_sem);
 	}
 out:
-	if (op_data->op_ioepoch) {
-		rc1 = ll_setattr_done_writing(inode, op_data, mod);
-		if (!rc)
-			rc = rc1;
-	}
-	ll_finish_md_op_data(op_data);
+	if (op_data)
+		ll_finish_md_op_data(op_data);
 
 	if (!S_ISDIR(inode->i_mode)) {
 		inode_lock(inode);
@@ -1828,48 +1759,11 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	LASSERT(fid_seq(&lli->lli_fid) != 0);
 
 	if (body->mbo_valid & OBD_MD_FLSIZE) {
-		if (exp_connect_som(ll_i2mdexp(inode)) &&
-		    S_ISREG(inode->i_mode)) {
-			struct lustre_handle lockh;
-			enum ldlm_mode mode;
-
-			/* As it is possible a blocking ast has been processed
-			 * by this time, we need to check there is an UPDATE
-			 * lock on the client and set LLIF_MDS_SIZE_LOCK holding
-			 * it.
-			 */
-			mode = ll_take_md_lock(inode, MDS_INODELOCK_UPDATE,
-					       &lockh, LDLM_FL_CBPENDING,
-					       LCK_CR | LCK_CW |
-					       LCK_PR | LCK_PW);
-			if (mode) {
-				if (lli->lli_flags & (LLIF_DONE_WRITING |
-						      LLIF_EPOCH_PENDING |
-						      LLIF_SOM_DIRTY)) {
-					CERROR("%s: inode "DFID" flags %u still has size authority! do not trust the size got from MDS\n",
-					       sbi->ll_md_exp->exp_obd->obd_name,
-					       PFID(ll_inode2fid(inode)),
-					       lli->lli_flags);
-				} else {
-					/* Use old size assignment to avoid
-					 * deadlock bz14138 & bz14326
-					 */
-					i_size_write(inode, body->mbo_size);
-					spin_lock(&lli->lli_lock);
-					lli->lli_flags |= LLIF_MDS_SIZE_LOCK;
-					spin_unlock(&lli->lli_lock);
-				}
-				ldlm_lock_decref(&lockh, mode);
-			}
-		} else {
-			/* Use old size assignment to avoid
-			 * deadlock bz14138 & bz14326
-			 */
-			i_size_write(inode, body->mbo_size);
+		i_size_write(inode, body->mbo_size);
 
-			CDEBUG(D_VFSTRACE, "inode=%lu, updating i_size %llu\n",
-			       inode->i_ino, (unsigned long long)body->mbo_size);
-		}
+		CDEBUG(D_VFSTRACE, "inode=" DFID ", updating i_size %llu\n",
+		       PFID(ll_inode2fid(inode)),
+		       (unsigned long long)body->mbo_size);
 
 		if (body->mbo_valid & OBD_MD_FLBLOCKS)
 			inode->i_blocks = body->mbo_blocks;
@@ -2164,7 +2058,6 @@ void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 		return;
 
 	op_data->op_fid1 = body->mbo_fid1;
-	op_data->op_ioepoch = body->mbo_ioepoch;
 	op_data->op_handle = body->mbo_handle;
 	op_data->op_mod_time = get_seconds();
 	md_close(exp, op_data, NULL, &close_req);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index dfa36d3..9cc4bb4 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -254,14 +254,6 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 				       PFID(ll_inode2fid(inode)), rc);
 		}
 
-		if (bits & MDS_INODELOCK_UPDATE) {
-			struct ll_inode_info *lli = ll_i2info(inode);
-
-			spin_lock(&lli->lli_lock);
-			lli->lli_flags &= ~LLIF_MDS_SIZE_LOCK;
-			spin_unlock(&lli->lli_lock);
-		}
-
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
 			struct ll_inode_info *lli = ll_i2info(inode);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 8aa8ecc..cab95ac 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -521,11 +521,10 @@ static void vvp_pgcache_page_show(const struct lu_env *env,
 
 	vpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
 	vmpage = vpg->vpg_page;
-	seq_printf(seq, " %5i | %p %p %s %s %s %s | %p "DFID"(%p) %lu %u [",
+	seq_printf(seq, " %5i | %p %p %s %s %s | %p " DFID "(%p) %lu %u [",
 		   0 /* gen */,
 		   vpg, page,
 		   "none",
-		   vpg->vpg_write_queued ? "wq" : "- ",
 		   vpg->vpg_defer_uptodate ? "du" : "- ",
 		   PageWriteback(vmpage) ? "wb" : "-",
 		   vmpage, PFID(ll_inode2fid(vmpage->mapping->host)),
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 5802da8..47d035e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -209,14 +209,6 @@ struct vvp_object {
 	struct inode           *vob_inode;
 
 	/**
-	 * A list of dirty pages pending IO in the cache. Used by
-	 * SOM. Protected by ll_inode_info::lli_lock.
-	 *
-	 * \see vvp_page::vpg_pending_linkage
-	 */
-	struct list_head	vob_pending_list;
-
-	/**
 	 * Number of transient pages.  This is no longer protected by i_sem,
 	 * and needs to be atomic.  This is not actually used for anything,
 	 * and can probably be removed.
@@ -249,15 +241,7 @@ struct vvp_object {
 struct vvp_page {
 	struct cl_page_slice vpg_cl;
 	unsigned int	vpg_defer_uptodate:1,
-			vpg_ra_used:1,
-			vpg_write_queued:1;
-	/**
-	 * Non-empty iff this page is already counted in
-	 * vvp_object::vob_pending_list. This list is only used as a flag,
-	 * that is, never iterated through, only checked for list_empty(), but
-	 * having a list is useful for debugging.
-	 */
-	struct list_head	   vpg_pending_linkage;
+			vpg_ra_used:1;
 	/** VM page */
 	struct page	  *vpg_page;
 };
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 2ab4503..dbc4c26 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -807,16 +807,11 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 				  struct cl_page *page)
 {
-	struct vvp_page *vpg;
 	struct page *vmpage = page->cp_vmpage;
-	struct cl_object *clob = cl_io_top(io)->ci_obj;
 
 	SetPageUptodate(vmpage);
 	set_page_dirty(vmpage);
 
-	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
-	vvp_write_pending(cl2vvp(clob), vpg);
-
 	cl_page_disown(env, io, page);
 
 	/* held in ll_cl_init() */
@@ -1051,13 +1046,7 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
 				    struct cl_page *page)
 {
-	struct vvp_page *vpg;
-	struct cl_object *clob = cl_io_top(io)->ci_obj;
-
 	set_page_dirty(page->cp_vmpage);
-
-	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
-	vvp_write_pending(cl2vvp(clob), vpg);
 }
 
 static int vvp_io_fault_start(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index b57195d..3214885 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -65,8 +65,7 @@ static int vvp_object_print(const struct lu_env *env, void *cookie,
 	struct inode	 *inode = obj->vob_inode;
 	struct ll_inode_info *lli;
 
-	(*p)(env, cookie, "(%s %d %d) inode: %p ",
-	     list_empty(&obj->vob_pending_list) ? "-" : "+",
+	(*p)(env, cookie, "(%d %d) inode: %p ",
 	     atomic_read(&obj->vob_transient_pages),
 	     atomic_read(&obj->vob_mmap_cnt), inode);
 	if (inode) {
@@ -240,7 +239,6 @@ static int vvp_object_init(const struct lu_env *env, struct lu_object *obj,
 		const struct cl_object_conf *cconf;
 
 		cconf = lu2cl_conf(conf);
-		INIT_LIST_HEAD(&vob->vob_pending_list);
 		lu_object_add(obj, below);
 		result = vvp_object_init0(env, vob, cconf);
 	} else {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 5d79efc..68f8990 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -162,8 +162,6 @@ static void vvp_page_delete(const struct lu_env *env,
 	LASSERT((struct cl_page *)vmpage->private == page);
 	LASSERT(inode == vvp_object_inode(obj));
 
-	vvp_write_complete(cl2vvp(obj), cl2vvp_page(slice));
-
 	/* Drop the reference count held in vvp_page_init */
 	refc = atomic_dec_return(&page->cp_ref);
 	LASSERTF(refc >= 1, "page = %p, refc = %d\n", page, refc);
@@ -221,8 +219,6 @@ static int vvp_page_prep_write(const struct lu_env *env,
 	if (!pg->cp_sync_io)
 		set_page_writeback(vmpage);
 
-	vvp_write_pending(cl2vvp(slice->cpl_obj), cl2vvp_page(slice));
-
 	return 0;
 }
 
@@ -290,19 +286,6 @@ static void vvp_page_completion_write(const struct lu_env *env,
 
 	CL_PAGE_HEADER(D_PAGE, env, pg, "completing WRITE with %d\n", ioret);
 
-	/*
-	 * TODO: Actually it makes sense to add the page into oap pending
-	 * list again and so that we don't need to take the page out from
-	 * SoM write pending list, if we just meet a recoverable error,
-	 * -ENOMEM, etc.
-	 * To implement this, we just need to return a non zero value in
-	 * ->cpo_completion method. The underlying transfer should be notified
-	 * and then re-add the page into pending transfer queue.  -jay
-	 */
-
-	vpg->vpg_write_queued = 0;
-	vvp_write_complete(cl2vvp(slice->cpl_obj), vpg);
-
 	if (pg->cp_sync_io) {
 		LASSERT(PageLocked(vmpage));
 		LASSERT(!PageWriteback(vmpage));
@@ -344,7 +327,6 @@ static int vvp_page_make_ready(const struct lu_env *env,
 		LASSERT(pg->cp_state == CPS_CACHED);
 		/* This actually clears the dirty bit in the radix tree. */
 		set_page_writeback(vmpage);
-		vvp_write_pending(cl2vvp(slice->cpl_obj), cl2vvp_page(slice));
 		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
 	} else if (pg->cp_state == CPS_PAGEOUT) {
 		/* is it possible for osc_flush_async_page() to already
@@ -381,9 +363,8 @@ static int vvp_page_print(const struct lu_env *env,
 	struct vvp_page *vpg = cl2vvp_page(slice);
 	struct page     *vmpage = vpg->vpg_page;
 
-	(*printer)(env, cookie, LUSTRE_VVP_NAME "-page@%p(%d:%d:%d) vm@%p ",
-		   vpg, vpg->vpg_defer_uptodate, vpg->vpg_ra_used,
-		   vpg->vpg_write_queued, vmpage);
+	(*printer)(env, cookie, LUSTRE_VVP_NAME "-page@%p(%d:%d) vm@%p ",
+		   vpg, vpg->vpg_defer_uptodate, vpg->vpg_ra_used, vmpage);
 	if (vmpage) {
 		(*printer)(env, cookie, "%lx %d:%d %lx %lu %slru",
 			   (long)vmpage->flags, page_count(vmpage),
@@ -542,7 +523,6 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	vpg->vpg_page = vmpage;
 	get_page(vmpage);
 
-	INIT_LIST_HEAD(&vpg->vpg_pending_linkage);
 	if (page->cp_type == CPT_CACHEABLE) {
 		/* in cache, decref in vvp_page_delete */
 		atomic_inc(&page->cp_ref);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
index e3f4c79..a8892e4 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_req.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_req.c
@@ -56,8 +56,6 @@ static inline struct vvp_req *cl2vvp_req(const struct cl_req_slice *slice)
  *
  *    - o_parent_ver
  *
- *    - o_ioepoch,
- *
  */
 static void vvp_req_attr_set(const struct lu_env *env,
 			     const struct cl_req_slice *slice,
@@ -72,14 +70,9 @@ static void vvp_req_attr_set(const struct lu_env *env,
 	inode = vvp_object_inode(obj);
 	valid_flags = OBD_MD_FLTYPE;
 
-	if (slice->crs_req->crq_type == CRT_WRITE) {
-		if (flags & OBD_MD_FLEPOCH) {
-			oa->o_valid |= OBD_MD_FLEPOCH;
-			oa->o_ioepoch = ll_i2info(inode)->lli_ioepoch;
-			valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
-				       OBD_MD_FLUID | OBD_MD_FLGID;
-		}
-	}
+	if (slice->crs_req->crq_type == CRT_WRITE)
+		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
+			       OBD_MD_FLUID | OBD_MD_FLGID;
 	obdo_from_inode(oa, inode, valid_flags & flags);
 	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
-- 
1.7.1
