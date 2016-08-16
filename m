From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:03 -0400
Subject: [lustre-devel] [PATCH 50/80] staging: lustre: lov: new pattern flag
	for partially repaired file
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

When the layout LFSCK repairs orphan OST-object, if the parent
MDT-object was lost, then it will re-create the MDT-object and
regenerate the LOV EA and fill the target LOV EA slot with the
orphan information, and fill other slots with zero (LOV hole);
if related LOV EA slot is invalid or hole, then it will refill
the target LOV EA slot; if the target slot exceeds current LOV
EA tail, then extend the LOV EA, and fill the gaps as zero.

Some of the LOV EA holes may cannot be re-filled finally because
of lost some OST-objects. And even if they can be re-filled, but
there are still some possible race accessings from client before
the re-filling. If the client access the LOV EA with hole(s), it
may cause some strange behaviour, such as trigger LBUG()/LASSERT()
on the client.

So we will make the client to be aware of the LOV EA is incomplete.
We introduce a new LOV EA pattern flag LOV_PATTERN_F_HOLE for that:
any time when the LFSCK repairs the LOV EA with hole(s), the LOV EA
will be marked as LOV_PATTERN_F_HOLE; when all the holes in the LOV
EA are refilled, the LOV_PATTERN_F_HOLE will be dropped.

For a new client, it recongizes the pattern flag LOV_PATTERN_F_HOLE,
then it can permit/forbid some opertions on the file with LOV holes:

 1) Normal read/write the file with LOV EA hole is permitted, but the
    application will get EIO error when read data from the dummy slot
    or write data to the dummy slot.
 2) The users can dump the recovered data via some common read tools,
    such as "dd conv=sync,noerror".

 3) Append data to the file which has LOV EA hole will get EIO failure.

 4) Other operations will skip the LOV EA hole(s), and will not get
    failures, such as {s,g}etattr, {s,g}getxattr, stat, chown/chgrp,
    chmod, touch, unlink, and so on.

For an old client, since it will not recognize the new pattern flag
LOV_PATTERN_F_HOLE. So the LOV EA with hole will be dicarded with
failure, but it will not cause the client to be crashed.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4675
Reviewed-on: http://review.whamcloud.com/10042
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 .../lustre/lustre/include/lustre/lustre_user.h     |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   16 +++++++++++++---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 ++
 6 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 69bed64..87eef4c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1289,6 +1289,7 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 #define OBD_CONNECT_OPEN_BY_FID	0x20000000000000ULL	/* open by fid won't pack
 							 * name in request
 							 */
+#define OBD_CONNECT_LFSCK	0x40000000000000ULL/* support online LFSCK */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 8398c4f..9e38ed3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -284,9 +284,9 @@ struct ost_id {
 #define LOV_PATTERN_CMOBD	0x200
 
 #define LOV_PATTERN_F_MASK	0xffff0000
+#define LOV_PATTERN_F_HOLE	0x40000000 /* there is hole in LOV EA */
 #define LOV_PATTERN_F_RELEASED	0x80000000 /* HSM released file */
 
-
 #define LOV_MAXPOOLNAME 16
 #define LOV_POOLNAMEF "%.16s"
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ac59cd6..dd44ee8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -189,7 +189,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_PINGLESS |
 				  OBD_CONNECT_MAX_EASIZE |
 				  OBD_CONNECT_FLOCK_DEAD |
-				  OBD_CONNECT_DISP_STRIPE;
+				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK;
 
 	if (sbi->ll_flags & LL_SBI_SOM_PREVIEW)
 		data->ocd_connect_flags |= OBD_CONNECT_SOM;
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 84032a5..95126c3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -298,8 +298,8 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	return result;
 }
 
-static void lov_io_slice_init(struct lov_io *lio,
-			      struct lov_object *obj, struct cl_io *io)
+static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
+			     struct cl_io *io)
 {
 	io->ci_result = 0;
 	lio->lis_object = obj;
@@ -314,6 +314,15 @@ static void lov_io_slice_init(struct lov_io *lio,
 		lio->lis_io_endpos = lio->lis_endpos;
 		if (cl_io_is_append(io)) {
 			LASSERT(io->ci_type == CIT_WRITE);
+
+			/*
+			 * If there is LOV EA hole, then we may cannot locate
+			 * the current file-tail exactly.
+			 */
+			if (unlikely(obj->lo_lsm->lsm_pattern &
+				     LOV_PATTERN_F_HOLE))
+				return -EIO;
+
 			lio->lis_pos = 0;
 			lio->lis_endpos = OBD_OBJECT_EOF;
 		}
@@ -349,6 +358,7 @@ static void lov_io_slice_init(struct lov_io *lio,
 	default:
 		LBUG();
 	}
+	return 0;
 }
 
 static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
@@ -870,7 +880,7 @@ int lov_io_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	struct lov_object   *lov = cl2lov(obj);
 
 	INIT_LIST_HEAD(&lio->lis_active);
-	lov_io_slice_init(lio, lov, io);
+	io->ci_result = lov_io_slice_init(lio, lov, io);
 	if (io->ci_result == 0) {
 		io->ci_result = lov_io_subio_init(env, lio, io);
 		if (io->ci_result == 0) {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index c83d28e..f42ed17 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -97,6 +97,8 @@ static const char * const obd_connect_names[] = {
 	"flock_deadlock",
 	"disp_stripe",
 	"unknown",
+	"lfsck",
+	"unknown",
 	NULL
 };
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index bc27f8d..9d5d2c8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1071,6 +1071,8 @@ void lustre_assert_wire_constants(void)
 		 "found 0x%.16llxULL\n", OBD_CONNECT_FLOCK_DEAD);
 	LASSERTF(OBD_CONNECT_OPEN_BY_FID == 0x20000000000000ULL,
 		 "found 0x%.16llxULL\n", OBD_CONNECT_OPEN_BY_FID);
+	LASSERTF(OBD_CONNECT_LFSCK == 0x40000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_LFSCK);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		(unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
1.7.1
