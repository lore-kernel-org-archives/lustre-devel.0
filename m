From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 05/34] lnet: make lnet_nid_cpt_hash
 non-static.
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763504.32103.13261120162709788445.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Future patch will need this.

This is part of
    Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
from upstream lustre, where it is marked:
    Signed-off-by: Amir Shehata <amir.shehata@intel.com>
    WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
    Reviewed-on: http://review.whamcloud.com/18293
    Reviewed-by: Olaf Weber <olaf@sgi.com>
    Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index a1c581069eb1..f925e3cd64ca 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -395,6 +395,7 @@ lnet_net2rnethash(__u32 net)
 extern struct lnet_lnd the_lolnd;
 extern int avoid_asym_router_failure;
 
+unsigned int lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number);
 int lnet_cpt_of_nid_locked(lnet_nid_t nid, struct lnet_ni *ni);
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 1b47cbd6fd68..20fa3fea04b9 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -693,7 +693,7 @@ lnet_get_net_locked(__u32 net_id)
 	return NULL;
 }
 
-static unsigned int
+unsigned int
 lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
 	__u64 key = nid;
