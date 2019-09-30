From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:32 -0400
Subject: [lustre-devel] [PATCH 133/151] lustre: misc: Wrong checksum return
 value
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-134-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

In the checksum calculation functions: tgt_checksum_niobuf and
osc_checksum_bulk, it is wrongly taken the error return value
of cfs_crypto_hash_init as the checksum value.
This patch fixes the problem.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10737
Lustre-commit: 28b8f3d9296d ("LU-10737 misc: Wrong checksum return value")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/31448
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 51 ++++++++++++++++++++++++++++-----------------
 1 file changed, 32 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 5797535..0a3d05e 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1028,11 +1028,11 @@ static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 	return (p1->off + p1->count == p2->off);
 }
 
-static u32 osc_checksum_bulk(int nob, u32 pg_count,
+static int osc_checksum_bulk(int nob, u32 pg_count,
 			     struct brw_page **pga, int opc,
-			     enum cksum_type cksum_type)
+			     enum cksum_type cksum_type,
+			     u32 *cksum)
 {
-	u32 cksum;
 	int i = 0;
 	struct ahash_request *hdesc;
 	unsigned int bufsize;
@@ -1076,16 +1076,16 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 		i++;
 	}
 
-	bufsize = sizeof(cksum);
-	cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
+	bufsize = sizeof(*cksum);
+	cfs_crypto_hash_final(hdesc, (unsigned char *)cksum, &bufsize);
 
 	/* For sending we only compute the wrong checksum instead
 	 * of corrupting the data so it is still correct on a redo
 	 */
 	if (opc == OST_WRITE && OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
-		cksum++;
+		(*cksum)++;
 
-	return cksum;
+	return 0;
 }
 
 static int osc_brw_prep_request(int cmd, struct client_obd *cli,
@@ -1296,12 +1296,18 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 			body->oa.o_flags |= cksum_type_pack(cksum_type);
 			body->oa.o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
-			body->oa.o_cksum = osc_checksum_bulk(requested_nob,
-							     page_count, pga,
-							     OST_WRITE,
-							     cksum_type);
+
+			rc = osc_checksum_bulk(requested_nob, page_count,
+					       pga, OST_WRITE, cksum_type,
+					       &body->oa.o_cksum);
+			if (rc < 0) {
+				CDEBUG(D_PAGE, "failed to checksum, rc = %d\n",
+				       rc);
+				goto out;
+			}
 			CDEBUG(D_PAGE, "checksum@write origin: %x\n",
 			       body->oa.o_cksum);
+
 			/* save this in 'oa', too, for later checking */
 			oa->o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
 			oa->o_flags |= cksum_type_pack(cksum_type);
@@ -1427,6 +1433,7 @@ static int check_write_checksum(struct obdo *oa,
 	u32 new_cksum;
 	char *msg;
 	enum cksum_type cksum_type;
+	int rc;
 
 	if (server_cksum == client_cksum) {
 		CDEBUG(D_PAGE, "checksum %x confirmed\n", client_cksum);
@@ -1439,10 +1446,13 @@ static int check_write_checksum(struct obdo *oa,
 
 	cksum_type = cksum_type_unpack(oa->o_valid & OBD_MD_FLFLAGS ?
 				       oa->o_flags : 0);
-	new_cksum = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
-				      aa->aa_ppga, OST_WRITE, cksum_type);
+	rc = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
+			       aa->aa_ppga, OST_WRITE, cksum_type,
+			       &new_cksum);
 
-	if (cksum_type != cksum_type_unpack(aa->aa_oa->o_flags))
+	if (rc < 0)
+		msg = "failed to calculate the client write checksum";
+	else if (cksum_type != cksum_type_unpack(aa->aa_oa->o_flags))
 		msg = "the server did not use the checksum type specified in the original request - likely a protocol problem";
 	else if (new_cksum == server_cksum)
 		msg = "changed on the client after we checksummed it - likely false positive due to mmap IO (bug 11742)";
@@ -1599,13 +1609,16 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		char *router = "";
 		enum cksum_type cksum_type;
 
-		cksum_type = cksum_type_unpack(body->oa.o_valid &
-					       OBD_MD_FLFLAGS ?
+		cksum_type = cksum_type_unpack(body->oa.o_valid & OBD_MD_FLFLAGS ?
 					       body->oa.o_flags : 0);
-		client_cksum = osc_checksum_bulk(rc, aa->aa_page_count,
-						 aa->aa_ppga, OST_READ,
-						 cksum_type);
 
+		rc = osc_checksum_bulk(rc, aa->aa_page_count, aa->aa_ppga,
+				       OST_READ, cksum_type, &client_cksum);
+		if (rc < 0) {
+			CDEBUG(D_PAGE,
+			       "failed to calculate checksum, rc = %d\n", rc);
+			goto out;
+		}
 		if (req->rq_bulk &&
 		    peer->nid != req->rq_bulk->bd_sender) {
 			via = " via ";
-- 
1.8.3.1
