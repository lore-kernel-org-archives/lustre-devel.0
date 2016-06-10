From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:15 -0400
Subject: [lustre-devel] [PATCH 5/8] staging/lustre/lov: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/lov directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index e15ef2e..c179b31 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1772,7 +1772,8 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 	fm_start = fiemap->fm_start;
 	fm_length = fiemap->fm_length;
 	/* Calculate start stripe, last stripe and length of mapping */
-	actual_start_stripe = start_stripe = lov_stripe_number(lsm, fm_start);
+	start_stripe = lov_stripe_number(lsm, fm_start);
+	actual_start_stripe = start_stripe;
 	fm_end = (fm_length == ~0ULL ? fm_key->oa.o_size :
 						fm_start + fm_length - 1);
 	/* If fm_length != ~0ULL but fm_start+fm_length-1 exceeds file size */
@@ -2095,11 +2096,9 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	u32 count;
 	int i, rc = 0, err;
 	struct lov_tgt_desc *tgt;
-	unsigned incr, check_uuid,
-		 do_inactive, no_set;
-	unsigned next_id = 0,  mds_con = 0;
+	unsigned int incr = 0, check_uuid = 0, do_inactive = 0, no_set = 0;
+	unsigned int next_id = 0, mds_con = 0;
 
-	incr = check_uuid = do_inactive = no_set = 0;
 	if (!set) {
 		no_set = 1;
 		set = ptlrpc_prep_set();
-- 
2.7.4
