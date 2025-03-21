Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8654EC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:28:01 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2rb5qLpz20wG;
	Fri, 21 Mar 2025 06:11:11 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2n93mmHz1y1x
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:13 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8223C88F9EB;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 7FBAB106BE18; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:57 -0400
Message-ID: <20250321130711.3257092-15-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 14/27] lustre: osc: convert more functions to
 static
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

Static analysis shows that a number of functions
could be made static. This patch declares several
functions in osc as static.

Also, fix a few minor style issues.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8191
Lustre-commit: 2fa075d10f72f1400 ("U-8191 lustre: convert osp,osd,osc,ofd functions to static")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51477
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c   |  9 +++------
 fs/lustre/osc/osc_io.c      |  4 ++--
 fs/lustre/osc/osc_request.c | 14 ++++++++------
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index d3131ee7eef1..2e2cec9db148 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -840,7 +840,7 @@ static ssize_t osc_stats_seq_write(struct file *file,
 
 LDEBUGFS_SEQ_FOPS(osc_stats);
 
-void lproc_osc_attach_seqstat(struct obd_device *obd)
+static void ldebugfs_osc_attach_seqstat(struct obd_device *obd)
 {
 	debugfs_create_file("osc_stats", 0644, obd->obd_debugfs_entry, obd,
 			    &osc_stats_fops);
@@ -884,17 +884,14 @@ int osc_tunables_init(struct obd_device *obd)
 	if (rc)
 		return rc;
 
+	ldebugfs_osc_attach_seqstat(obd);
+
 	rc = sptlrpc_lprocfs_cliobd_attach(obd);
 	if (rc) {
 		lprocfs_obd_cleanup(obd);
 		return rc;
 	}
 
-	debugfs_create_file("osc_stats", 0644, obd->obd_debugfs_entry, obd,
-			    &osc_stats_fops);
-	debugfs_create_file("rpc_stats", 0644, obd->obd_debugfs_entry, obd,
-			    &osc_rpc_stats_fops);
-
 	ptlrpc_lprocfs_register_obd(obd);
 	return 0;
 }
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 900edf8b9a41..5b4abb1cb625 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -937,8 +937,8 @@ int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 }
 EXPORT_SYMBOL(osc_fsync_ost);
 
-int osc_io_fsync_start(const struct lu_env *env,
-		       const struct cl_io_slice *slice)
+static int osc_io_fsync_start(const struct lu_env *env,
+			      const struct cl_io_slice *slice)
 {
 	struct cl_io *io = slice->cis_io;
 	struct cl_fsync_io *fio = &io->u.ci_fsync;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 5c9f93b91609..4a739b1858e5 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2927,10 +2927,11 @@ static int osc_set_lock_data(struct ldlm_lock *lock, void *data)
 	return set;
 }
 
-int osc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
-		     void *cookie, struct lustre_handle *lockh,
-		     enum ldlm_mode mode, u64 *flags, int speculative,
-		     int errcode)
+static int osc_enqueue_fini(struct ptlrpc_request *req,
+			    osc_enqueue_upcall_f upcall,
+			    void *cookie, struct lustre_handle *lockh,
+			    enum ldlm_mode mode, u64 *flags,
+			    int speculative, int errcode)
 {
 	bool intent = *flags & LDLM_FL_HAS_INTENT;
 	int rc;
@@ -2962,8 +2963,9 @@ int osc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
 	return rc;
 }
 
-int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			  void *args, int rc)
+static int osc_enqueue_interpret(const struct lu_env *env,
+				 struct ptlrpc_request *req,
+				 void *args, int rc)
 {
 	struct osc_enqueue_args *aa = args;
 	struct ldlm_lock *lock;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
