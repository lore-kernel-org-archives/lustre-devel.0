From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: simplfy
 lov_finish_set()
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956733.22133.5869125353037664313.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

When deleting everything from a list, a while loop
is cleaner than list_for_each_safe().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/lov/lov_request.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 9d3b3f3e9f10..54f883e359ce 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -48,15 +48,13 @@ static void lov_init_set(struct lov_request_set *set)
 
 static void lov_finish_set(struct lov_request_set *set)
 {
-	struct list_head *pos, *n;
+	struct lov_request *req;
 
 	LASSERT(set);
-	list_for_each_safe(pos, n, &set->set_list) {
-		struct lov_request *req = list_entry(pos,
-							 struct lov_request,
-							 rq_link);
+	while ((req = list_first_entry_or_null(&set->set_list,
+					       struct lov_request,
+					       rq_link)) != NULL) {
 		list_del_init(&req->rq_link);
-
 		kfree(req->rq_oi.oi_osfs);
 		kfree(req);
 	}
