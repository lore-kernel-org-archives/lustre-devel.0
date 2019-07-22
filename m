From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:18 -0400
Subject: [lustre-devel] [PATCH 06/10] lnet: socklnd: fix infinite loop in
 ksocknal_push()
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

If the list_for_each_entry() loop in ksocknal_push()
ever finds a match, then it will increment 'i', and the outer
loop will continue.

Once peer_off becomes larger than the number of matches
in a given chain, 'peer_ni' will be an invalid pointer, and
ksocknal_push_peer() will probably crash when called on it.

To abort the outer loop properly, we need to test if
"i <= peer_off", which indicates that all patching peers
have been found.

This bug can easily be reproduced by running
  lctl --net tcp push

Signed-off-by: NeilBrown <neilb@suse.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-12101
Reviewed-on: https://review.whamcloud.com/34499
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 08feaf7..a422481 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1952,7 +1952,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			}
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 
-			if (!i) /* no match */
+			if (i <= peer_off) /* no match */
 				break;
 
 			rc = 0;
-- 
1.8.3.1
