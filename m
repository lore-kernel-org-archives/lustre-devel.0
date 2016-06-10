From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:13 -0400
Subject: [lustre-devel] [PATCH 3/8] staging/lustre/ldlm: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/ldlm directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c   | 3 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 8 +++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b4ffbe2..b6a90b0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -345,7 +345,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 * Set cl_chksum* to CRC32 for now to avoid returning screwed info
 	 * through procfs.
 	 */
-	cli->cl_cksum_type = cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
+	cli->cl_cksum_type = OBD_CKSUM_CRC32;
+	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
 	atomic_set(&cli->cl_resends, OSC_DEFAULT_RESENDS);
 
 	/* This value may be reduced at connect time in
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ab739f0..3303ffa 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1011,9 +1011,11 @@ static int ldlm_setup(void)
 		blp->blp_min_threads = LDLM_NTHRS_INIT;
 		blp->blp_max_threads = LDLM_NTHRS_MAX;
 	} else {
-		blp->blp_min_threads = blp->blp_max_threads =
-			min_t(int, LDLM_NTHRS_MAX, max_t(int, LDLM_NTHRS_INIT,
-							 ldlm_num_threads));
+		blp->blp_min_threads = min_t(int, LDLM_NTHRS_MAX,
+					     max_t(int, LDLM_NTHRS_INIT,
+						   ldlm_num_threads));
+
+		blp->blp_max_threads = blp->blp_min_threads;
 	}
 
 	for (i = 0; i < blp->blp_min_threads; i++) {
-- 
2.7.4
