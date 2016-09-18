From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:07 -0400
Subject: [lustre-devel] [PATCH 008/124] staging: lustre: obd: add rnb_
	prefix to struct niobuf_remote members
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add the prefix rnb_ to the members of struct niobuf_remote. Delete the
relevant compat macros from ofd_internal.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5061
Reviewed-on: http://review.whamcloud.com/10452
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 ++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |   14 +++++-----
 drivers/staging/lustre/lustre/osc/osc_request.c    |    8 +++---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    8 +++---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   24 ++++++++++----------
 5 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 3a0feac..6ff6615 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1803,9 +1803,9 @@ void lustre_swab_obd_ioobj(struct obd_ioobj *ioo);
 
 /* multiple of 8 bytes => can array */
 struct niobuf_remote {
-	__u64 offset;
-	__u32 len;
-	__u32 flags;
+	__u64	rnb_offset;
+	__u32	rnb_len;
+	__u32	rnb_flags;
 };
 
 void lustre_swab_niobuf_remote(struct niobuf_remote *nbr);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index e7c492e..6968953 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1437,9 +1437,9 @@ static int echo_client_prep_commit(const struct lu_env *env,
 			npages = tot_pages;
 
 		for (i = 0; i < npages; i++, off += PAGE_SIZE) {
-			rnb[i].offset = off;
-			rnb[i].len = PAGE_SIZE;
-			rnb[i].flags = brw_flags;
+			rnb[i].rnb_offset = off;
+			rnb[i].rnb_len = PAGE_SIZE;
+			rnb[i].rnb_flags = brw_flags;
 		}
 
 		ioo.ioo_bufcnt = npages;
@@ -1469,13 +1469,13 @@ static int echo_client_prep_commit(const struct lu_env *env,
 			if (rw == OBD_BRW_WRITE)
 				echo_client_page_debug_setup(page, rw,
 							    ostid_id(&oa->o_oi),
-							     rnb[i].offset,
-							     rnb[i].len);
+							     rnb[i].rnb_offset,
+							     rnb[i].rnb_len);
 			else
 				echo_client_page_debug_check(page,
 							    ostid_id(&oa->o_oi),
-							     rnb[i].offset,
-							     rnb[i].len);
+							     rnb[i].rnb_offset,
+							     rnb[i].rnb_len);
 		}
 
 		ret = obd_commitrw(env, rw, exp, oa, 1, &ioo,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index bdb329d..e861973 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1335,11 +1335,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 		if (i > 0 && can_merge_pages(pg_prev, pg)) {
 			niobuf--;
-			niobuf->len += pg->count;
+			niobuf->rnb_len += pg->count;
 		} else {
-			niobuf->offset = pg->off;
-			niobuf->len = pg->count;
-			niobuf->flags = pg->flag;
+			niobuf->rnb_offset = pg->off;
+			niobuf->rnb_len = pg->count;
+			niobuf->rnb_flags = pg->flag;
 		}
 		pg_prev = pg;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 2cf3a51..102f0aa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1604,9 +1604,9 @@ EXPORT_SYMBOL(lustre_swab_obd_ioobj);
 
 void lustre_swab_niobuf_remote(struct niobuf_remote *nbr)
 {
-	__swab64s(&nbr->offset);
-	__swab32s(&nbr->len);
-	__swab32s(&nbr->flags);
+	__swab64s(&nbr->rnb_offset);
+	__swab32s(&nbr->rnb_len);
+	__swab32s(&nbr->rnb_flags);
 }
 EXPORT_SYMBOL(lustre_swab_niobuf_remote);
 
@@ -2061,7 +2061,7 @@ EXPORT_SYMBOL(dump_ioo);
 void dump_rniobuf(struct niobuf_remote *nb)
 {
 	CDEBUG(D_RPCTRACE, "niobuf_remote: offset=%llu, len=%d, flags=%x\n",
-	       nb->offset, nb->len, nb->flags);
+	       nb->rnb_offset, nb->rnb_len, nb->rnb_flags);
 }
 EXPORT_SYMBOL(dump_rniobuf);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index eb6d88e..2390255 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1652,18 +1652,18 @@ void lustre_assert_wire_constants(void)
 	/* Checks for struct niobuf_remote */
 	LASSERTF((int)sizeof(struct niobuf_remote) == 16, "found %lld\n",
 		 (long long)(int)sizeof(struct niobuf_remote));
-	LASSERTF((int)offsetof(struct niobuf_remote, offset) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct niobuf_remote, offset));
-	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->offset) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct niobuf_remote *)0)->offset));
-	LASSERTF((int)offsetof(struct niobuf_remote, len) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct niobuf_remote, len));
-	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->len) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct niobuf_remote *)0)->len));
-	LASSERTF((int)offsetof(struct niobuf_remote, flags) == 12, "found %lld\n",
-		 (long long)(int)offsetof(struct niobuf_remote, flags));
-	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct niobuf_remote *)0)->flags));
+	LASSERTF((int)offsetof(struct niobuf_remote, rnb_offset) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct niobuf_remote, rnb_offset));
+	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->rnb_offset) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct niobuf_remote *)0)->rnb_offset));
+	LASSERTF((int)offsetof(struct niobuf_remote, rnb_len) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct niobuf_remote, rnb_len));
+	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->rnb_len) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct niobuf_remote *)0)->rnb_len));
+	LASSERTF((int)offsetof(struct niobuf_remote, rnb_flags) == 12, "found %lld\n",
+		 (long long)(int)offsetof(struct niobuf_remote, rnb_flags));
+	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->rnb_flags) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct niobuf_remote *)0)->rnb_flags));
 	LASSERTF(OBD_BRW_READ == 0x01, "found 0x%.8x\n",
 		 OBD_BRW_READ);
 	LASSERTF(OBD_BRW_WRITE == 0x02, "found 0x%.8x\n",
-- 
1.7.1
