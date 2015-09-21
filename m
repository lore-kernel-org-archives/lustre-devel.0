From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 21 Sep 2015 15:33:58 +0200
Subject: [lustre-devel] [PATCH 26/38] staging: lustre: remove invalid check
In-Reply-To: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Message-ID: <1442842450-29769-27-git-send-email-a.hajda@samsung.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Unsigned cannot be negative.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index c504d15..f3eb39f 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -451,9 +451,6 @@ static ssize_t resend_count_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	if (val < 0)
-	       return -EINVAL;
-
 	atomic_set(&obd->u.cli.cl_resends, val);
 
 	return count;
-- 
1.9.1
