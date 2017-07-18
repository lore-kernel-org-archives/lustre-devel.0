From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 08/12] staging: lustre: ldlm: remove unused
 'overlaps' variable
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040758.20736.9079474817471825999.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

'overlaps' is never used, only incremented.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index b6d5a83e61cd..0fb2c882ab4a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -133,7 +133,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	struct ldlm_lock *new2 = NULL;
 	enum ldlm_mode mode = req->l_req_mode;
 	int added = (mode == LCK_NL);
-	int overlaps = 0;
 	int splitted = 0;
 	const struct ldlm_callback_suite null_cbs = { };
 
@@ -226,8 +225,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 		    lock->l_policy_data.l_flock.start)
 			break;
 
-		++overlaps;
-
 		if (new->l_policy_data.l_flock.start <=
 		    lock->l_policy_data.l_flock.start) {
 			if (new->l_policy_data.l_flock.end <
