From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:11 -0500
Subject: [lustre-devel] [PATCH 563/622] lnet: libcfs: provide an scnprintf
 and start using it
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-564-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

snprintf() returns the number of chars that would be needed to hold
the complete result, which may be larger that the buffer size.

scnprintf differs in it's return value is number of chars actually
written (not including the terminating null).

Correct the few patterns where the return from snprintf() is used and
expected not to exceed the passed buffer size.

Cray-bug-id: LUS-7999
WC-bug-id: https://jira.whamcloud.com/browse/LU-12861
Lustre-commit: 998a494fa9a4 ("LU-12861 libcfs: provide an scnprintf and start using it")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/36453
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c   |   6 +--
 net/lnet/lnet/config.c      |   6 +--
 net/lnet/lnet/router_proc.c | 128 ++++++++++++++++++++++----------------------
 3 files changed, 70 insertions(+), 70 deletions(-)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 2bc7047..d545d1b 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -703,9 +703,9 @@ static ssize_t grant_shrink_show(struct kobject *kobj, struct attribute *attr,
 		return len;
 
 	imp = obd->u.cli.cl_import;
-	len = snprintf(buf, PAGE_SIZE, "%d\n",
-		       !imp->imp_grant_shrink_disabled &&
-		       OCD_HAS_FLAG(&imp->imp_connect_data, GRANT_SHRINK));
+	len = scnprintf(buf, PAGE_SIZE, "%d\n",
+			!imp->imp_grant_shrink_disabled &&
+			OCD_HAS_FLAG(&imp->imp_connect_data, GRANT_SHRINK));
 	up_read(&obd->u.cli.cl_sem);
 
 	return len;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 8994882..f50df88 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1535,9 +1535,9 @@ struct lnet_ni *
 
 			list_move_tail(&tb->ltb_list, &matched_nets);
 
-			len += snprintf(networks + len, sizeof(networks) - len,
-					"%s%s", !len ? "" : ",",
-					tb->ltb_text);
+			len += scnprintf(networks + len, sizeof(networks) - len,
+					 "%s%s", !len ? "" : ",",
+					 tb->ltb_text);
 
 			if (len >= sizeof(networks)) {
 				CERROR("Too many matched networks\n");
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 2e9342c..180bbde 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -105,16 +105,16 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
 	lnet_counters_get(ctrs);
 	common = ctrs->lct_common;
 
-	len = snprintf(tmpstr, tmpsiz,
-		       "%u %u %u %u %u %u %u %llu %llu %llu %llu",
-		       common.lcc_msgs_alloc, common.lcc_msgs_max,
-		       common.lcc_errors,
-		       common.lcc_send_count, common.lcc_recv_count,
-		       common.lcc_route_count, common.lcc_drop_count,
-		       common.lcc_send_length, common.lcc_recv_length,
-		       common.lcc_route_length, common.lcc_drop_length);
-
-	if (pos >= min_t(int, len, strlen(tmpstr)))
+	len = scnprintf(tmpstr, tmpsiz,
+			"%u %u %u %u %u %u %u %llu %llu %llu %llu",
+			common.lcc_msgs_alloc, common.lcc_msgs_max,
+			common.lcc_errors,
+			common.lcc_send_count, common.lcc_recv_count,
+			common.lcc_route_count, common.lcc_drop_count,
+			common.lcc_send_length, common.lcc_recv_length,
+			common.lcc_route_length, common.lcc_drop_length);
+
+	if (pos >= len)
 		rc = 0;
 	else
 		rc = cfs_trace_copyout_string(buffer, nob,
@@ -153,12 +153,12 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 	s = tmpstr; /* points to current position in tmpstr[] */
 
 	if (!*ppos) {
-		s += snprintf(s, tmpstr + tmpsiz - s, "Routing %s\n",
-			      the_lnet.ln_routing ? "enabled" : "disabled");
+		s += scnprintf(s, tmpstr + tmpsiz - s, "Routing %s\n",
+			       the_lnet.ln_routing ? "enabled" : "disabled");
 		LASSERT(tmpstr + tmpsiz - s > 0);
 
-		s += snprintf(s, tmpstr + tmpsiz - s, "%-8s %4s %8s %7s %s\n",
-			      "net", "hops", "priority", "state", "router");
+		s += scnprintf(s, tmpstr + tmpsiz - s, "%-8s %4s %8s %7s %s\n",
+			       "net", "hops", "priority", "state", "router");
 		LASSERT(tmpstr + tmpsiz - s > 0);
 
 		lnet_net_lock(0);
@@ -217,12 +217,12 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			unsigned int priority = route->lr_priority;
 			int alive = lnet_is_route_alive(route);
 
-			s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%-8s %4d %8u %7s %s\n",
-				      libcfs_net2str(net), hops,
-				      priority,
-				      alive ? "up" : "down",
-				      libcfs_nid2str(route->lr_nid));
+			s += scnprintf(s, tmpstr + tmpsiz - s,
+				       "%-8s %4d %8u %7s %s\n",
+				       libcfs_net2str(net), hops,
+				       priority,
+				       alive ? "up" : "down",
+				       libcfs_nid2str(route->lr_nid));
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
 
@@ -276,9 +276,9 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 	s = tmpstr; /* points to current position in tmpstr[] */
 
 	if (!*ppos) {
-		s += snprintf(s, tmpstr + tmpsiz - s,
-			      "%-4s %7s %5s %s\n",
-			      "ref", "rtr_ref", "alive", "router");
+		s += scnprintf(s, tmpstr + tmpsiz - s,
+			       "%-4s %7s %5s %s\n",
+			       "ref", "rtr_ref", "alive", "router");
 		LASSERT(tmpstr + tmpsiz - s > 0);
 
 		lnet_net_lock(0);
@@ -320,11 +320,11 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			int nrtrrefs = peer->lp_rtr_refcount;
 			int alive = lnet_is_gateway_alive(peer);
 
-			s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%-4d %7d %5s %s\n",
-				      nrefs, nrtrrefs,
-				      alive ? "up" : "down",
-				      libcfs_nid2str(nid));
+			s += scnprintf(s, tmpstr + tmpsiz - s,
+				       "%-4d %7d %5s %s\n",
+				       nrefs, nrtrrefs,
+				       alive ? "up" : "down",
+				       libcfs_nid2str(nid));
 		}
 
 		lnet_net_unlock(0);
@@ -411,10 +411,10 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 	s = tmpstr; /* points to current position in tmpstr[] */
 
 	if (!*ppos) {
-		s += snprintf(s, tmpstr + tmpsiz - s,
-			      "%-24s %4s %5s %5s %5s %5s %5s %5s %5s %s\n",
-			      "nid", "refs", "state", "last", "max",
-			      "rtr", "min", "tx", "min", "queue");
+		s += scnprintf(s, tmpstr + tmpsiz - s,
+			       "%-24s %4s %5s %5s %5s %5s %5s %5s %5s %s\n",
+			       "nid", "refs", "state", "last", "max",
+			       "rtr", "min", "tx", "min", "queue");
 		LASSERT(tmpstr + tmpsiz - s > 0);
 
 		hoff++;
@@ -498,11 +498,11 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 			lnet_net_unlock(cpt);
 
-			s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%-24s %4d %5s %5lld %5d %5d %5d %5d %5d %d\n",
-				      libcfs_nid2str(nid), nrefs, aliveness,
-				      lastalive, maxcr, rtrcr, minrtrcr, txcr,
-				      mintxcr, txqnob);
+			s += scnprintf(s, tmpstr + tmpsiz - s,
+				       "%-24s %4d %5s %5lld %5d %5d %5d %5d %5d %d\n",
+				       libcfs_nid2str(nid), nrefs, aliveness,
+				       lastalive, maxcr, rtrcr, minrtrcr, txcr,
+				       mintxcr, txqnob);
 			LASSERT(tmpstr + tmpsiz - s > 0);
 
 		} else { /* peer is NULL */
@@ -560,9 +560,9 @@ static int proc_lnet_buffers(struct ctl_table *table, int write,
 
 	s = tmpstr; /* points to current position in tmpstr[] */
 
-	s += snprintf(s, tmpstr + tmpsiz - s,
-		      "%5s %5s %7s %7s\n",
-		      "pages", "count", "credits", "min");
+	s += scnprintf(s, tmpstr + tmpsiz - s,
+		       "%5s %5s %7s %7s\n",
+		       "pages", "count", "credits", "min");
 	LASSERT(tmpstr + tmpsiz - s > 0);
 
 	if (!the_lnet.ln_rtrpools)
@@ -573,12 +573,12 @@ static int proc_lnet_buffers(struct ctl_table *table, int write,
 
 		lnet_net_lock(LNET_LOCK_EX);
 		cfs_percpt_for_each(rbp, i, the_lnet.ln_rtrpools) {
-			s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%5d %5d %7d %7d\n",
-				      rbp[idx].rbp_npages,
-				      rbp[idx].rbp_nbuffers,
-				      rbp[idx].rbp_credits,
-				      rbp[idx].rbp_mincredits);
+			s += scnprintf(s, tmpstr + tmpsiz - s,
+				       "%5d %5d %7d %7d\n",
+				       rbp[idx].rbp_npages,
+				       rbp[idx].rbp_nbuffers,
+				       rbp[idx].rbp_credits,
+				       rbp[idx].rbp_mincredits);
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
 		lnet_net_unlock(LNET_LOCK_EX);
@@ -652,10 +652,10 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 	s = tmpstr; /* points to current position in tmpstr[] */
 
 	if (!*ppos) {
-		s += snprintf(s, tmpstr + tmpsiz - s,
-			      "%-24s %6s %5s %4s %4s %4s %5s %5s %5s\n",
-			      "nid", "status", "alive", "refs", "peer",
-			      "rtr", "max", "tx", "min");
+		s += scnprintf(s, tmpstr + tmpsiz - s,
+			       "%-24s %6s %5s %4s %4s %4s %5s %5s %5s\n",
+			       "nid", "status", "alive", "refs", "peer",
+			       "rtr", "max", "tx", "min");
 		LASSERT(tmpstr + tmpsiz - s > 0);
 	} else {
 		struct lnet_ni *ni = NULL;
@@ -705,15 +705,15 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 				if (i)
 					lnet_net_lock(i);
 
-				s += snprintf(s, tmpstr + tmpsiz - s,
-					      "%-24s %6s %5lld %4d %4d %4d %5d %5d %5d\n",
-					      libcfs_nid2str(ni->ni_nid), stat,
-					      last_alive, *ni->ni_refs[i],
-					      ni->ni_net->net_tunables.lct_peer_tx_credits,
-					      ni->ni_net->net_tunables.lct_peer_rtr_credits,
-					      tq->tq_credits_max,
-					      tq->tq_credits,
-					      tq->tq_credits_min);
+				s += scnprintf(s, tmpstr + tmpsiz - s,
+					       "%-24s %6s %5lld %4d %4d %4d %5d %5d %5d\n",
+					       libcfs_nid2str(ni->ni_nid), stat,
+					       last_alive, *ni->ni_refs[i],
+					       ni->ni_net->net_tunables.lct_peer_tx_credits,
+					       ni->ni_net->net_tunables.lct_peer_rtr_credits,
+					       tq->tq_credits_max,
+					       tq->tq_credits,
+					       tq->tq_credits_min);
 				if (i)
 					lnet_net_unlock(i);
 			}
@@ -803,11 +803,11 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 		LASSERT(portal_rotors[i].pr_value == portal_rotor);
 		lnet_res_unlock(0);
 
-		rc = snprintf(buf, buf_len,
-			      "{\n\tportals: all\n"
-			      "\trotor: %s\n\tdescription: %s\n}",
-			      portal_rotors[i].pr_name,
-			      portal_rotors[i].pr_desc);
+		rc = scnprintf(buf, buf_len,
+			       "{\n\tportals: all\n"
+			       "\trotor: %s\n\tdescription: %s\n}",
+			       portal_rotors[i].pr_name,
+			       portal_rotors[i].pr_desc);
 
 		if (pos >= min_t(int, rc, buf_len)) {
 			rc = 0;
-- 
1.8.3.1
