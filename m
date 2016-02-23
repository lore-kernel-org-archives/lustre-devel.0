From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:10 -0500
Subject: [lustre-devel] [PATCH 32/56] staging/lustre: Remove lquota_glb_rec,
	lquota_slv_rec and lquota_acct_rec
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-33-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These server-only structures and some supporting defines are unused
on the client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 52 ----------------------
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 44 ------------------
 2 files changed, 96 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 607bfde..b5f8453 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1819,58 +1819,6 @@ do {					\
 	Q_COPY(out, in, qc_dqblk);	\
 } while (0)
 
-/* Quota types currently supported */
-enum {
-	LQUOTA_TYPE_USR	= 0x00, /* maps to USRQUOTA */
-	LQUOTA_TYPE_GRP	= 0x01, /* maps to GRPQUOTA */
-	LQUOTA_TYPE_MAX
-};
-
-/* There are 2 different resource types on which a quota limit can be enforced:
- * - inodes on the MDTs
- * - blocks on the OSTs */
-enum {
-	LQUOTA_RES_MD		= 0x01, /* skip 0 to avoid null oid in FID */
-	LQUOTA_RES_DT		= 0x02,
-	LQUOTA_LAST_RES,
-	LQUOTA_FIRST_RES	= LQUOTA_RES_MD
-};
-
-#define LQUOTA_NR_RES (LQUOTA_LAST_RES - LQUOTA_FIRST_RES + 1)
-
-/*
- * Space accounting support
- * Format of an accounting record, providing disk usage information for a given
- * user or group
- */
-struct lquota_acct_rec { /* 16 bytes */
-	__u64 bspace;  /* current space in use */
-	__u64 ispace;  /* current # inodes in use */
-};
-
-/*
- * Global quota index support
- * Format of a global record, providing global quota settings for a given quota
- * identifier
- */
-struct lquota_glb_rec { /* 32 bytes */
-	__u64 qbr_hardlimit; /* quota hard limit, in #inodes or kbytes */
-	__u64 qbr_softlimit; /* quota soft limit, in #inodes or kbytes */
-	__u64 qbr_time;      /* grace time, in seconds */
-	__u64 qbr_granted;   /* how much is granted to slaves, in #inodes or
-			      * kbytes */
-};
-
-/*
- * Slave index support
- * Format of a slave record, recording how much space is granted to a given
- * slave
- */
-struct lquota_slv_rec { /* 8 bytes */
-	__u64 qsr_granted; /* space granted to the slave for the key=ID,
-			    * in #inodes or kbytes */
-};
-
 /* Data structures associated with the quota locks */
 
 /* Glimpse descriptor used for the index & per-ID quota locks */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index c61d46f..249f9b3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -336,10 +336,6 @@ void lustre_assert_wire_constants(void)
 	CLASSERT(LUSTRE_RES_ID_QUOTA_SEQ_OFF == 2);
 	CLASSERT(LUSTRE_RES_ID_QUOTA_VER_OID_OFF == 3);
 	CLASSERT(LUSTRE_RES_ID_HSH_OFF == 3);
-	CLASSERT(LQUOTA_TYPE_USR == 0);
-	CLASSERT(LQUOTA_TYPE_GRP == 1);
-	CLASSERT(LQUOTA_RES_MD == 1);
-	CLASSERT(LQUOTA_RES_DT == 2);
 	LASSERTF(OBD_PING == 400, "found %lld\n",
 		 (long long)OBD_PING);
 	LASSERTF(OBD_LOG_CANCEL == 401, "found %lld\n",
@@ -1609,46 +1605,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(Q_FINVALIDATE == 0x800104, "found 0x%.8x\n",
 		Q_FINVALIDATE);
 
-	/* Checks for struct lquota_acct_rec */
-	LASSERTF((int)sizeof(struct lquota_acct_rec) == 16, "found %lld\n",
-		 (long long)(int)sizeof(struct lquota_acct_rec));
-	LASSERTF((int)offsetof(struct lquota_acct_rec, bspace) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_acct_rec, bspace));
-	LASSERTF((int)sizeof(((struct lquota_acct_rec *)0)->bspace) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_acct_rec *)0)->bspace));
-	LASSERTF((int)offsetof(struct lquota_acct_rec, ispace) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_acct_rec, ispace));
-	LASSERTF((int)sizeof(((struct lquota_acct_rec *)0)->ispace) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_acct_rec *)0)->ispace));
-
-	/* Checks for struct lquota_glb_rec */
-	LASSERTF((int)sizeof(struct lquota_glb_rec) == 32, "found %lld\n",
-		 (long long)(int)sizeof(struct lquota_glb_rec));
-	LASSERTF((int)offsetof(struct lquota_glb_rec, qbr_hardlimit) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_glb_rec, qbr_hardlimit));
-	LASSERTF((int)sizeof(((struct lquota_glb_rec *)0)->qbr_hardlimit) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_glb_rec *)0)->qbr_hardlimit));
-	LASSERTF((int)offsetof(struct lquota_glb_rec, qbr_softlimit) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_glb_rec, qbr_softlimit));
-	LASSERTF((int)sizeof(((struct lquota_glb_rec *)0)->qbr_softlimit) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_glb_rec *)0)->qbr_softlimit));
-	LASSERTF((int)offsetof(struct lquota_glb_rec, qbr_time) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_glb_rec, qbr_time));
-	LASSERTF((int)sizeof(((struct lquota_glb_rec *)0)->qbr_time) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_glb_rec *)0)->qbr_time));
-	LASSERTF((int)offsetof(struct lquota_glb_rec, qbr_granted) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_glb_rec, qbr_granted));
-	LASSERTF((int)sizeof(((struct lquota_glb_rec *)0)->qbr_granted) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_glb_rec *)0)->qbr_granted));
-
-	/* Checks for struct lquota_slv_rec */
-	LASSERTF((int)sizeof(struct lquota_slv_rec) == 8, "found %lld\n",
-		 (long long)(int)sizeof(struct lquota_slv_rec));
-	LASSERTF((int)offsetof(struct lquota_slv_rec, qsr_granted) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct lquota_slv_rec, qsr_granted));
-	LASSERTF((int)sizeof(((struct lquota_slv_rec *)0)->qsr_granted) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lquota_slv_rec *)0)->qsr_granted));
-
 	/* Checks for struct idx_info */
 	LASSERTF((int)sizeof(struct idx_info) == 80, "found %lld\n",
 		 (long long)(int)sizeof(struct idx_info));
-- 
2.1.0
