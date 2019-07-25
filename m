From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Jul 2019 22:44:06 -0400
Subject: [lustre-devel] [PATCH 7/8] lustre: tests: testcases for multiple
 modify RPCs feature
In-Reply-To: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
References: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1564022647-17351-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gregoire Pichon <gregoire.pichon@bull.net>

This patch creates new testcases in the Auster test suite to
test the support of multiple modify RPCs in flight feature.

Two new OBD_FAIL codes are added to allow several failure occurences
of the reint requests or replies. This is needed because the current
fail checks impose the OBD_FAIL_ONCE flag.

Added testcases are :
- sanity         245
- conf-sanity    90a 90b 90c 90d
- replay-single  102a 102b 102c 102d

This patch also removes replay-single tests 53a and 53b
from the ALWAYS_EXCEPT list.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5319
Lustre-commit: c2d27a0f12688c0d029880919f8b002e557b540c
Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Reviewed-on: http://review.whamcloud.com/14861
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
---
 fs/lustre/include/obd_support.h | 2 ++
 fs/lustre/ldlm/ldlm_lib.c       | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 3e15cac..7999ac6 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -189,6 +189,8 @@
 #define OBD_FAIL_MDS_SWAP_LAYOUTS_NET			0x14f
 #define OBD_FAIL_MDS_HSM_ACTION_NET			0x150
 #define OBD_FAIL_MDS_CHANGELOG_INIT			0x151
+#define OBD_FAIL_MDS_REINT_MULTI_NET			0x159
+#define OBD_FAIL_MDS_REINT_MULTI_NET_REP		0x15a
 
 /* layout lock */
 #define OBD_FAIL_MDS_NO_LL_GETATTR			0x170
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 887507d..a3b8df4 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -689,6 +689,9 @@ int target_pack_pool_reply(struct ptlrpc_request *req)
 		DEBUG_REQ(D_ERROR, req, "dropping reply");
 		return -ECOMM;
 	}
+	if (unlikely(lustre_msg_get_opc(req->rq_reqmsg) == MDS_REINT &&
+		     OBD_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
+		return -ECOMM;
 
 	if (unlikely(rc)) {
 		DEBUG_REQ(D_NET, req, "processing error (%d)", rc);
-- 
1.8.3.1
