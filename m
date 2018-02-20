From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 12/21] staging: lustre: discard
 libcfs_kvzalloc and linux-mem.c
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341794.25814.12112685405079106591.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The only interesting difference between libcfs_kvzalloc()
and kvzalloc() is that the former appears to work
with GFP_NOFS, which the latter gives a WARN_ON_ONCE()
when that is attempted.

Each libcfs_kvzalloc() should really be analysed
and either converted to a kzalloc() call if the size is never
more than a page, or to use GFP_KERNEL if no locks are held.

If there is ever a case where locks are held and a large allocation
is needed, then some other technique should be used.

It might be nice to not always blindly zero pages too...

For now, just convert libcfs_kvzalloc() calls to
kvzalloc(), and let the warning remind us that there is work to do.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 -
 drivers/staging/lustre/lnet/libcfs/Makefile        |    1 
 .../staging/lustre/lnet/libcfs/linux/linux-mem.c   |   44 --------------------
 drivers/staging/lustre/lustre/llite/file.c         |    2 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    4 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    2 -
 drivers/staging/lustre/lustre/lov/lov_io.c         |    2 -
 drivers/staging/lustre/lustre/lov/lov_lock.c       |    2 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |    4 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 -
 .../lustre/lustre/obdclass/linux/linux-module.c    |    2 -
 drivers/staging/lustre/lustre/obdclass/llog.c      |    4 +-
 .../lustre/lustre/obdclass/lustre_handles.c        |    2 -
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 -
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 -
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |    8 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    8 ++--
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 +-
 20 files changed, 28 insertions(+), 75 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 039205763021..392793582956 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -112,8 +112,6 @@ static inline void *__container_of(void *ptr, unsigned long shift)
 
 #define _LIBCFS_H
 
-void *libcfs_kvzalloc(size_t size, gfp_t flags);
-
 extern struct miscdevice libcfs_dev;
 /**
  * The path of debug log dump upcall script.
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index a51a8b0b9921..b7dc7ac11cc5 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -9,7 +9,6 @@ libcfs-linux-objs += linux-cpu.o
 libcfs-linux-objs += linux-module.o
 libcfs-linux-objs += linux-crypto.o
 libcfs-linux-objs += linux-crypto-adler.o
-libcfs-linux-objs += linux-mem.o
 
 libcfs-linux-objs := $(addprefix linux/,$(libcfs-linux-objs))
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
deleted file mode 100644
index f2c001bac303..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
+++ /dev/null
@@ -1,44 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
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
- */
-/*
- * This file creates a memory allocation primitive for Lustre, that
- * allows to fallback to vmalloc allocations should regular kernel allocations
- * fail due to size or system memory fragmentation.
- *
- * Author: Oleg Drokin <green@linuxhacker.ru>
- *
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Seagate Technology.
- */
-#include <linux/slab.h>
-#include <linux/vmalloc.h>
-
-#include <linux/libcfs/libcfs.h>
-
-void *libcfs_kvzalloc(size_t size, gfp_t flags)
-{
-	void *ret;
-
-	ret = kzalloc(size, flags | __GFP_NOWARN);
-	if (!ret)
-		ret = __vmalloc(size, flags | __GFP_ZERO, PAGE_KERNEL);
-	return ret;
-}
-EXPORT_SYMBOL(libcfs_kvzalloc);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 002a56793e89..ca5faea13b7e 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3361,7 +3361,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 		goto out;
 	}
 
-	lvbdata = libcfs_kvzalloc(lmmsize, GFP_NOFS);
+	lvbdata = kvzalloc(lmmsize, GFP_NOFS);
 	if (!lvbdata) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index c2c57f65431e..179651531862 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1035,7 +1035,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				reqlen = offsetof(typeof(*hur),
 						  hur_user_item[nr])
 					 + hur->hur_request.hr_data_len;
-				req = libcfs_kvzalloc(reqlen, GFP_NOFS);
+				req = kvzalloc(reqlen, GFP_NOFS);
 				if (!req)
 					return -ENOMEM;
 
@@ -2733,7 +2733,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		lsm_size = lmv_stripe_md_size(0);
 
 	if (!lsm) {
-		lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
+		lsm = kvzalloc(lsm_size, GFP_NOFS);
 		if (!lsm)
 			return -ENOMEM;
 		allocated = true;
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index d563dd73343a..c56a971745e8 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -89,7 +89,7 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 	oinfo_ptrs_size = sizeof(struct lov_oinfo *) * stripe_count;
 	lsm_size = sizeof(*lsm) + oinfo_ptrs_size;
 
-	lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
+	lsm = kvzalloc(lsm_size, GFP_NOFS);
 	if (!lsm)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index c5f5d1b106dc..c0dbf6cd53b4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -243,7 +243,7 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	 * when writing a page. -jay
 	 */
 	lio->lis_subs =
-		libcfs_kvzalloc(lsm->lsm_stripe_count *
+		kvzalloc(lsm->lsm_stripe_count *
 				sizeof(lio->lis_subs[0]),
 				GFP_NOFS);
 	if (lio->lis_subs) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 2fcdeb707ff9..b0292100bf26 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -145,7 +145,7 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 			nr++;
 	}
 	LASSERT(nr > 0);
-	lovlck = libcfs_kvzalloc(offsetof(struct lov_lock, lls_sub[nr]),
+	lovlck = kvzalloc(offsetof(struct lov_lock, lls_sub[nr]),
 				 GFP_NOFS);
 	if (!lovlck)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 86cd4f9fbd0c..16cf9d584bbc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -242,7 +242,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	r0->lo_nr  = lsm->lsm_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
-	r0->lo_sub = libcfs_kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
+	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
 				     GFP_NOFS);
 	if (r0->lo_sub) {
 		int psz = 0;
@@ -1375,7 +1375,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	if (fiemap_count_to_size(fiemap->fm_extent_count) < buffer_size)
 		buffer_size = fiemap_count_to_size(fiemap->fm_extent_count);
 
-	fm_local = libcfs_kvzalloc(buffer_size, GFP_NOFS);
+	fm_local = kvzalloc(buffer_size, GFP_NOFS);
 	if (!fm_local) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index e5b11c4085a9..b1060d02a164 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -333,7 +333,7 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	lmmk_size = lov_mds_md_size(stripe_count, lsm->lsm_magic);
 
 
-	lmmk = libcfs_kvzalloc(lmmk_size, GFP_NOFS);
+	lmmk = kvzalloc(lmmk_size, GFP_NOFS);
 	if (!lmmk) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 3114907ac5ff..695ef44532cf 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -660,7 +660,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		LDLM_DEBUG(lock, "layout lock returned by: %s, lvb_len: %d",
 			   ldlm_it2str(it->it_op), lvb_len);
 
-		lmm = libcfs_kvzalloc(lvb_len, GFP_NOFS);
+		lmm = kvzalloc(lvb_len, GFP_NOFS);
 		if (!lmm) {
 			LDLM_LOCK_PUT(lock);
 			return -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index f8967fd44363..7bceee7f121e 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -180,7 +180,7 @@ int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 	 * obdfilter-survey is an example, which relies on ioctl. So we'd
 	 * better avoid vmalloc on ioctl path. LU-66
 	 */
-	*buf = libcfs_kvzalloc(hdr.ioc_len, GFP_KERNEL);
+	*buf = kvzalloc(hdr.ioc_len, GFP_KERNEL);
 	if (!*buf) {
 		CERROR("Cannot allocate control buffer of len %d\n",
 		       hdr.ioc_len);
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index ed310696a95d..693e1129f1f9 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -155,7 +155,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 	LASSERT(!handle->lgh_hdr);
 
 	LASSERT(chunk_size >= LLOG_MIN_CHUNK_SIZE);
-	llh = libcfs_kvzalloc(sizeof(*llh), GFP_KERNEL);
+	llh = kvzalloc(sizeof(*llh), GFP_KERNEL);
 	if (!llh)
 		return -ENOMEM;
 	handle->lgh_hdr = llh;
@@ -240,7 +240,7 @@ static int llog_process_thread(void *arg)
 	/* expect chunk_size to be power of two */
 	LASSERT(is_power_of_2(chunk_size));
 
-	buf = libcfs_kvzalloc(chunk_size, GFP_NOFS);
+	buf = kvzalloc(chunk_size, GFP_NOFS);
 	if (!buf) {
 		lpi->lpi_rc = -ENOMEM;
 		return 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 9a6377502ae4..f53b1a3c342e 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -184,7 +184,7 @@ int class_handle_init(void)
 
 	LASSERT(!handle_hash);
 
-	handle_hash = libcfs_kvzalloc(sizeof(*bucket) * HANDLE_HASH_SIZE,
+	handle_hash = kvzalloc(sizeof(*bucket) * HANDLE_HASH_SIZE,
 				      GFP_KERNEL);
 	if (!handle_hash)
 		return -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 781462621d92..d4c641d2480c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -547,7 +547,7 @@ int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
 		req = ptlrpc_request_cache_alloc(GFP_KERNEL);
 		if (!req)
 			return i;
-		msg = libcfs_kvzalloc(size, GFP_KERNEL);
+		msg = kvzalloc(size, GFP_KERNEL);
 		if (!msg) {
 			ptlrpc_request_cache_free(req);
 			return i;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 90e3b3022106..f152ba1af0fc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -442,7 +442,7 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 	/* save request message */
 	reqmsg_size = req->rq_reqlen;
 	if (reqmsg_size != 0) {
-		reqmsg = libcfs_kvzalloc(reqmsg_size, GFP_NOFS);
+		reqmsg = kvzalloc(reqmsg_size, GFP_NOFS);
 		if (!reqmsg)
 			return -ENOMEM;
 		memcpy(reqmsg, req->rq_reqmsg, reqmsg_size);
@@ -1089,7 +1089,7 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 
 	early_size = req->rq_nob_received;
 	early_bufsz = size_roundup_power2(early_size);
-	early_buf = libcfs_kvzalloc(early_bufsz, GFP_NOFS);
+	early_buf = kvzalloc(early_bufsz, GFP_NOFS);
 	if (!early_buf) {
 		rc = -ENOMEM;
 		goto err_req;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 134ee727e8b7..2184022ed724 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -375,7 +375,7 @@ static inline void enc_pools_alloc(void)
 {
 	LASSERT(page_pools.epp_max_pools);
 	page_pools.epp_pools =
-		libcfs_kvzalloc(page_pools.epp_max_pools *
+		kvzalloc(page_pools.epp_max_pools *
 				sizeof(*page_pools.epp_pools),
 				GFP_NOFS);
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 80cea0b24693..ecc387d1b9b4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -158,7 +158,7 @@ int null_alloc_reqbuf(struct ptlrpc_sec *sec,
 		int alloc_size = size_roundup_power2(msgsize);
 
 		LASSERT(!req->rq_pool);
-		req->rq_reqbuf = libcfs_kvzalloc(alloc_size, GFP_NOFS);
+		req->rq_reqbuf = kvzalloc(alloc_size, GFP_NOFS);
 		if (!req->rq_reqbuf)
 			return -ENOMEM;
 
@@ -201,7 +201,7 @@ int null_alloc_repbuf(struct ptlrpc_sec *sec,
 
 	msgsize = size_roundup_power2(msgsize);
 
-	req->rq_repbuf = libcfs_kvzalloc(msgsize, GFP_NOFS);
+	req->rq_repbuf = kvzalloc(msgsize, GFP_NOFS);
 	if (!req->rq_repbuf)
 		return -ENOMEM;
 
@@ -246,7 +246,7 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 	if (req->rq_reqbuf_len < newmsg_size) {
 		alloc_size = size_roundup_power2(newmsg_size);
 
-		newbuf = libcfs_kvzalloc(alloc_size, GFP_NOFS);
+		newbuf = kvzalloc(alloc_size, GFP_NOFS);
 		if (!newbuf)
 			return -ENOMEM;
 
@@ -317,7 +317,7 @@ int null_alloc_rs(struct ptlrpc_request *req, int msgsize)
 		/* pre-allocated */
 		LASSERT(rs->rs_size >= rs_size);
 	} else {
-		rs = libcfs_kvzalloc(rs_size, GFP_NOFS);
+		rs = kvzalloc(rs_size, GFP_NOFS);
 		if (!rs)
 			return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 44e34056515b..ec3d9af76b17 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -562,7 +562,7 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
 		LASSERT(!req->rq_pool);
 
 		alloc_len = size_roundup_power2(alloc_len);
-		req->rq_reqbuf = libcfs_kvzalloc(alloc_len, GFP_NOFS);
+		req->rq_reqbuf = kvzalloc(alloc_len, GFP_NOFS);
 		if (!req->rq_reqbuf)
 			return -ENOMEM;
 
@@ -620,7 +620,7 @@ int plain_alloc_repbuf(struct ptlrpc_sec *sec,
 
 	alloc_len = size_roundup_power2(alloc_len);
 
-	req->rq_repbuf = libcfs_kvzalloc(alloc_len, GFP_NOFS);
+	req->rq_repbuf = kvzalloc(alloc_len, GFP_NOFS);
 	if (!req->rq_repbuf)
 		return -ENOMEM;
 
@@ -671,7 +671,7 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
 	if (req->rq_reqbuf_len < newbuf_size) {
 		newbuf_size = size_roundup_power2(newbuf_size);
 
-		newbuf = libcfs_kvzalloc(newbuf_size, GFP_NOFS);
+		newbuf = kvzalloc(newbuf_size, GFP_NOFS);
 		if (!newbuf)
 			return -ENOMEM;
 
@@ -808,7 +808,7 @@ int plain_alloc_rs(struct ptlrpc_request *req, int msgsize)
 		/* pre-allocated */
 		LASSERT(rs->rs_size >= rs_size);
 	} else {
-		rs = libcfs_kvzalloc(rs_size, GFP_NOFS);
+		rs = kvzalloc(rs_size, GFP_NOFS);
 		if (!rs)
 			return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 57e41e2cd30a..79d9f3860022 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1068,7 +1068,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	reqcopy = ptlrpc_request_cache_alloc(GFP_NOFS);
 	if (!reqcopy)
 		return -ENOMEM;
-	reqmsg = libcfs_kvzalloc(req->rq_reqlen, GFP_NOFS);
+	reqmsg = kvzalloc(req->rq_reqlen, GFP_NOFS);
 	if (!reqmsg) {
 		rc = -ENOMEM;
 		goto out_free;
@@ -2077,7 +2077,7 @@ static int ptlrpc_main(void *arg)
 	}
 
 	/* Alloc reply state structure for this one */
-	rs = libcfs_kvzalloc(svc->srv_max_reply_size, GFP_NOFS);
+	rs = kvzalloc(svc->srv_max_reply_size, GFP_NOFS);
 	if (!rs) {
 		rc = -ENOMEM;
 		goto out_srv_fini;
