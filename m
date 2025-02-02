Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2CD61C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:03:51 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFz18t7z20tk;
	Sun, 02 Feb 2025 12:50:15 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFX6bqpz212T
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:52 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 07765881A9D;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 04568106BE15; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:25 -0500
Message-ID: <20250202204633.1148872-26-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 25/33] lnet: libcfs: use round_up directly
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

The macro cfs_size_round() is just round_up(val, 8). Replace
cfs_size_round() with the Linux standard round_up().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 20683c0d6c3e7d042 ("LU-9859 libcfs: use round_up directly")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50545
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/cl_object.h         |  2 +-
 fs/lustre/llite/vvp_object.c          |  2 +-
 fs/lustre/mdc/mdc_request.c           |  9 ++++-----
 fs/lustre/obdclass/class_obd.c        |  6 +++---
 fs/lustre/obdecho/echo_client.c       |  2 +-
 fs/lustre/osc/osc_cache.c             |  2 +-
 fs/lustre/ptlrpc/batch.c              |  6 ++----
 fs/lustre/ptlrpc/layout.c             |  8 +++++---
 fs/lustre/ptlrpc/pack_generic.c       | 13 ++++++-------
 include/linux/libcfs/libcfs_private.h |  4 ----
 net/lnet/libcfs/module.c              |  8 ++++----
 11 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 9d940cbdb249..b8ac31960a2f 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2162,7 +2162,7 @@ static inline int cl_object_same(struct cl_object *o0, struct cl_object *o1)
 static inline void cl_object_page_init(struct cl_object *clob, int size)
 {
 	clob->co_slice_off = cl_object_header(clob)->coh_page_bufsize;
-	cl_object_header(clob)->coh_page_bufsize += cfs_size_round(size);
+	cl_object_header(clob)->coh_page_bufsize += round_up(size, 8);
 	WARN_ON(cl_object_header(clob)->coh_page_bufsize > 512);
 }
 
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 5120ec095862..f4b2f8921b6c 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -316,7 +316,7 @@ struct lu_object *vvp_object_alloc(const struct lu_env *env,
 		obj = &vob->vob_cl.co_lu;
 		hdr = &vob->vob_header;
 		cl_object_header_init(hdr);
-		hdr->coh_page_bufsize = cfs_size_round(sizeof(struct cl_page));
+		hdr->coh_page_bufsize = round_up(sizeof(struct cl_page), 8);
 
 		lu_object_init(obj, &hdr->coh_lu, dev);
 		lu_object_add_top(&hdr->coh_lu, obj);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 5919e5952c0e..2b8386661a31 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1712,15 +1712,14 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 		return -EOVERFLOW;
 
 	/* Key is KEY_FID2PATH + getinfo_fid2path description */
-	keylen = cfs_size_round(sizeof(KEY_FID2PATH)) + sizeof(*gf) +
-				sizeof(struct lu_fid);
+	keylen = round_up(sizeof(KEY_FID2PATH) + sizeof(*gf) +
+			  sizeof(struct lu_fid), 8);
 	key = kzalloc(keylen, GFP_NOFS);
 	if (!key)
 		return -ENOMEM;
 	memcpy(key, KEY_FID2PATH, sizeof(KEY_FID2PATH));
-	memcpy(key + cfs_size_round(sizeof(KEY_FID2PATH)), gf, sizeof(*gf));
-
-	memcpy(key + cfs_size_round(sizeof(KEY_FID2PATH)) + sizeof(*gf),
+	memcpy(key + round_up(sizeof(KEY_FID2PATH), 8), gf, sizeof(*gf));
+	memcpy(key + round_up(sizeof(KEY_FID2PATH), 8) + sizeof(*gf),
 	       gf->gf_root_fid, sizeof(struct lu_fid));
 	CDEBUG(D_IOCTL, "path get " DFID " from %llu #%d\n",
 	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno);
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index ab27cf23ca9a..a6e256484800 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -278,17 +278,17 @@ int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 
 	if (data->ioc_inllen1) {
 		data->ioc_inlbuf1 = &data->ioc_bulk[0];
-		offset += cfs_size_round(data->ioc_inllen1);
+		offset += round_up(data->ioc_inllen1, 8);
 	}
 
 	if (data->ioc_inllen2) {
 		data->ioc_inlbuf2 = &data->ioc_bulk[0] + offset;
-		offset += cfs_size_round(data->ioc_inllen2);
+		offset += round_up(data->ioc_inllen2, 8);
 	}
 
 	if (data->ioc_inllen3) {
 		data->ioc_inlbuf3 = &data->ioc_bulk[0] + offset;
-		offset += cfs_size_round(data->ioc_inllen3);
+		offset += round_up(data->ioc_inllen3, 8);
 	}
 
 	if (data->ioc_inllen4)
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 220ceae89150..654bc3b7d351 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -294,7 +294,7 @@ static struct lu_object *echo_object_alloc(const struct lu_env *env,
 
 		obj = &echo_obj2cl(eco)->co_lu;
 		cl_object_header_init(hdr);
-		hdr->coh_page_bufsize = cfs_size_round(sizeof(struct cl_page));
+		hdr->coh_page_bufsize = round_up(sizeof(struct cl_page), 8);
 
 		lu_object_init(obj, &hdr->coh_lu, dev);
 		lu_object_add_top(&hdr->coh_lu, obj);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 691ebc0ad46a..f1f21c28765e 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2302,7 +2302,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	struct osc_async_page *oap = &ops->ops_oap;
 
 	if (!page)
-		return cfs_size_round(sizeof(*oap));
+		return round_up(sizeof(*oap), 8);
 
 	oap->oap_obj = osc;
 	oap->oap_page = page->cp_vmpage;
diff --git a/fs/lustre/ptlrpc/batch.c b/fs/lustre/ptlrpc/batch.c
index 77e3261862e0..753dfe3c15e8 100644
--- a/fs/lustre/ptlrpc/batch.c
+++ b/fs/lustre/ptlrpc/batch.c
@@ -132,14 +132,12 @@ static int batch_prep_update_req(struct batch_update_head *head,
 	struct batch_update_buffer *buf;
 	struct but_update_header *buh;
 	struct but_update_buffer *bub;
+	int repsize = head->buh_repsize;
 	int page_count = 0;
 	int total = 0;
-	int repsize;
 	int rc;
 
-	repsize = head->buh_repsize +
-		  cfs_size_round(offsetof(struct batch_update_reply,
-					  burp_repmsg[0]));
+	repsize += round_up(offsetof(struct batch_update_reply, burp_repmsg[0]), 8);
 	if (repsize < OUT_UPDATE_REPLY_SIZE)
 		repsize = OUT_UPDATE_REPLY_SIZE;
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 3a9e83f5262b..64e0224ce496 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -2404,9 +2404,11 @@ u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
 	if (!size)
 		return size;
 
-	for (; i < fmt->rf_fields[loc].nr; ++i)
-		if (fmt->rf_fields[loc].d[i]->rmf_size != -1)
-			size += cfs_size_round(fmt->rf_fields[loc].d[i]->rmf_size);
+	for (; i < fmt->rf_fields[loc].nr; ++i) {
+		if (fmt->rf_fields[loc].d[i]->rmf_size == -1)
+			continue;
+		size += round_up(fmt->rf_fields[loc].d[i]->rmf_size, 8);
+	}
 	return size;
 }
 EXPORT_SYMBOL(req_capsule_fmt_size);
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 61fd122e8e3f..cb7a8a39a380 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -55,8 +55,7 @@
 
 static inline u32 lustre_msg_hdr_size_v2(u32 count)
 {
-	return cfs_size_round(offsetof(struct lustre_msg_v2,
-				       lm_buflens[count]));
+	return round_up(offsetof(struct lustre_msg_v2, lm_buflens[count]), 8);
 }
 
 u32 lustre_msg_hdr_size(u32 magic, u32 count)
@@ -91,7 +90,7 @@ u32 lustre_msg_size_v2(int count, u32 *lengths)
 	LASSERT(count > 0);
 	size = lustre_msg_hdr_size_v2(count);
 	for (i = 0; i < count; i++)
-		size += cfs_size_round(lengths[i]);
+		size += round_up(lengths[i], 8);
 
 	return size;
 }
@@ -164,7 +163,7 @@ void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, u32 *lens,
 
 		if (tmp)
 			memcpy(ptr, tmp, lens[i]);
-		ptr += cfs_size_round(lens[i]);
+		ptr += round_up(lens[i], 8);
 	}
 }
 EXPORT_SYMBOL(lustre_init_msg_v2);
@@ -376,7 +375,7 @@ void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size)
 
 	offset = lustre_msg_hdr_size_v2(bufcount);
 	for (i = 0; i < n; i++)
-		offset += cfs_size_round(m->lm_buflens[i]);
+		offset += round_up(m->lm_buflens[i], 8);
 
 	return (char *)m + offset;
 }
@@ -410,7 +409,7 @@ static int lustre_shrink_msg_v2(struct lustre_msg_v2 *msg, u32 segment,
 	if (move_data && msg->lm_bufcount > segment + 1) {
 		tail = lustre_msg_buf_v2(msg, segment + 1, 0);
 		for (n = segment + 1; n < msg->lm_bufcount; n++)
-			tail_len += cfs_size_round(msg->lm_buflens[n]);
+			tail_len += round_up(msg->lm_buflens[n], 8);
 	}
 
 	msg->lm_buflens[segment] = newlen;
@@ -562,7 +561,7 @@ static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 	for (i = 0; i < m->lm_bufcount; i++) {
 		if (swabbed)
 			__swab32s(&m->lm_buflens[i]);
-		buflen = cfs_size_round(m->lm_buflens[i]);
+		buflen = round_up(m->lm_buflens[i], 8);
 		if (buflen < 0 || buflen > PTLRPC_MAX_BUFLEN) {
 			CERROR("buffer %d length %d is not valid\n", i, buflen);
 			return -EINVAL;
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index 86d135a65d81..7c0fb5a1c652 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -139,13 +139,9 @@ do {								\
 /* logical equivalence */
 #define equi(a, b) (!!(a) == !!(b))
 
-#ifndef HAVE_CFS_SIZE_ROUND
 static inline size_t cfs_size_round(int val)
 {
 	return round_up(val, 8);
 }
 
-#define HAVE_CFS_SIZE_ROUND
-#endif
-
 #endif
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index a126683354ac..17cb8e4b818f 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -72,8 +72,8 @@ static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 {
 	size_t len = sizeof(*data);
 
-	len += cfs_size_round(data->ioc_inllen1);
-	len += cfs_size_round(data->ioc_inllen2);
+	len += round_up(data->ioc_inllen1, 8);
+	len += round_up(data->ioc_inllen2, 8);
 	return len;
 }
 
@@ -124,7 +124,7 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 		return true;
 	}
 	if (data->ioc_inllen2 &&
-	    data->ioc_bulk[cfs_size_round(data->ioc_inllen1) +
+	    data->ioc_bulk[round_up(data->ioc_inllen1, 8) +
 			   data->ioc_inllen2 - 1] != '\0') {
 		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
 		return true;
@@ -144,7 +144,7 @@ static int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 
 	if (data->ioc_inllen2)
 		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
-			cfs_size_round(data->ioc_inllen1);
+				    round_up(data->ioc_inllen1, 8);
 
 	return 0;
 }
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
