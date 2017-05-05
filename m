From: Valentin Vidic <Valentin.Vidic@CARNet.hr>
Date: Fri,  5 May 2017 07:27:41 +0200
Subject: [lustre-devel] [PATCH v2] staging: lustre: cleanup le32 assignment
	to ldp_flags
In-Reply-To: <20170429154900.25819-1-Valentin.Vidic@CARNet.hr>
References: <20170429154900.25819-1-Valentin.Vidic@CARNet.hr>
Message-ID: <20170505052741.5713-1-Valentin.Vidic@CARNet.hr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: Valentin Vidic <Valentin.Vidic@CARNet.hr>

Introduces a local var to collect flags and convert
them to le32.

Fixes the following sparse warnings:

drivers/staging/lustre/lustre/lmv/lmv_obd.c:2305:23: warning: invalid assignment: |=
drivers/staging/lustre/lustre/lmv/lmv_obd.c:2305:23:    left side has type restricted __le32
drivers/staging/lustre/lustre/lmv/lmv_obd.c:2305:23:    right side has type int
drivers/staging/lustre/lustre/lmv/lmv_obd.c:2383:39: warning: invalid assignment: |=
drivers/staging/lustre/lustre/lmv/lmv_obd.c:2383:39:    left side has type restricted __le32
drivers/staging/lustre/lustre/lmv/lmv_obd.c:2383:39:    right side has type int

Signed-off-by: Valentin Vidic <Valentin.Vidic@CARNet.hr>
---
Changes in v2: use a local var to collect flags

 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 09b469243d73..bec8c1948fa0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2275,6 +2275,7 @@ static int lmv_read_striped_page(struct obd_export *exp,
 	struct lu_fid master_fid = op_data->op_fid1;
 	struct obd_device *obd = exp->exp_obd;
 	__u64 hash_offset = offset;
+	__u32 ldp_flags;
 	struct page *min_ent_page = NULL;
 	struct page *ent_page = NULL;
 	struct lu_dirent *min_ent = NULL;
@@ -2302,7 +2303,7 @@ static int lmv_read_striped_page(struct obd_export *exp,
 	dp = kmap(ent_page);
 	memset(dp, 0, sizeof(*dp));
 	dp->ldp_hash_start = cpu_to_le64(offset);
-	dp->ldp_flags |= LDF_COLLIDE;
+	ldp_flags = LDF_COLLIDE;
 
 	area = dp + 1;
 	left_bytes = PAGE_SIZE - sizeof(*dp);
@@ -2380,8 +2381,8 @@ static int lmv_read_striped_page(struct obd_export *exp,
 		ent_page = NULL;
 	} else {
 		if (ent == area)
-			dp->ldp_flags |= LDF_EMPTY;
-		dp->ldp_flags = cpu_to_le32(dp->ldp_flags);
+			ldp_flags |= LDF_EMPTY;
+		dp->ldp_flags |= cpu_to_le32(ldp_flags);
 		dp->ldp_hash_end = cpu_to_le64(hash_offset);
 	}
 
-- 
2.11.0
