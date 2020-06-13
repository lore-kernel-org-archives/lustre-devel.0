From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:13 -0400
Subject: [lustre-devel] [PATCH 17/20] lnet: fix uninitialize var in
 choose_ipv4_src()
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

choose_ip4_src() test "*ret" without initializing it - and callers do
not (and should not) initialize the var.

Instead of testing "*ret", test "err" - if this is non-zero (it will
be -ENOENT) we want to use the address.  If it is zero, then we only
use the address if it is on the right subnet.

Reported-by: Amir Shehata <ashehata@whamcloud.com>
Fixes: 382731148e24 ("lnet: socklnd: use interface index to track local addr")
WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 8ea895389a92d ("LU-10391 lnet: fix uninitialize var in choose_ipv4_src()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38823
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index a4db830..e082b52 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -158,7 +158,7 @@ int choose_ipv4_src(__u32 *ret, int interface, __u32 dst_ipaddr, struct net *ns)
 		goto out;
 	err = -ENOENT;
 	in_dev_for_each_ifa_rcu(ifa, in_dev) {
-		if (*ret == 0 ||
+		if (err == 0 ||
 		    ((dst_ipaddr ^ ntohl(ifa->ifa_local)) &
 		     ntohl(ifa->ifa_mask)) == 0) {
 			/* This address at least as good as what we
-- 
1.8.3.1
