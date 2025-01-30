Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3C9B9C0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:39:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLh63T0cz2293;
	Thu, 30 Jan 2025 06:17:26 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYc6PyJz1whJ
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:48 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 070E1899AD6;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 03D07106BE16; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:00 -0500
Message-ID: <20250130141115.950749-11-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 10/25] lustre: lov: refresh LOVEA with LL
 granted
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
Cc: Zhenyu Xu <bobijam@hotmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alex Zhuravlev <bzzz@whamcloud.com>

This change tries to fix:

lov_layout_change() should not apply old layouts which
can get through when MDS doesn't take layout lock

This patch misses an optimization and can result in a number of
useless calls to OSD to fetch LOVEA. To be fixed in a followup
patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15300
Lustre-commit: 13557aa86904376e4 ("LU-15300 mdt: refresh LOVEA with LL granted")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46413
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/vvp_page.c      |  4 ++++
 fs/lustre/lov/lov_object.c      | 18 ++++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index ab7899cd1384..43b4684f418a 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -492,6 +492,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LLITE_XATTR_PAUSE			0x1420
 #define OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE		0x1421
 #define OBD_FAIL_LLITE_READPAGE_PAUSE			0x1422
+#define OBD_FAIL_LLITE_PANIC_ON_ESTALE			0x1423
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 30524fda692e..9994c3d292a9 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -115,6 +115,10 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage,
 		obj->vob_discard_page_warned = 0;
 	} else {
 		SetPageError(vmpage);
+		if (ioret != -ENOSPC &&
+		    OBD_FAIL_CHECK(OBD_FAIL_LLITE_PANIC_ON_ESTALE))
+			LBUG();
+
 		mapping_set_error(inode->i_mapping, ioret);
 
 		if ((ioret == -ESHUTDOWN || ioret == -EINTR ||
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 5d65aabe7645..7c20f6eae03b 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1370,6 +1370,24 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 
 	LASSERT(conf->coc_opc == OBJECT_CONF_SET);
 
+	/*
+	 * don't apply old layouts which can be brought
+	 * if returned w/o ldlm lock.
+	 * XXX: can we rollback in case of recovery?
+	 */
+	if (lsm && lov->lo_lsm) {
+		u32 oldgen = lov->lo_lsm->lsm_layout_gen &= ~LU_LAYOUT_RESYNC;
+		u32 newgen = lsm->lsm_layout_gen & ~LU_LAYOUT_RESYNC;
+
+		if (newgen < oldgen) {
+			CDEBUG(D_HA, "skip old for "DFID": %d < %d\n",
+			       PFID(lu_object_fid(lov2lu(lov))),
+			       (int)newgen, (int)oldgen);
+			result = 0;
+			goto out;
+		}
+	}
+
 	if ((!lsm && !lov->lo_lsm) ||
 	    ((lsm && lov->lo_lsm) &&
 	     (lov->lo_lsm->lsm_layout_gen == lsm->lsm_layout_gen) &&
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
