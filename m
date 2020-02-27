From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:37 -0500
Subject: [lustre-devel] [PATCH 349/622] lnet: drop all rule
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-350-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add a rule to drop all messages arriving on a specific interface.
This is useful for simulating failures on a specific router interface.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11470
Lustre-commit: deb31c2ffad5 ("LU-11470 lnet: drop all rule")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33305
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h     |  3 ++-
 include/uapi/linux/lnet/lnetctl.h |  6 ++++++
 net/lnet/lnet/lib-move.c          |  2 +-
 net/lnet/lnet/lib-msg.c           |  7 +++++--
 net/lnet/lnet/net_fault.c         | 28 +++++++++++++++++++++-------
 5 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 5a83e3a..4dee7a9 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -663,7 +663,8 @@ void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 int lnet_fault_init(void);
 void lnet_fault_fini(void);
 
-bool lnet_drop_rule_match(struct lnet_hdr *hdr, enum lnet_msg_hstatus *hstatus);
+bool lnet_drop_rule_match(struct lnet_hdr *hdr, lnet_nid_t local_nid,
+			  enum lnet_msg_hstatus *hstatus);
 
 int lnet_delay_rule_add(struct lnet_fault_attr *attr);
 int lnet_delay_rule_del(lnet_nid_t src, lnet_nid_t dst, bool shutdown);
diff --git a/include/uapi/linux/lnet/lnetctl.h b/include/uapi/linux/lnet/lnetctl.h
index 2eb9c82..bd08b4f 100644
--- a/include/uapi/linux/lnet/lnetctl.h
+++ b/include/uapi/linux/lnet/lnetctl.h
@@ -64,6 +64,10 @@ struct lnet_fault_attr {
 	lnet_nid_t			fa_src;
 	/** destination NID of drop rule, see @dr_src for details */
 	lnet_nid_t			fa_dst;
+	/** local NID. In case of router this is the NID we're ceiving
+	 * messages on
+	 */
+	lnet_nid_t			fa_local_nid;
 	/**
 	 * Portal mask to drop, -1 means all portals, for example:
 	 * fa_ptl_mask = (1 << _LDLM_CB_REQUEST_PORTAL ) |
@@ -95,6 +99,8 @@ struct lnet_fault_attr {
 			__u32			da_health_error_mask;
 			/** randomize error generation */
 			bool			da_random;
+			/** drop all messages if flag is set */
+			bool			da_drop_all;
 		} drop;
 		/** message latency simulation */
 		struct {
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 90b4e3f..fff9fea 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3964,7 +3964,7 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	if (!list_empty(&the_lnet.ln_drop_rules) &&
-	    lnet_drop_rule_match(hdr, NULL)) {
+	    lnet_drop_rule_match(hdr, ni->ni_nid, NULL)) {
 		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       libcfs_nid2str(dest_nid), lnet_msgtyp2str(type));
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 2cbaff8a..8876866 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -900,11 +900,14 @@
 		return false;
 
 	/* match only health rules */
-	if (!lnet_drop_rule_match(&msg->msg_hdr, hstatus))
+	if (!lnet_drop_rule_match(&msg->msg_hdr, LNET_NID_ANY,
+				  hstatus))
 		return false;
 
-	CDEBUG(D_NET, "src %s, dst %s: %s simulate health error: %s\n",
+	CDEBUG(D_NET,
+	       "src %s(%s)->dst %s: %s simulate health error: %s\n",
 	       libcfs_nid2str(msg->msg_hdr.src_nid),
+	       libcfs_nid2str(msg->msg_txni->ni_nid),
 	       libcfs_nid2str(msg->msg_hdr.dest_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(*hstatus));
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index becb709..9f78e43 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -79,10 +79,12 @@ struct lnet_drop_rule {
 
 static bool
 lnet_fault_attr_match(struct lnet_fault_attr *attr, lnet_nid_t src,
-		      lnet_nid_t dst, unsigned int type, unsigned int portal)
+		      lnet_nid_t local_nid, lnet_nid_t dst,
+		      unsigned int type, unsigned int portal)
 {
 	if (!lnet_fault_nid_match(attr->fa_src, src) ||
-	    !lnet_fault_nid_match(attr->fa_dst, dst))
+	    !lnet_fault_nid_match(attr->fa_dst, dst) ||
+	    !lnet_fault_nid_match(attr->fa_local_nid, local_nid))
 		return false;
 
 	if (!(attr->fa_msg_mask & (1 << type)))
@@ -340,15 +342,22 @@ struct lnet_drop_rule {
  */
 static bool
 drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
-		lnet_nid_t dst, unsigned int type, unsigned int portal,
+		lnet_nid_t local_nid, lnet_nid_t dst,
+		unsigned int type, unsigned int portal,
 		enum lnet_msg_hstatus *hstatus)
 {
 	struct lnet_fault_attr *attr = &rule->dr_attr;
 	bool drop;
 
-	if (!lnet_fault_attr_match(attr, src, dst, type, portal))
+	if (!lnet_fault_attr_match(attr, src, local_nid, dst, type, portal))
 		return false;
 
+	if (attr->u.drop.da_drop_all) {
+		CDEBUG(D_NET, "set to drop all messages\n");
+		drop = true;
+		goto drop_matched;
+	}
+
 	/* if we're trying to match a health status error but it hasn't
 	 * been set in the rule, then don't match
 	 */
@@ -396,6 +405,8 @@ struct lnet_drop_rule {
 		}
 	}
 
+drop_matched:
+
 	if (drop) { /* drop this message, update counters */
 		if (hstatus)
 			lnet_fault_match_health(hstatus,
@@ -412,7 +423,9 @@ struct lnet_drop_rule {
  * Check if message from @src to @dst can match any existed drop rule
  */
 bool
-lnet_drop_rule_match(struct lnet_hdr *hdr, enum lnet_msg_hstatus *hstatus)
+lnet_drop_rule_match(struct lnet_hdr *hdr,
+		     lnet_nid_t local_nid,
+		     enum lnet_msg_hstatus *hstatus)
 {
 	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
 	lnet_nid_t dst = le64_to_cpu(hdr->dest_nid);
@@ -433,7 +446,7 @@ struct lnet_drop_rule {
 
 	cpt = lnet_net_lock_current();
 	list_for_each_entry(rule, &the_lnet.ln_drop_rules, dr_link) {
-		drop = drop_rule_match(rule, src, dst, typ, ptl,
+		drop = drop_rule_match(rule, src, local_nid, dst, typ, ptl,
 				       hstatus);
 		if (drop)
 			break;
@@ -524,7 +537,8 @@ struct delay_daemon_data {
 	struct lnet_fault_attr *attr = &rule->dl_attr;
 	bool delay;
 
-	if (!lnet_fault_attr_match(attr, src, dst, type, portal))
+	if (!lnet_fault_attr_match(attr, src, LNET_NID_ANY,
+				   dst, type, portal))
 		return false;
 
 	/* match this rule, check delay rate now */
-- 
1.8.3.1
