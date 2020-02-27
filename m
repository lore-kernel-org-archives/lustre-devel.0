From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:13 -0500
Subject: [lustre-devel] [PATCH 025/622] lnet: fix nid range format '*@<net>'
 support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

In cfs_ip_min_max(), (nidrange->nr_all == 1) means this nid range
is a full IP address range(*.*.*.*). In this case, we don't need
to compare it to any other nid range, but set min_nid to 0.0.0.0
and max_nid to 255.255.255.255 directly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8913
Lustre-commit: 230266326f49 ("LU-8913 nodemap: fix nodemap range format '*@<net>' support")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31684
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/nidstrings.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index b4e38e5..13338d0 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -680,6 +680,12 @@ static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 		if (nidlist_count > 0)
 			return -EINVAL;
 
+		if (nr->nr_all) {
+			min_ip_addr = 0;
+			max_ip_addr = 0xffffffff;
+			break;
+		}
+
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
 			rc = cfs_ip_ar_min_max(ar, &tmp_min_ip_addr,
 					       &tmp_max_ip_addr);
-- 
1.8.3.1
