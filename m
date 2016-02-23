From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:16 -0500
Subject: [lustre-devel] [PATCH 38/56] staging/lustre: Remove dead code in
	ldlm_lock_destroy_internal
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-39-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This code has been commented out since end of 2012, so it's
clearly not needed here.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 07e83e5..65d0cfe 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -337,16 +337,6 @@ static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 	ldlm_lock_remove_from_lru(lock);
 	class_handle_unhash(&lock->l_handle);
 
-#if 0
-	/* Wake anyone waiting for this lock */
-	/* FIXME: I should probably add yet another flag, instead of using
-	 * l_export to only call this on clients */
-	if (lock->l_export)
-		class_export_put(lock->l_export);
-	lock->l_export = NULL;
-	if (lock->l_export && lock->l_completion_ast)
-		lock->l_completion_ast(lock, 0);
-#endif
 	return 1;
 }
 
-- 
2.1.0
