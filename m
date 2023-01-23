Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7ADA0C54EAA
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:04:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15G40Kckz1yC9;
	Mon, 23 Jan 2023 15:02:04 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Dt63RPz1wSM
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:01:02 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1ABBF6C1;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 126DC5898C; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:14 -0500
Message-Id: <1674514855-15399-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/42] lustre: osc: pack osc_async_page better
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

The oap_cmd field was used to store a number of other flags, but
those were redundant with oap_brw_page.flag, and never used.
That allows shrinking oap_cmd down to 2 bits.

Modern GCC allows specifying a bitfield for an enum, so the size
can be explicitly set.

The oap_page_off always holds < PAGE_SIZE, so it can safely fit
into PAGE_SHIFT bits, similar to ops_from. However, since this
field is used in math operations and we don't need the space,
always allocate it as an aligned 16-bit field.

This allows packing oap_async_flags, oap_cmd, and oap_page_off
into a 32-bit space.  This avoids having holes in the struct. The
explicit oap_padding fields are needed so that "packed" does not
cause the fields to be misaligned, but still allows packing with
the following 4-byte field in osc_page.

Also move oap_brw_page to the end of the struct, since the
bp_padding field therein is useless and can be removed. This
allows better packing with the bitfields in struct osc_page.

    brw_page       old size:  32, holes: 0, padding: 4
    brw_page       new size:  28, holes: 0, padding: 0
    osc_async_page old size: 104, holes: 8, padding: 4
    osc_async_page new size:  92, holes: 0, bit holes: 10
    osc_page       old size: 144, holes: 8, bit holes:  4
    osc_page       new size: 128, holes: 0, bit holes:  4

Together this saves 16 bytes *per page* in cache,
and fits osc_page into a noce-sized allocation.
That is 512MiB on a system with 128GiB of cache.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15619
Lustre-commit: 0bfc8eca5c3d26235 ("LU-15619 osc: pack osc_async_page better")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46721
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 25 +++++++++++++++++--------
 fs/lustre/include/obd.h        |  3 +--
 fs/lustre/osc/osc_io.c         |  5 ++---
 fs/lustre/osc/osc_page.c       |  4 +---
 4 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index d15f46b4a34a..526093ebff18 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -60,7 +60,7 @@ struct osc_quota_info {
 	struct rcu_head		rcu;
 };
 
-enum async_flags {
+enum oap_async_flags {
 	ASYNC_READY		= 0x1,	/* osc_make_ready will not be called
 					 * before this page is added to an rpc
 					 */
@@ -71,24 +71,32 @@ enum async_flags {
 					 * to give the caller a chance to update
 					 * or cancel the size of the io
 					 */
-	ASYNC_HP = 0x10,
+	ASYNC_HP		= 0x8,
+	OAP_ASYNC_MAX,
+	OAP_ASYNC_BITS = 4
 };
 
+/* add explicit padding to keep fields aligned despite "packed",
+ * which is needed to pack with following field in osc_page
+ */
+#define OAP_PAD_BITS (16 - OBD_BRW_WRITE - OAP_ASYNC_BITS)
 struct osc_async_page {
-	unsigned short		oap_cmd;
+	unsigned short		oap_page_off;	/* :PAGE_SHIFT */
+	unsigned int		oap_cmd:OBD_BRW_WRITE;
+	enum oap_async_flags    oap_async_flags:OAP_ASYNC_BITS;
+	unsigned int		oap_padding1:OAP_PAD_BITS;	/* unused */
+	unsigned int		oap_padding2;			/* unused */
 
 	struct list_head        oap_pending_item;
 	struct list_head        oap_rpc_item;
 
 	u64			oap_obj_off;
-	unsigned int		oap_page_off;
-	enum async_flags	oap_async_flags;
-
-	struct brw_page		oap_brw_page;
 
 	struct ptlrpc_request	*oap_request;
 	struct osc_object	*oap_obj;
-};
+
+	struct brw_page         oap_brw_page;
+} __packed;
 
 #define oap_page	oap_brw_page.pg
 #define oap_count	oap_brw_page.count
@@ -96,6 +104,7 @@ struct osc_async_page {
 
 static inline struct osc_async_page *brw_page2oap(struct brw_page *pga)
 {
+	BUILD_BUG_ON(OAP_ASYNC_MAX - 1 >= (1 << OAP_ASYNC_BITS));
 	return container_of(pga, struct osc_async_page, oap_brw_page);
 }
 
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 56e56414fd72..e9752a306294 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -123,8 +123,7 @@ struct brw_page {
 	u16			bp_off_diff;
 	/* used for encryption: difference with count in clear text page */
 	u16			bp_count_diff;
-	u32			bp_padding;
-};
+} __packed;
 
 struct timeout_item {
 	enum timeout_event	ti_event;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index b9362d96b78d..c9a317575993 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -514,9 +514,8 @@ static bool trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 				      start, current->comm);
 
 		if (PageLocked(page->cp_vmpage))
-			CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
-			       ops, osc_index(ops),
-			       oap->oap_cmd & OBD_BRW_RWMASK);
+			CDEBUG(D_CACHE, "page %p index %lu locked for cmd=%d\n",
+			       ops, osc_index(ops), oap->oap_cmd);
 	}
 	return true;
 }
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 667825a90442..feec99fe0ca2 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -296,10 +296,8 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_count = opg->ops_to - opg->ops_from + 1;
 	oap->oap_brw_flags = OBD_BRW_SYNC | brw_flags;
 
-	if (oio->oi_cap_sys_resource) {
+	if (oio->oi_cap_sys_resource)
 		oap->oap_brw_flags |= OBD_BRW_SYS_RESOURCE;
-		oap->oap_cmd |= OBD_BRW_SYS_RESOURCE;
-	}
 
 	osc_page_transfer_get(opg, "transfer\0imm");
 	osc_page_transfer_add(env, opg, crt);
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
