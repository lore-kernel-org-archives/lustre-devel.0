From: Guillermo O. Freschi <kedrot@gmail.com>
Date: Mon, 26 Dec 2016 15:44:03 -0000
Subject: [lustre-devel] [PATCH 1/2] Fixed signedness check
Message-ID: <20161226154339.8916-1-kedrot@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org
Cc: "Guillermo O. Freschi" <kedrot@gmail.com>

Was `unsigned int`, but `enum`s are signed.

Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index a4a291acb659..f4cbc89b4f24 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1148,7 +1148,7 @@ static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
 	return INTERVAL_ITER_STOP;
 }
 
-static unsigned int itree_overlap_cb(struct interval_node *in, void *args)
+static enum interval_iter itree_overlap_cb(struct interval_node *in, void *args)
 {
 	struct ldlm_interval *node = to_ldlm_interval(in);
 	struct lock_match_data *data = args;
-- 
2.11.0
