From: Lidza Louina <lidza.louina@oracle.com>
Date: Mon, 16 May 2016 14:51:42 -0400
Subject: [lustre-devel] [PATCH v3] staging/lustre/ptlrpc: Removes potential
	null dereference
Message-ID: <1463424702-5467-1-git-send-email-lidza.louina@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The lustre_msg_buf method could return NULL. Subsequent code didn't
check if it's null before using it. This patch adds two checks.

Signed-off-by: Lidza Louina <lidza.louina@oracle.com>
---
 drivers/staging/lustre/lustre/ptlrpc/sec.c       | 3 +++
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c | 8 ++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 187fd1d..657b41f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -2196,6 +2196,9 @@ int sptlrpc_pack_user_desc(struct lustre_msg *msg, int offset)
 
 	pud = lustre_msg_buf(msg, offset, 0);
 
+	if (!pud)
+		return -EINVAL;
+
 	pud->pud_uid = from_kuid(&init_user_ns, current_uid());
 	pud->pud_gid = from_kgid(&init_user_ns, current_gid());
 	pud->pud_fsuid = from_kuid(&init_user_ns, current_fsuid());
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 37c9f4c..ec8edbf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -574,8 +574,12 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
 	lustre_init_msg_v2(req->rq_reqbuf, PLAIN_PACK_SEGMENTS, buflens, NULL);
 	req->rq_reqmsg = lustre_msg_buf(req->rq_reqbuf, PLAIN_PACK_MSG_OFF, 0);
 
-	if (req->rq_pack_udesc)
-		sptlrpc_pack_user_desc(req->rq_reqbuf, PLAIN_PACK_USER_OFF);
+	if (req->rq_pack_udesc) {
+		int rc = sptlrpc_pack_user_desc(req->rq_reqbuf,
+					      PLAIN_PACK_USER_OFF);
+		if (rc < 0)
+			return rc;
+	}
 
 	return 0;
 }
-- 
1.9.1
