Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CB99DC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:58:59 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFT5j6pz211b;
	Sun, 02 Feb 2025 12:49:49 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCz6Rn9z20xC
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:31 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D3094899ADD;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D165A106BE17; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:15 -0500
Message-ID: <20250202204633.1148872-16-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 15/33] lustre: obd: remove OBD_ -> CFS_ macros
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

From: Timothy Day <timday@amazon.com>

Remove OBD macros that are simply redefinitions
of CFS macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: 24ada119f28045eba ("LU-12610 obd: remove OBD_ -> CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Signed-off-by: Ben Evans <beevans@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50808
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_page.c    | 2 +-
 fs/lustre/obdclass/class_obd.c  | 2 +-
 fs/lustre/obdclass/kernelcomm.c | 2 +-
 fs/lustre/obdclass/llog_obd.c   | 2 +-
 fs/lustre/obdclass/lu_object.c  | 4 ++--
 fs/lustre/obdclass/obd_config.c | 2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index ecfccdb2c945..479707a8366f 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -149,7 +149,7 @@ static struct cl_page *__cl_page_alloc(struct cl_object *o)
 	struct cl_page *cl_page = NULL;
 	unsigned short bufsize = cl_object_header(o)->coh_page_bufsize;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PAGE_ALLOC))
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_PAGE_ALLOC))
 		return NULL;
 
 check:
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 3692d57fbcef..dabd40da5912 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -749,7 +749,7 @@ static int __init obdclass_init(void)
 	/* simulate a late OOM situation now to require all
 	 * alloc'ed/initialized resources to be freed
 	 */
-	if (OBD_FAIL_CHECK(OBD_FAIL_OBDCLASS_MODULE_LOAD)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_OBDCLASS_MODULE_LOAD)) {
 		/* force error to ensure module will be unloaded/cleaned */
 		err = -ENOMEM;
 		goto cleanup_all;
diff --git a/fs/lustre/obdclass/kernelcomm.c b/fs/lustre/obdclass/kernelcomm.c
index 0cf3c44a528b..dda7823e4598 100644
--- a/fs/lustre/obdclass/kernelcomm.c
+++ b/fs/lustre/obdclass/kernelcomm.c
@@ -456,7 +456,7 @@ int libcfs_kkuc_group_put(const struct obd_uuid *uuid, int group, void *payload)
 	down_write(&kg_sem);
 
 	if (unlikely(list_empty(&kkuc_groups[group])) ||
-	    unlikely(OBD_FAIL_CHECK(OBD_FAIL_MDS_HSM_CT_REGISTER_NET))) {
+	    unlikely(CFS_FAIL_CHECK(OBD_FAIL_MDS_HSM_CT_REGISTER_NET))) {
 		/* no agent have fully registered, CDT will retry */
 		up_write(&kg_sem);
 		return -EAGAIN;
diff --git a/fs/lustre/obdclass/llog_obd.c b/fs/lustre/obdclass/llog_obd.c
index 4743dc9a6abc..b1c5a9e6db9f 100644
--- a/fs/lustre/obdclass/llog_obd.c
+++ b/fs/lustre/obdclass/llog_obd.c
@@ -182,7 +182,7 @@ int llog_setup(const struct lu_env *env, struct obd_device *obd,
 	}
 
 	if (op->lop_setup) {
-		if (OBD_FAIL_CHECK(OBD_FAIL_OBD_LLOG_SETUP))
+		if (CFS_FAIL_CHECK(OBD_FAIL_OBD_LLOG_SETUP))
 			rc = -EOPNOTSUPP;
 		else
 			rc = op->lop_setup(env, obd, olg, index, disk_obd);
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 468dd43b6151..a07890f38180 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -418,7 +418,7 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	int bnr;
 	unsigned int i;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_OBD_NO_LRU))
+	if (CFS_FAIL_CHECK(OBD_FAIL_OBD_NO_LRU))
 		return 0;
 
 	/*
@@ -806,7 +806,7 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	 */
 	s  = dev->ld_site;
 	hs = &s->ls_obj_hash;
-	if (unlikely(OBD_FAIL_PRECHECK(OBD_FAIL_OBD_ZERO_NLINK_RACE)))
+	if (unlikely(CFS_FAIL_PRECHECK(OBD_FAIL_OBD_ZERO_NLINK_RACE)))
 		lu_site_purge(env, s, -1);
 
 	bkt = &s->ls_bkts[lu_bkt_hash(s, f)];
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 3fe1cb6e5341..140950418e55 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -450,7 +450,7 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	int err = 0;
 	char *flag;
 
-	OBD_RACE(OBD_FAIL_LDLM_RECOV_CLIENTS);
+	CFS_RACE(OBD_FAIL_LDLM_RECOV_CLIENTS);
 
 	if (!obd->obd_set_up) {
 		CERROR("Device %d not setup\n", obd->obd_minor);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
