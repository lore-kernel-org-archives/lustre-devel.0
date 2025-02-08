Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5CCA5C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:30:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw30y9bz1xPb;
	Fri, 07 Feb 2025 16:30:43 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw12S7pz1xNy
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:41 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 011AE88F9DD;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id F09D1106BE14; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:13 -0500
Message-ID: <20250208003027.180076-8-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 07/21] lustre: osc: remove OBD_ -> CFS_ macros
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Remove OBD macros that are simply redefinitions
of CFS macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: ef01e035b3307e20e ("LU-12610 osc: remove OBD_ -> CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Signed-off-by: Ben Evans <beevans@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51124
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c   |  4 ++--
 fs/lustre/osc/osc_io.c      |  2 +-
 fs/lustre/osc/osc_lock.c    |  8 ++++----
 fs/lustre/osc/osc_request.c | 26 +++++++++++++-------------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 37624a7a99d6..41a07e5d1d07 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1638,7 +1638,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	/* force the caller to try sync io.  this can jump the list
 	 * of queued writes and create a discontiguous rpc stream
 	 */
-	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
+	if (CFS_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
 	    !cli->cl_dirty_max_pages || cli->cl_ar.ar_force_sync ||
 	    loi->loi_ar.ar_force_sync) {
 		OSC_DUMP_GRANT(D_CACHE, cli, "forced sync i/o\n");
@@ -3196,7 +3196,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 		if (!res)
 			break;
 
-		OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_SLOW_PAGE_EVICT,
+		CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_SLOW_PAGE_EVICT,
 				 cfs_fail_val ?: 20);
 
 		if (io->ci_type == CIT_MISC &&
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 71bfe60ad40a..900edf8b9a41 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -899,7 +899,7 @@ int osc_io_write_start(const struct lu_env *env,
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int rc = 0;
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_SETTIME, 1);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_SETTIME, 1);
 	cl_object_attr_lock(obj);
 	attr->cat_ctime = ktime_get_real_seconds();
 	attr->cat_mtime = attr->cat_ctime;
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 181edf286739..3eac1d44fb2d 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -412,7 +412,7 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 
 	unlock_res_and_lock(dlmlock);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_CANCEL, 5);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_CANCEL, 5);
 
 	/* if l_ast_data is NULL, the dlmlock was enqueued by AGL or
 	 * the object has been destroyed.
@@ -586,7 +586,7 @@ int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 		dlmlock = NULL;
 
 		if (!obj && res->lr_type == LDLM_EXTENT) {
-			if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_SIZE_DATA))
+			if (CFS_FAIL_CHECK(OBD_FAIL_OSC_NO_SIZE_DATA))
 				break;
 
 			lock_res(res);
@@ -1025,8 +1025,8 @@ static int osc_lock_enqueue(const struct lu_env *env,
 		if (osc_lock_is_lockless(oscl)) {
 			oio->oi_lockless = 1;
 		} else if (!async) {
-			if (OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_IDLE_RACE)) {
-				OBD_RACE(OBD_FAIL_PTLRPC_IDLE_RACE);
+			if (CFS_FAIL_PRECHECK(OBD_FAIL_PTLRPC_IDLE_RACE)) {
+				CFS_RACE(OBD_FAIL_PTLRPC_IDLE_RACE);
 				set_current_state(TASK_UNINTERRUPTIBLE);
 				schedule_timeout(HZ / 2);
 			}
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 128b7d15d760..3298a9923ea2 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1243,7 +1243,7 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 		 * simulate an OST->client data error
 		 */
 		if (unlikely(i == 0 && opc == OST_READ &&
-			     OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE))) {
+			     CFS_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE))) {
 			unsigned char *ptr = kmap(pga[i]->pg);
 
 			memcpy(ptr + off, "bad1", min_t(typeof(nob), 4, nob));
@@ -1292,7 +1292,7 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 		 * of corrupting the data so it is still correct on a redo
 		 */
 		if (opc == OST_WRITE &&
-		    OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
+		    CFS_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
 			cksum++;
 
 		*check_sum = cksum;
@@ -1328,7 +1328,7 @@ static int osc_checksum_bulk(int nob, u32 pg_count,
 		 * simulate an OST->client data error
 		 */
 		if (i == 0 && opc == OST_READ &&
-		    OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE)) {
+		    CFS_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE)) {
 			unsigned char *ptr = kmap(pga[i]->pg);
 			int off = pga[i]->off & ~PAGE_MASK;
 
@@ -1356,7 +1356,7 @@ static int osc_checksum_bulk(int nob, u32 pg_count,
 	/* For sending we only compute the wrong checksum instead
 	 * of corrupting the data so it is still correct on a redo
 	 */
-	if (opc == OST_WRITE && OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
+	if (opc == OST_WRITE && CFS_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
 		(*cksum)++;
 
 	return 0;
@@ -1537,9 +1537,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		if (clpage->cp_type == CPT_TRANSIENT)
 			directio = true;
 	}
-	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
+	if (CFS_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
-	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ2))
+	if (CFS_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ2))
 		return -EINVAL; /* Fatal */
 
 	if ((cmd & OBD_BRW_WRITE) != 0) {
@@ -1804,7 +1804,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 	if (inode && IS_ENCRYPTED(inode) &&
 	    fscrypt_has_encryption_key(inode) &&
-	    !OBD_FAIL_CHECK(OBD_FAIL_LFSCK_NO_ENCFLAG)) {
+	    !CFS_FAIL_CHECK(OBD_FAIL_LFSCK_NO_ENCFLAG)) {
 		if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
 			body->oa.o_valid |= OBD_MD_FLFLAGS;
 			body->oa.o_flags = 0;
@@ -2846,7 +2846,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		       cmd == OBD_BRW_READ ? "read" : "write", starting_offset,
 		       ending_offset, cli->cl_r_in_flight, cli->cl_w_in_flight);
 	}
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_IO, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_IO, cfs_fail_val);
 
 	ptlrpcd_add_req(req);
 	rc = 0;
@@ -2987,10 +2987,10 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	ldlm_lock_addref(lockh, mode);
 
 	/* Let cl_lock_state_wait fail with -ERESTARTSYS to unuse sublocks. */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_HANG, 2);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_HANG, 2);
 
 	/* Let CP AST to grant the lock first. */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
 	if (aa->oa_speculative) {
 		LASSERT(!aa->oa_lvb);
@@ -3006,7 +3006,7 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	rc = osc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
 			      aa->oa_flags, aa->oa_speculative, rc);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
 
 	ldlm_lock_decref(lockh, mode);
 	LDLM_LOCK_PUT(lock);
@@ -3165,7 +3165,7 @@ int osc_match_base(const struct lu_env *env, struct obd_export *exp,
 	u64 lflags = *flags;
 	enum ldlm_mode rc;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_MATCH))
+	if (CFS_FAIL_CHECK(OBD_FAIL_OSC_MATCH))
 		return -EIO;
 
 	/* Filesystem lock extents are extended to page boundaries so that
@@ -3432,7 +3432,7 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	char *tmp;
 	int rc;
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_SHUTDOWN, 10);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_OSC_SHUTDOWN, 10);
 
 	if (KEY_IS(KEY_CHECKSUM)) {
 		if (vallen != sizeof(int))
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
