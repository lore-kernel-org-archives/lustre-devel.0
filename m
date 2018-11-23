From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Nov 2018 18:15:27 +1100
Subject: [lustre-devel] [PATCH 3/9] lustre: ptlrpc: use smp unsafe at_init
 only for initialization
In-Reply-To: <154295730810.2850.961218355189474016.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
Message-ID: <154295732794.2850.5519811101627910956.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <vladimir.saveliev@seagate.com>

at_init() is not smp safe, so it is not supposed to be used anywhere
but in at initialization.
Add at_reinit() - safe version of at_init().

Signed-off-by: Vladimir Saveliev <vladimir.saveliev@seagate.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-6805
Reviewed-on: http://review.whamcloud.com/15522
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_import.h  |   19 +++++++++++++++++--
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 +-
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index a629f6bba814..8a8a125bd130 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -331,12 +331,17 @@ static inline unsigned int at_timeout2est(unsigned int val)
 	return (max((val << 2) / 5, 5U) - 4);
 }
 
-static inline void at_reset(struct adaptive_timeout *at, int val)
+static inline void at_reset_nolock(struct adaptive_timeout *at, int val)
 {
-	spin_lock(&at->at_lock);
 	at->at_current = val;
 	at->at_worst_ever = val;
 	at->at_worst_time = ktime_get_real_seconds();
+}
+
+static inline void at_reset(struct adaptive_timeout *at, int val)
+{
+	spin_lock(&at->at_lock);
+	at_reset_nolock(at, val);
 	spin_unlock(&at->at_lock);
 }
 
@@ -348,6 +353,16 @@ static inline void at_init(struct adaptive_timeout *at, int val, int flags)
 	at_reset(at, val);
 }
 
+static inline void at_reinit(struct adaptive_timeout *at, int val, int flags)
+{
+	spin_lock(&at->at_lock);
+	at->at_binstart = 0;
+	memset(at->at_hist, 0, sizeof(at->at_hist));
+	at->at_flags = flags;
+	at_reset_nolock(at, val);
+	spin_unlock(&at->at_lock);
+}
+
 extern unsigned int at_min;
 static inline int at_get(struct adaptive_timeout *at)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 07dc87d9513e..480c860d066e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1036,7 +1036,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	 * The net statistics after (re-)connect is not valid anymore,
 	 * because may reflect other routing, etc.
 	 */
-	at_init(&imp->imp_at.iat_net_latency, 0, 0);
+	at_reinit(&imp->imp_at.iat_net_latency, 0, 0);
 	ptlrpc_at_adj_net_latency(request,
 				  lustre_msg_get_service_time(request->rq_repmsg));
 
