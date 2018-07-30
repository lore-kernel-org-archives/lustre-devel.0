From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:41 +1000
Subject: [lustre-devel] [PATCH 12/22] Revert "staging: lustre: obdclass: Use
 list_for_each_entry_safe"
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186108.13840.4929208218603720715.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts commit 6069f756d42160e454f49286183712514db3ca6b.

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index e286a2665423..7fc62b7e95b4 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -146,7 +146,6 @@ int class_del_uuid(const char *uuid)
 {
 	LIST_HEAD(deathrow);
 	struct uuid_nid_data *data;
-	struct uuid_nid_data *temp;
 
 	spin_lock(&g_uuid_lock);
 	if (uuid) {
@@ -169,7 +168,9 @@ int class_del_uuid(const char *uuid)
 		return -EINVAL;
 	}
 
-	list_for_each_entry_safe(data, temp, &deathrow, un_list) {
+	while (!list_empty(&deathrow)) {
+		data = list_entry(deathrow.next, struct uuid_nid_data,
+				  un_list);
 		list_del(&data->un_list);
 
 		CDEBUG(D_INFO, "del uuid %s %s/%d\n",
