From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:19 -0400
Subject: [lustre-devel] [PATCH 23/23] lnet: socklnd: NID to interface
 mapping issues
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Fix the NID to interface mapping in ksocknal_startup to make sure
the messages go out the interface assigned by LNet on a system
with multiple interfaces configured.

Fixes: 3aa523159321 ("lnet: consoldate secondary IP address handling")

WC-bug-id: https://jira.whamcloud.com/browse/LU-13790
Lustre-commit: 00f672da3ba9a ("LU-13790 socklnd: NID to interface mapping issues")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39408
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 91925475..a7c0b65 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2694,7 +2694,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 					   ni->ni_interfaces[i]) != 0)
 					continue;
 
-				ksi = &net->ksnn_interfaces[j];
+				ksi = &net->ksnn_interfaces[net->ksnn_ninterfaces];
 				ni->ni_dev_cpt = ifaces[j].li_cpt;
 				ksi->ksni_ipaddr = ifaces[j].li_ipaddr;
 				ksi->ksni_index =
-- 
1.8.3.1
