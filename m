From: Nikola Jelic <nikola.jelic83@gmail.com>
Date: Sun, 28 May 2017 00:14:11 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: in-place endianness
	functions
Message-ID: <20170527221411.23772-1-nikola.jelic83@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lib-move.c file has a lot of expressions in the form of:
v = le[32|64]_to_cpu(v);
This caused a lot of sparse warnings.
Replaced with:
le[32|64]_to_cpus(&v);

Signed-off-by: Nikola Jelic <nikola.jelic83@gmail.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index a99c5c0aa672..20ebe247071f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1274,9 +1274,9 @@ lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
 	int rc;
 
 	/* Convert put fields to host byte order */
-	hdr->msg.put.match_bits	= le64_to_cpu(hdr->msg.put.match_bits);
-	hdr->msg.put.ptl_index	= le32_to_cpu(hdr->msg.put.ptl_index);
-	hdr->msg.put.offset	= le32_to_cpu(hdr->msg.put.offset);
+	le64_to_cpus(&hdr->msg.put.match_bits);
+	le32_to_cpus(&hdr->msg.put.ptl_index);
+	le32_to_cpus(&hdr->msg.put.offset);
 
 	info.mi_id.nid	= hdr->src_nid;
 	info.mi_id.pid	= hdr->src_pid;
@@ -1332,10 +1332,10 @@ lnet_parse_get(struct lnet_ni *ni, struct lnet_msg *msg, int rdma_get)
 	int rc;
 
 	/* Convert get fields to host byte order */
-	hdr->msg.get.match_bits  = le64_to_cpu(hdr->msg.get.match_bits);
-	hdr->msg.get.ptl_index   = le32_to_cpu(hdr->msg.get.ptl_index);
-	hdr->msg.get.sink_length = le32_to_cpu(hdr->msg.get.sink_length);
-	hdr->msg.get.src_offset  = le32_to_cpu(hdr->msg.get.src_offset);
+	le64_to_cpus(&hdr->msg.get.match_bits);
+	le32_to_cpus(&hdr->msg.get.ptl_index);
+	le32_to_cpus(&hdr->msg.get.sink_length);
+	le32_to_cpus(&hdr->msg.get.src_offset);
 
 	info.mi_id.nid  = hdr->src_nid;
 	info.mi_id.pid  = hdr->src_pid;
@@ -1464,8 +1464,8 @@ lnet_parse_ack(struct lnet_ni *ni, struct lnet_msg *msg)
 	src.pid = hdr->src_pid;
 
 	/* Convert ack fields to host byte order */
-	hdr->msg.ack.match_bits = le64_to_cpu(hdr->msg.ack.match_bits);
-	hdr->msg.ack.mlength = le32_to_cpu(hdr->msg.ack.mlength);
+	le64_to_cpus(&hdr->msg.ack.match_bits);
+	le32_to_cpus(&hdr->msg.ack.mlength);
 
 	cpt = lnet_cpt_of_cookie(hdr->msg.ack.dst_wmd.wh_object_cookie);
 	lnet_res_lock(cpt);
@@ -1798,7 +1798,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 		/* convert common msg->hdr fields to host byteorder */
 		msg->msg_hdr.type	= type;
 		msg->msg_hdr.src_nid	= src_nid;
-		msg->msg_hdr.src_pid	= le32_to_cpu(msg->msg_hdr.src_pid);
+		le32_to_cpus(&msg->msg_hdr.src_pid);
 		msg->msg_hdr.dest_nid	= dest_nid;
 		msg->msg_hdr.dest_pid	= dest_pid;
 		msg->msg_hdr.payload_length = payload_length;
-- 
2.11.0
