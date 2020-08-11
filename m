From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:15 -0400
Subject: [lustre-devel] [PATCH 19/23] lnet: Allow duplicate nets in ip2nets
 syntax
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Before the MR feature was implemented, it was not possible to
configure multiple interfaces on the same LNet, so the ip2nets
syntax did not allow for this. Now that we have MR feature, we should
allow it to be configured via ip2nets syntax. e.g.

o2ib(ib0) 10.10.10.1
o2ib(ib1) 10.10.10.2

A test is added for configuring LNet with kernel ip2nets parameter.

setup_netns() refactored to facilitate the new test.

cleanup_lnet() is modified to check whether lnet module is loaded
before attempting lnetctl lnet unconfigured otherwise sanity-lnet.sh
could exit with rc 234 on cleanup.

HPE-bug-id: LUS-9046
WC-bug-id: https://jira.whamcloud.com/browse/LU-13734
Lustre-commit: 6203ed821ffac ("LU-13734 lnet: Allow duplicate nets in ip2nets syntax")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39227
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/config.c | 36 ++++--------------------------------
 1 file changed, 4 insertions(+), 32 deletions(-)

diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 9f36c82..6ddd9d6 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -349,10 +349,10 @@ struct lnet_net *
 {
 	struct lnet_net *net;
 
-	if (!lnet_net_unique(net_id, net_list, NULL)) {
-		CERROR("Duplicate net %s. Ignore\n",
-		       libcfs_net2str(net_id));
-		return NULL;
+	if (!lnet_net_unique(net_id, net_list, &net)) {
+		CDEBUG(D_NET, "Returning duplicate net %p %s\n", net,
+		       libcfs_net2str(net->net_id));
+		return net;
 	}
 
 	net = kzalloc(sizeof(*net), GFP_NOFS);
@@ -1450,12 +1450,8 @@ struct lnet_ni *
 	struct list_head *t;
 	struct list_head *t2;
 	struct lnet_text_buf *tb;
-	struct lnet_text_buf *tb2;
-	u32 net1;
-	u32 net2;
 	int len;
 	int count;
-	int dup;
 	int rc;
 
 	if (lnet_str2tbs_sep(&raw_entries, ip2nets) < 0) {
@@ -1494,30 +1490,6 @@ struct lnet_ni *
 		if (rc < 0)
 			break;
 
-		dup = 0;
-		list_for_each_entry(tb, &current_nets, ltb_list) {
-			net1 = lnet_netspec2net(tb->ltb_text);
-			LASSERT(net1 != LNET_NIDNET(LNET_NID_ANY));
-
-			list_for_each_entry(tb2, &matched_nets, ltb_list) {
-				net2 = lnet_netspec2net(tb2->ltb_text);
-				LASSERT(net2 != LNET_NIDNET(LNET_NID_ANY));
-
-				if (net1 == net2) {
-					dup = 1;
-					break;
-				}
-			}
-
-			if (dup)
-				break;
-		}
-
-		if (dup) {
-			lnet_free_text_bufs(&current_nets);
-			continue;
-		}
-
 		list_for_each_safe(t, t2, &current_nets) {
 			tb = list_entry(t, struct lnet_text_buf, ltb_list);
 
-- 
1.8.3.1
