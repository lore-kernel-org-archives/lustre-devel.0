From: Andrew Kanner <andrew.kanner@gmail.com>
Date: Thu, 03 Nov 2016 21:57:24 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: fixed shadowed variable in
	socklnd_cb.c
Message-ID: <1478210059-6091-1-git-send-email-andrew.kanner@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com
Cc: andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, bevans@cray.com, bhaktipriya96@gmail.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Changed variable 'tx' name in local scope
Fixed: sparse warning:
socklnd_cb.c:2476:41: warning: symbol 'tx' shadows an earlier one
socklnd_cb.c:2435:25: originally declared here

Signed-off-by: Andrew Kanner <andrew.kanner@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index c1c6f60..03fe4e5 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -2473,11 +2473,11 @@ ksocknal_check_peer_timeouts(int idx)
 		 * holding only shared lock
 		 */
 		if (!list_empty(&peer->ksnp_tx_queue)) {
-			struct ksock_tx *tx = list_entry(peer->ksnp_tx_queue.next,
+			struct ksock_tx *_tx = list_entry(peer->ksnp_tx_queue.next,
 						    struct ksock_tx, tx_list);
 
 			if (cfs_time_aftereq(cfs_time_current(),
-					     tx->tx_deadline)) {
+					     _tx->tx_deadline)) {
 				ksocknal_peer_addref(peer);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
 
-- 
2.1.4
