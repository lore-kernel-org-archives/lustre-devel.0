From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:13 -0400
Subject: [lustre-devel] [PATCH 17/23] lnet: discard unused lnet_print_hdr()
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

lnet_print_hdr() is unused, and has not been used in git history since
at least 2004.
So remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 58d4a4c38ab1b ("LU-6142 lnet: discard unused lnet_print_hdr()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39358
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 -
 net/lnet/lnet/lib-move.c      | 58 -------------------------------------------
 2 files changed, 59 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e733807..299ecf5 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -590,7 +590,6 @@ void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 
 char *lnet_health_error2str(enum lnet_msg_hstatus hstatus);
 char *lnet_msgtyp2str(int type);
-void lnet_print_hdr(struct lnet_hdr *hdr);
 int lnet_fail_nid(lnet_nid_t nid, unsigned int threshold);
 
 /** \addtogroup lnet_fault_simulation @{ */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 7c14518..85b6453 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3940,64 +3940,6 @@ void lnet_monitor_thr_stop(void)
 	}
 }
 
-void
-lnet_print_hdr(struct lnet_hdr *hdr)
-{
-	struct lnet_process_id src = { 0 };
-	struct lnet_process_id dst = { 0 };
-	char *type_str = lnet_msgtyp2str(hdr->type);
-
-	src.nid = hdr->src_nid;
-	src.pid = hdr->src_pid;
-
-	dst.nid = hdr->dest_nid;
-	dst.pid = hdr->dest_pid;
-
-	CWARN("P3 Header at %p of type %s\n", hdr, type_str);
-	CWARN("    From %s\n", libcfs_id2str(src));
-	CWARN("    To   %s\n", libcfs_id2str(dst));
-
-	switch (hdr->type) {
-	default:
-		break;
-
-	case LNET_MSG_PUT:
-		CWARN("    Ptl index %d, ack md %#llx.%#llx, match bits %llu\n",
-		      hdr->msg.put.ptl_index,
-		      hdr->msg.put.ack_wmd.wh_interface_cookie,
-		      hdr->msg.put.ack_wmd.wh_object_cookie,
-		      hdr->msg.put.match_bits);
-		CWARN("    Length %d, offset %d, hdr data %#llx\n",
-		      hdr->payload_length, hdr->msg.put.offset,
-		      hdr->msg.put.hdr_data);
-		break;
-
-	case LNET_MSG_GET:
-		CWARN("    Ptl index %d, return md %#llx.%#llx, match bits %llu\n",
-		      hdr->msg.get.ptl_index,
-		      hdr->msg.get.return_wmd.wh_interface_cookie,
-		      hdr->msg.get.return_wmd.wh_object_cookie,
-		      hdr->msg.get.match_bits);
-		CWARN("    Length %d, src offset %d\n",
-		      hdr->msg.get.sink_length,
-		      hdr->msg.get.src_offset);
-		break;
-
-	case LNET_MSG_ACK:
-		CWARN("    dst md %#llx.%#llx, manipulated length %d\n",
-		      hdr->msg.ack.dst_wmd.wh_interface_cookie,
-		      hdr->msg.ack.dst_wmd.wh_object_cookie,
-		      hdr->msg.ack.mlength);
-		break;
-
-	case LNET_MSG_REPLY:
-		CWARN("    dst md %#llx.%#llx, length %d\n",
-		      hdr->msg.reply.dst_wmd.wh_interface_cookie,
-		      hdr->msg.reply.dst_wmd.wh_object_cookie,
-		      hdr->payload_length);
-	}
-}
-
 int
 lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	   void *private, int rdma_req)
-- 
1.8.3.1
