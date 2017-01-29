From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:56 -0500
Subject: [lustre-devel] [PATCH 28/60] staging: lustre: ldlm:
	ASSERTION(flock->blocking_export!=0) failed
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <andriy.skulysh@seagate.com>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Andriy Skulysh <andriy.skulysh@seagate.com>

Whole policy structure was zeroed twice. Once during enqueue
and second time during resend or replay. Policy structure
should be initialized with default values only in ldlm_lock_new().

Signed-off-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8349
Seagate-bug-id: MRP-2536, MRP-2909
Reviewed-on: http://review.whamcloud.com/21061
Reviewed-by: Alexander Boyko <alexander.boyko@seagate.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c    | 1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c     | 1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c | 1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 32b73ee..5616ea4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -243,7 +243,6 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				      union ldlm_policy_data *lpolicy)
 {
-	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_extent.start = wpolicy->l_extent.start;
 	lpolicy->l_extent.end = wpolicy->l_extent.end;
 	lpolicy->l_extent.gid = wpolicy->l_extent.gid;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index f815827..b7f28b3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -615,7 +615,6 @@ struct ldlm_flock_wait_data {
 void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
-	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_flock.start = wpolicy->l_flock.lfw_start;
 	lpolicy->l_flock.end = wpolicy->l_flock.lfw_end;
 	lpolicy->l_flock.pid = wpolicy->l_flock.lfw_pid;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
index 8e1709d..ae37c36 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
@@ -57,7 +57,6 @@
 void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
-	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
 }
 
-- 
1.8.3.1
