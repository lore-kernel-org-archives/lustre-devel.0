From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:49 -0400
Subject: [lustre-devel] [PATCH 13/32] staging: lustre: obd: rename
	lsr_padding to lsr_valid
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Simple variable rename.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4345
Reviewed-on: http://review.whamcloud.com/10223
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    1 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    8 ++++----
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 87eef4c..bbf0c8d 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3036,7 +3036,7 @@ struct llog_setattr64_rec {
 	__u32			lsr_uid_h;
 	__u32			lsr_gid;
 	__u32			lsr_gid_h;
-	__u64			lsr_padding;
+	__u64			lsr_valid;
 	struct llog_rec_tail    lsr_tail;
 } __packed;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index f7b9b19..0ec6361 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -224,6 +224,7 @@ void lustre_swab_llog_rec(struct llog_rec_hdr *rec)
 		__swab32s(&lsr->lsr_uid_h);
 		__swab32s(&lsr->lsr_gid);
 		__swab32s(&lsr->lsr_gid_h);
+		__swab64s(&lsr->lsr_valid);
 		tail = &lsr->lsr_tail;
 		break;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 9d5d2c8..8dbaf32 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -3170,10 +3170,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_gid_h));
 	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_gid_h) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_gid_h));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_padding) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_padding));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_padding) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_padding));
+	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_valid) == 48, "found %lld\n",
+		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_valid));
+	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_valid) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_valid));
 	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_tail) == 56, "found %lld\n",
 		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_tail));
 	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_tail) == 8, "found %lld\n",
-- 
1.7.1
