From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:45:39 +1000
Subject: [lustre-devel] [PATCH 5/6] lustre: convert list_for_each() in
 ksocknal_push_peer()
In-Reply-To: <153292233170.26104.16164388413209501300.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
Message-ID: <153292233968.26104.1980002621622141877.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The use of list_for_each() in ksocknal_push_peer() cannot be trivially
converted to list_for_each_entry() as the new loop variable
is tested outside the loop.  We can change that test to compare 'i'
to 'index' instead.  Then a trivial conversion is possible.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index ea95bff79996..33335713b371 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1853,7 +1853,6 @@ ksocknal_push_peer(struct ksock_peer *peer)
 {
 	int index;
 	int i;
-	struct list_head *tmp;
 	struct ksock_conn *conn;
 
 	for (index = 0; ; index++) {
@@ -1862,10 +1861,8 @@ ksocknal_push_peer(struct ksock_peer *peer)
 		i = 0;
 		conn = NULL;
 
-		list_for_each(tmp, &peer->ksnp_conns) {
+		list_for_each_entry(conn, &peer->ksnp_conns, ksnc_list) {
 			if (i++ == index) {
-				conn = list_entry(tmp, struct ksock_conn,
-						  ksnc_list);
 				ksocknal_conn_addref(conn);
 				break;
 			}
@@ -1873,7 +1870,7 @@ ksocknal_push_peer(struct ksock_peer *peer)
 
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 
-		if (!conn)
+		if (i <= index)
 			break;
 
 		ksocknal_lib_push_conn(conn);
