From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:25 -0500
Subject: [lustre-devel] [PATCH 517/622] lnet: net_fault: don't pass struct
 member to do_div()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-518-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

do_div() changes it's first argument, so passing a struct member
is not a good idea unless we really want the struct to change,
which we don't in these cases.
So copy the value to a local variable and call do_div() on
that.

Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradaed.org>
---
 net/lnet/lnet/net_fault.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 9f78e43..e43b1e1 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -394,9 +394,11 @@ struct lnet_drop_rule {
 		}
 
 	} else { /* rate based drop */
-		drop = rule->dr_stat.fs_count++ == rule->dr_drop_at;
+		u64 count;
 
-		if (!do_div(rule->dr_stat.fs_count, attr->u.drop.da_rate)) {
+		drop = rule->dr_stat.fs_count++ == rule->dr_drop_at;
+		count = rule->dr_stat.fs_count;
+		if (!do_div(count, attr->u.drop.da_rate)) {
 			rule->dr_drop_at = rule->dr_stat.fs_count +
 				prandom_u32_max(attr->u.drop.da_rate);
 			CDEBUG(D_NET, "Drop Rule %s->%s: next drop: %lu\n",
@@ -563,9 +565,12 @@ struct delay_daemon_data {
 		}
 
 	} else { /* rate based delay */
+		u64 count;
+
 		delay = rule->dl_stat.fs_count++ == rule->dl_delay_at;
+		count = rule->dl_stat.fs_count;
 		/* generate the next random rate sequence */
-		if (!do_div(rule->dl_stat.fs_count, attr->u.delay.la_rate)) {
+		if (!do_div(count, attr->u.delay.la_rate)) {
 			rule->dl_delay_at = rule->dl_stat.fs_count +
 				prandom_u32_max(attr->u.delay.la_rate);
 			CDEBUG(D_NET, "Delay Rule %s->%s: next delay: %lu\n",
-- 
1.8.3.1
