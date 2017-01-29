From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:14 -0500
Subject: [lustre-devel] [PATCH 46/60] staging: lustre: mdc: Make IT_OPEN
	take lookup bits lock
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-47-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>, James Simmons <jsimmons@infradead.org>

From: Patrick Farrell <paf@cray.com>

An earlier commit accidentally changed handling of IT_OPEN,
making it take the MDS_INODELOCK_UPDATE bits lock instead of
MDS_INODELOCK_LOOKUP. This does not cause any known bugs.

Signed-off-by: Patrick Farrell <paf@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8842
Reviewed-on: https://review.whamcloud.com/23797
Fixes: 70a251f68dea ("staging: lustre: obd: decruft md_enqueue() and md_intent_lock()"
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 156add7..91a7243 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -721,7 +721,7 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		LASSERT(!policy);
 
 		saved_flags |= LDLM_FL_HAS_INTENT;
-		if (it->it_op & (IT_OPEN | IT_UNLINK | IT_GETATTR | IT_READDIR))
+		if (it->it_op & (IT_UNLINK | IT_GETATTR | IT_READDIR))
 			policy = &update_policy;
 		else if (it->it_op & IT_LAYOUT)
 			policy = &layout_policy;
-- 
1.8.3.1
