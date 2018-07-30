From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:41 +1000
Subject: [lustre-devel] [PATCH 22/22] lustre: sec_config: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186151.13840.8095964948258952076.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These loops are removing all elements from a list.
So using while(!list_empty()) makes the intent clearer.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 2389f9a8f534..1844ada6780f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -839,12 +839,13 @@ int sptlrpc_conf_init(void)
 
 void sptlrpc_conf_fini(void)
 {
-	struct sptlrpc_conf *conf, *conf_next;
+	struct sptlrpc_conf *conf;
 
 	mutex_lock(&sptlrpc_conf_lock);
-	list_for_each_entry_safe(conf, conf_next, &sptlrpc_confs, sc_list) {
+	while (!list_empty(&sptlrpc_confs)) {
+		conf = list_first_entry(&sptlrpc_confs,
+					struct sptlrpc_conf, sc_list);
 		sptlrpc_conf_free(conf);
 	}
-	LASSERT(list_empty(&sptlrpc_confs));
 	mutex_unlock(&sptlrpc_conf_lock);
 }
