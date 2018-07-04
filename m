From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 01/11] lustre: use DIV_ROUND_UP() where
 appropriate.
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943057.30111.7389117779247056126.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There places have code of the form
   ( x + y - 1 ) / y

replace all of these with DIV_ROUND_UP(x, y) to improve readability.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    3 +--
 drivers/staging/lustre/lnet/selftest/selftest.h    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    3 +--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 7d8429672616..41990020832a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -127,8 +127,7 @@ extern struct kib_tunables  kiblnd_tunables;
 #define IBLND_RX_MSGS(c)	\
 	((c->ibc_queue_depth) * 2 + IBLND_OOB_MSGS(c->ibc_version))
 #define IBLND_RX_MSG_BYTES(c)	(IBLND_RX_MSGS(c) * IBLND_MSG_SIZE)
-#define IBLND_RX_MSG_PAGES(c)	\
-	((IBLND_RX_MSG_BYTES(c) + PAGE_SIZE - 1) / PAGE_SIZE)
+#define IBLND_RX_MSG_PAGES(c)	DIV_ROUND_UP(IBLND_RX_MSG_BYTES(c), PAGE_SIZE)
 
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 8737fa96b192..6690e8ec5155 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -397,7 +397,7 @@ struct sfw_test_instance {
 #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
 #define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(struct lnet_process_id_packed))
 #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
-#define sfw_id_pages(n)    (((n) + SFW_ID_PER_PAGE - 1) / SFW_ID_PER_PAGE)
+#define sfw_id_pages(n)    DIV_ROUND_UP(n, SFW_ID_PER_PAGE)
 
 struct sfw_test_unit {
 	struct list_head    tsu_list;	   /* chain on lst_test_instance */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 2d05387d1b0d..21497eac5c81 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -712,8 +712,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 			 * take extent tax into account when asking for more
 			 * grant space
 			 */
-			nrextents = (nrpages + cli->cl_max_extent_pages - 1)  /
-				     cli->cl_max_extent_pages;
+			nrextents = DIV_ROUND_UP(nrpages, cli->cl_max_extent_pages);
 			oa->o_undirty += nrextents * cli->cl_grant_extent_tax;
 		}
 	}
