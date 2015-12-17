From: Shraddha <shraddha.6596@gmail.com>
Date: Fri, 18 Dec 2015 02:40:28 +0530
Subject: [lustre-devel] [PATCH 3/5] Staging: lustre: osc: Declare as static
In-Reply-To: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
References: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450386630-5662-4-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

Declare osc_extent_find and osc_unreserve_grant as static since they
are used only in this particular file.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b1d1a87f..3f5a2a7d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -619,9 +619,9 @@ static inline int overlapped(struct osc_extent *ex1, struct osc_extent *ex2)
  * Find or create an extent which includes @index, core function to manage
  * extent tree.
  */
-struct osc_extent *osc_extent_find(const struct lu_env *env,
-				   struct osc_object *obj, pgoff_t index,
-				   int *grants)
+static struct osc_extent *osc_extent_find(const struct lu_env *env,
+					  struct osc_object *obj, pgoff_t index,
+					  int *grants)
 
 {
 	struct client_obd *cli = osc_cli(obj);
@@ -1420,8 +1420,8 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 	}
 }
 
-void osc_unreserve_grant(struct client_obd *cli,
-			 unsigned int reserved, unsigned int unused)
+static void osc_unreserve_grant(struct client_obd *cli,
+				unsigned int reserved, unsigned int unused)
 {
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	__osc_unreserve_grant(cli, reserved, unused);
-- 
2.1.4
