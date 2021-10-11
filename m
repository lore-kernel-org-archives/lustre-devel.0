Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7FE9C433FE
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:06 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7393F60EBB
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 7393F60EBB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 83E1C380CEA;
	Mon, 11 Oct 2021 10:41:01 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 39CFF21FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B2AAD266;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AA4ABD5A4E; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:35 -0400
Message-Id: <1633974049-26490-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/20] lustre: brw: log T10 GRD tags during
 checksum calcs
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

From: Andreas Dilger <adilger@whamcloud.com>

Log the T10 guard tags during checksum calculation on the client and
target to help identify where checksum errors are being introduced.
The added debugging is only active on RPC resend, so will not add
overhead during the normal IO path.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14895
Lustre-commit: c628b1b441d0ee191 ("LU-14895 brw: log T10 GRD tags during checksum calcs")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44655
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 83 ++++++++++++++++++++++++++-------------------
 1 file changed, 49 insertions(+), 34 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index db73fce..def2ee7 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1186,7 +1186,7 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 				   size_t pg_count, struct brw_page **pga,
 				   int opc, obd_dif_csum_fn *fn,
 				   int sector_size,
-				   u32 *check_sum)
+				   u32 *check_sum, bool resend)
 {
 	struct ahash_request *hdesc;
 	/* Used Adler as the default checksum type on top of DIF tags */
@@ -1219,6 +1219,10 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 	buffer = kmap(__page);
 	guard_start = (u16 *)buffer;
 	guard_number = PAGE_SIZE / sizeof(*guard_start);
+	CDEBUG(D_PAGE | (resend ? D_HA : 0),
+	       "GRD tags per page=%u, resend=%u, bytes=%u, pages=%zu\n",
+	       guard_number, resend, nob, pg_count);
+
 	while (nob > 0 && pg_count > 0) {
 		unsigned int count = pga[i]->count > nob ? nob : pga[i]->count;
 
@@ -1245,6 +1249,12 @@ static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
 						  guard_number - used_number,
 						  &used, sector_size,
 						  fn);
+		if (unlikely(resend))
+			CDEBUG(D_PAGE | D_HA,
+			       "pga[%u]: used %u off %llu+%u gen checksum: %*phN\n",
+			       i, used, pga[i]->off & ~PAGE_MASK, count,
+			       (int)(used * sizeof(*guard_start)),
+			       guard_start + used_number);
 		if (rc)
 			break;
 
@@ -1346,7 +1356,7 @@ static int osc_checksum_bulk_rw(const char *obd_name,
 				enum cksum_types cksum_type,
 				int nob, size_t pg_count,
 				struct brw_page **pga, int opc,
-				u32 *check_sum)
+				u32 *check_sum, bool resend)
 {
 	obd_dif_csum_fn *fn = NULL;
 	int sector_size = 0;
@@ -1356,7 +1366,8 @@ static int osc_checksum_bulk_rw(const char *obd_name,
 
 	if (fn)
 		rc = osc_checksum_bulk_t10pi(obd_name, nob, pg_count, pga,
-					     opc, fn, sector_size, check_sum);
+					     opc, fn, sector_size, check_sum,
+					     resend);
 	else
 		rc = osc_checksum_bulk(nob, pg_count, pga, opc, cksum_type,
 				       check_sum);
@@ -1727,14 +1738,15 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			rc = osc_checksum_bulk_rw(obd_name, cksum_type,
 						  requested_nob, page_count,
 						  pga, OST_WRITE,
-						  &body->oa.o_cksum);
+						  &body->oa.o_cksum, resend);
 			if (rc < 0) {
-				CDEBUG(D_PAGE, "failed to checksum, rc = %d\n",
+				CDEBUG(D_PAGE, "failed to checksum: rc = %d\n",
 				       rc);
 				goto out;
 			}
-			CDEBUG(D_PAGE, "checksum at write origin: %x\n",
-			       body->oa.o_cksum);
+			CDEBUG(D_PAGE | (resend ? D_HA : 0),
+			       "checksum at write origin: %x (%x)\n",
+			       body->oa.o_cksum, cksum_type);
 
 			/* save this in 'oa', too, for later checking */
 			oa->o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
@@ -1814,6 +1826,7 @@ static void dump_all_bulk_pages(struct obdo *oa, u32 page_count,
 		 pga[0]->off,
 		 pga[page_count - 1]->off + pga[page_count - 1]->count - 1,
 		 client_cksum, server_cksum);
+	CWARN("dumping checksum data to %s\n", dbgcksum_file_name);
 	filp = filp_open(dbgcksum_file_name,
 			 O_CREAT | O_EXCL | O_WRONLY | O_LARGEFILE, 0600);
 	if (IS_ERR(filp)) {
@@ -1840,8 +1853,6 @@ static void dump_all_bulk_pages(struct obdo *oa, u32 page_count,
 			}
 			len -= rc;
 			buf += rc;
-			CDEBUG(D_INFO, "%s: wrote %d bytes\n",
-			       dbgcksum_file_name, rc);
 		}
 		kunmap(pga[i]->pg);
 	}
@@ -1850,6 +1861,8 @@ static void dump_all_bulk_pages(struct obdo *oa, u32 page_count,
 	if (rc)
 		CERROR("%s: sync returns %d\n", dbgcksum_file_name, rc);
 	filp_close(filp, NULL);
+
+	libcfs_debug_dumplog();
 }
 
 static int check_write_checksum(struct obdo *oa,
@@ -1902,7 +1915,7 @@ static int check_write_checksum(struct obdo *oa,
 		rc = osc_checksum_bulk_t10pi(obd_name, aa->aa_requested_nob,
 					     aa->aa_page_count, aa->aa_ppga,
 					     OST_WRITE, fn, sector_size,
-					     &new_cksum);
+					     &new_cksum, true);
 	else
 		rc = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
 				       aa->aa_ppga, OST_WRITE, cksum_type,
@@ -2067,17 +2080,18 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	if (body->oa.o_valid & OBD_MD_FLCKSUM) {
 		static int cksum_counter;
 		u32 server_cksum = body->oa.o_cksum;
+		int nob = rc;
 		char *via = "";
 		char *router = "";
 		enum cksum_types cksum_type;
 		u32 o_flags = body->oa.o_valid & OBD_MD_FLFLAGS ?
-			body->oa.o_flags : 0;
+			      body->oa.o_flags : 0;
 
 		cksum_type = obd_cksum_type_unpack(o_flags);
 
-		rc = osc_checksum_bulk_rw(obd_name, cksum_type, rc,
+		rc = osc_checksum_bulk_rw(obd_name, cksum_type, nob,
 					  aa->aa_page_count, aa->aa_ppga,
-					  OST_READ, &client_cksum);
+					  OST_READ, &client_cksum, false);
 		if (rc < 0)
 			goto out;
 
@@ -2090,7 +2104,11 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		if (server_cksum != client_cksum) {
 			u32 page_count = aa->aa_page_count;
 			struct ost_body *clbody;
+			u32 client_cksum2;
 
+			osc_checksum_bulk_rw(obd_name, cksum_type, nob,
+					     page_count, aa->aa_ppga,
+					     OST_READ, &client_cksum2, true);
 			clbody = req_capsule_client_get(&req->rq_pill,
 							&RMF_OST_BODY);
 			if (cli->cl_checksum_dump)
@@ -2098,26 +2116,23 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 						    aa->aa_ppga, server_cksum,
 						    client_cksum);
 
-			LCONSOLE_ERROR_MSG(
-				0x133,
-				"%s: BAD READ CHECKSUM: from %s%s%s inode " DFID
-				" object " DOSTID
-				" extent [%llu-%llu], client %x, server %x, cksum_type %x\n",
-				obd_name,
-				libcfs_nid2str(peer->nid),
-				via, router,
-				clbody->oa.o_valid & OBD_MD_FLFID ?
-				clbody->oa.o_parent_seq : (u64)0,
-				clbody->oa.o_valid & OBD_MD_FLFID ?
-				clbody->oa.o_parent_oid : 0,
-				clbody->oa.o_valid & OBD_MD_FLFID ?
-				clbody->oa.o_parent_ver : 0,
-				POSTID(&body->oa.o_oi),
-				aa->aa_ppga[0]->off,
-				aa->aa_ppga[page_count - 1]->off +
-				aa->aa_ppga[page_count - 1]->count - 1,
-				client_cksum, server_cksum,
-				cksum_type);
+			LCONSOLE_ERROR_MSG(0x133,
+					   "%s: BAD READ CHECKSUM: from %s%s%s inode "DFID" object "DOSTID" extent [%llu-%llu], client %x/%x, server %x, cksum_type %x\n",
+					   obd_name,
+					   libcfs_nid2str(peer->nid),
+					   via, router,
+					   clbody->oa.o_valid & OBD_MD_FLFID ?
+					   clbody->oa.o_parent_seq : (u64)0,
+					   clbody->oa.o_valid & OBD_MD_FLFID ?
+					   clbody->oa.o_parent_oid : 0,
+					   clbody->oa.o_valid & OBD_MD_FLFID ?
+					   clbody->oa.o_parent_ver : 0,
+					   POSTID(&body->oa.o_oi),
+					   aa->aa_ppga[0]->off,
+					   aa->aa_ppga[page_count - 1]->off +
+					   aa->aa_ppga[page_count - 1]->count - 1,
+					   client_cksum, client_cksum2,
+					   server_cksum, cksum_type);
 			cksum_counter = 0;
 			aa->aa_oa->o_cksum = client_cksum;
 			rc = -EAGAIN;
@@ -2356,7 +2371,7 @@ static int brw_interpret(const struct lu_env *env,
 			       req->rq_import->imp_obd->obd_name,
 			       POSTID(&aa->aa_oa->o_oi), rc);
 		} else if (rc == -EINPROGRESS ||
-		    client_should_resend(aa->aa_resends, aa->aa_cli)) {
+			   client_should_resend(aa->aa_resends, aa->aa_cli)) {
 			rc = osc_brw_redo_request(req, aa, rc);
 		} else {
 			CERROR("%s: too many resent retries for object: %llu:%llu, rc = %d.\n",
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
