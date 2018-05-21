From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 08/30] staging: lustre: discard cfs_cap_t,
 use kernel_cap_t
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731265.24196.15391613601574901407.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

lustre only sends 32bits of capabilities in on-the-wire RPC calls.
It current strips off higher bits and uses a 32bit cfs_cap_t
throughout.
Though there is a small memory cost, it is cleaner to use
kernel_cap_t throughout and only truncate when marshalling
data for RPC calls.

So this patch replaces cfs_cap_t with kernel_cap_t throughout,
and where a cfs_cap_t was previous stored in a __u32, we now
store cap.cap[0] instead.

With this, we can remove include/linux/libcfs/curproc.h

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |   69 --------------------
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 
 drivers/staging/lustre/lustre/include/obd.h        |    4 +
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 -
 drivers/staging/lustre/lustre/llite/dir.c          |    2 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 -
 drivers/staging/lustre/lustre/llite/namei.c        |    2 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    8 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    4 +
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   17 +++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 -
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    2 -
 13 files changed, 24 insertions(+), 93 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/curproc.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
deleted file mode 100644
index fc6f6eb2d5fe..000000000000
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ /dev/null
@@ -1,69 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
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
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/include/libcfs/curproc.h
- *
- * Lustre curproc API declaration
- *
- * Author: Nikita Danilov <nikita@clusterfs.com>
- */
-
-#ifndef __LIBCFS_CURPROC_H__
-#define __LIBCFS_CURPROC_H__
-
-/*
- * Plus, platform-specific constant
- *
- * and opaque scalar type
- *
- * kernel_cap_t
- */
-
-typedef u32 cfs_cap_t;
-
-static inline cfs_cap_t cfs_curproc_cap_pack(void)
-{
-	/* cfs_cap_t is only the first word of kernel_cap_t */
-	return (cfs_cap_t)(current_cap().cap[0]);
-}
-
-/* __LIBCFS_CURPROC_H__ */
-#endif
-/*
- * Local variables:
- * c-indentation-style: "K&R"
- * c-basic-offset: 8
- * tab-width: 8
- * fill-column: 80
- * scroll-step: 1
- * End:
- */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4c91ef45abb6..7259544e4c32 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -86,7 +86,6 @@
 #include <linux/libcfs/libcfs_string.h>
 #include <linux/libcfs/libcfs_hash.h>
 #include <linux/libcfs/libcfs_fail.h>
-#include <linux/libcfs/curproc.h>
 
 #define LIBCFS_VERSION "0.7.0"
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index fe21987a3f9f..da99a0f02b6c 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -717,7 +717,7 @@ struct md_op_data {
 	__u32		   op_suppgids[2];
 	__u32		   op_fsuid;
 	__u32		   op_fsgid;
-	cfs_cap_t	       op_cap;
+	kernel_cap_t	       op_cap;
 	void		   *op_data;
 	size_t			op_data_size;
 
@@ -912,7 +912,7 @@ struct md_ops {
 		     struct md_open_data *, struct ptlrpc_request **);
 	int (*create)(struct obd_export *, struct md_op_data *,
 		      const void *, size_t, umode_t, uid_t, gid_t,
-		      cfs_cap_t, __u64, struct ptlrpc_request **);
+		      kernel_cap_t, __u64, struct ptlrpc_request **);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
 		       const union ldlm_policy_data *, struct md_op_data *,
 		       struct lustre_handle *, __u64);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index a76f016a8c45..a3b1465121e5 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1226,7 +1226,7 @@ static inline int md_close(struct obd_export *exp, struct md_op_data *op_data,
 
 static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
 			    const void *data, size_t datalen, umode_t mode,
-			    uid_t uid, gid_t gid, cfs_cap_t cap_effective,
+			    uid_t uid, gid_t gid, kernel_cap_t cap_effective,
 			    __u64 rdev, struct ptlrpc_request **request)
 {
 	int rc;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 80d44ca9516a..688dddf3ca47 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -445,7 +445,7 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 	err = md_create(sbi->ll_md_exp, op_data, lump, sizeof(*lump), mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
-			cfs_curproc_cap_pack(), 0, &request);
+			current_cap(), 0, &request);
 	ll_finish_md_op_data(op_data);
 
 	err = ll_prep_inode(&inode, request, parent->i_sb, NULL);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 60dbe888e336..bdb53ab77e58 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2336,7 +2336,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_mod_time = ktime_get_real_seconds();
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
-	op_data->op_cap = cfs_curproc_cap_pack();
+	op_data->op_cap = current_cap();
 	if ((opc == LUSTRE_OPC_CREATE) && name &&
 	    filename_is_volatile(name, namelen, &op_data->op_mds))
 		op_data->op_bias |= MDS_CREATE_VOLATILE;
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 9ac7f097802d..d5f6d20afe8c 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -885,7 +885,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	err = md_create(sbi->ll_md_exp, op_data, tgt, tgt_len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
-			cfs_curproc_cap_pack(), rdev, &request);
+			current_cap(), rdev, &request);
 	ll_finish_md_op_data(op_data);
 	if (err < 0 && err != -EREMOTE)
 		goto err_exit;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index b55be6cb52bb..6ab9cdb6f9d1 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1598,7 +1598,7 @@ lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 
 static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		      const void *data, size_t datalen, umode_t mode,
-		      uid_t uid, gid_t gid, cfs_cap_t cap_effective,
+		      uid_t uid, gid_t gid, kernel_cap_t cap_effective,
 		      __u64 rdev, struct ptlrpc_request **request)
 {
 	struct obd_device       *obd = exp->exp_obd;
@@ -1783,7 +1783,7 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
-	op_data->op_cap = cfs_curproc_cap_pack();
+	op_data->op_cap = current_cap();
 	if (op_data->op_mea2) {
 		struct lmv_stripe_md *lsm = op_data->op_mea2;
 		const struct lmv_oinfo *oinfo;
@@ -1835,7 +1835,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
-	op_data->op_cap = cfs_curproc_cap_pack();
+	op_data->op_cap = current_cap();
 
 	if (op_data->op_cli_flags & CLI_MIGRATE) {
 		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID " DFID "\n",
@@ -2413,7 +2413,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
-	op_data->op_cap = cfs_curproc_cap_pack();
+	op_data->op_cap = current_cap();
 
 	/*
 	 * If child's fid is given, cancel unused locks for it if it is from
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 88ee32717688..28924e927b50 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -50,7 +50,7 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		      void *ea, size_t ealen);
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode, uid_t uid,
-		     gid_t gid, cfs_cap_t capability, __u64 rdev);
+		     gid_t gid, kernel_cap_t capability, __u64 rdev);
 void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		   umode_t mode, __u64 rdev, __u64 flags, const void *data,
 		   size_t datalen);
@@ -97,7 +97,7 @@ void mdc_replay_open(struct ptlrpc_request *req);
 
 int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	       const void *data, size_t datalen, umode_t mode, uid_t uid,
-	       gid_t gid, cfs_cap_t capability, __u64 rdev,
+	       gid_t gid, kernel_cap_t capability, __u64 rdev,
 	       struct ptlrpc_request **request);
 int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 	     struct ptlrpc_request **request);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 46eefdc09e3a..d582968987ff 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -49,7 +49,7 @@ static void __mdc_pack_body(struct mdt_body *b, __u32 suppgid)
 	b->mbo_gid = from_kgid(&init_user_ns, current_gid());
 	b->mbo_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	b->mbo_fsgid = from_kgid(&init_user_ns, current_fsgid());
-	b->mbo_capability = cfs_curproc_cap_pack();
+	b->mbo_capability = current_cap().cap[0];
 }
 
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
@@ -126,7 +126,8 @@ void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
 /* packing of MDS records */
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode,
-		     uid_t uid, gid_t gid, cfs_cap_t cap_effective, __u64 rdev)
+		     uid_t uid, gid_t gid, kernel_cap_t cap_effective,
+		     __u64 rdev)
 {
 	struct mdt_rec_create	*rec;
 	char			*tmp;
@@ -138,7 +139,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_opcode   = REINT_CREATE;
 	rec->cr_fsuid    = uid;
 	rec->cr_fsgid    = gid;
-	rec->cr_cap      = cap_effective;
+	rec->cr_cap      = cap_effective.cap[0];
 	rec->cr_fid1     = op_data->op_fid1;
 	rec->cr_fid2     = op_data->op_fid2;
 	rec->cr_mode     = mode;
@@ -203,7 +204,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_opcode   = REINT_OPEN;
 	rec->cr_fsuid    = from_kuid(&init_user_ns, current_fsuid());
 	rec->cr_fsgid    = from_kgid(&init_user_ns, current_fsgid());
-	rec->cr_cap      = cfs_curproc_cap_pack();
+	rec->cr_cap      = current_cap().cap[0];
 	rec->cr_fid1 = op_data->op_fid1;
 	rec->cr_fid2 = op_data->op_fid2;
 
@@ -281,7 +282,7 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 	rec->sa_opcode  = REINT_SETATTR;
 	rec->sa_fsuid   = from_kuid(&init_user_ns, current_fsuid());
 	rec->sa_fsgid   = from_kgid(&init_user_ns, current_fsgid());
-	rec->sa_cap     = cfs_curproc_cap_pack();
+	rec->sa_cap     = current_cap().cap[0];
 	rec->sa_suppgid = -1;
 
 	rec->sa_fid    = op_data->op_fid1;
@@ -350,7 +351,7 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 					REINT_RMENTRY : REINT_UNLINK;
 	rec->ul_fsuid    = op_data->op_fsuid;
 	rec->ul_fsgid    = op_data->op_fsgid;
-	rec->ul_cap      = op_data->op_cap;
+	rec->ul_cap      = op_data->op_cap.cap[0];
 	rec->ul_mode     = op_data->op_mode;
 	rec->ul_suppgid1 = op_data->op_suppgids[0];
 	rec->ul_suppgid2 = -1;
@@ -372,7 +373,7 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->lk_opcode   = REINT_LINK;
 	rec->lk_fsuid    = op_data->op_fsuid; /* current->fsuid; */
 	rec->lk_fsgid    = op_data->op_fsgid; /* current->fsgid; */
-	rec->lk_cap      = op_data->op_cap;   /* current->cap_effective; */
+	rec->lk_cap      = op_data->op_cap.cap[0]; /* current->cap_effective; */
 	rec->lk_suppgid1 = op_data->op_suppgids[0];
 	rec->lk_suppgid2 = op_data->op_suppgids[1];
 	rec->lk_fid1     = op_data->op_fid1;
@@ -423,7 +424,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->rn_opcode   = REINT_RENAME;
 	rec->rn_fsuid    = op_data->op_fsuid;
 	rec->rn_fsgid    = op_data->op_fsgid;
-	rec->rn_cap      = op_data->op_cap;
+	rec->rn_cap      = op_data->op_cap.cap[0];
 	rec->rn_suppgid1 = op_data->op_suppgids[0];
 	rec->rn_suppgid2 = op_data->op_suppgids[1];
 	rec->rn_fid1     = op_data->op_fid1;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 488b98007558..94ab43bcbe4f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -148,7 +148,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 
 int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	       const void *data, size_t datalen, umode_t mode,
-	       uid_t uid, gid_t gid, cfs_cap_t cap_effective,
+	       uid_t uid, gid_t gid, kernel_cap_t cap_effective,
 	       __u64 rdev, struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 0eaf35c55966..1aee9691b513 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -303,7 +303,7 @@ static int mdc_xattr_common(struct obd_export *exp,
 		rec->sx_opcode = REINT_SETXATTR;
 		rec->sx_fsuid  = from_kuid(&init_user_ns, current_fsuid());
 		rec->sx_fsgid  = from_kgid(&init_user_ns, current_fsgid());
-		rec->sx_cap    = cfs_curproc_cap_pack();
+		rec->sx_cap    = current_cap().cap[0];
 		rec->sx_suppgid1 = suppgid;
 		rec->sx_suppgid2 = -1;
 		rec->sx_fid    = *fid;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 3cb1e075f077..256421465bcd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -2236,7 +2236,7 @@ int sptlrpc_pack_user_desc(struct lustre_msg *msg, int offset)
 	pud->pud_gid = from_kgid(&init_user_ns, current_gid());
 	pud->pud_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	pud->pud_fsgid = from_kgid(&init_user_ns, current_fsgid());
-	pud->pud_cap = cfs_curproc_cap_pack();
+	pud->pud_cap = current_cap().cap[0];
 	pud->pud_ngroups = (msg->lm_buflens[offset] - sizeof(*pud)) / 4;
 
 	task_lock(current);
