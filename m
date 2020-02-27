From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:09 -0500
Subject: [lustre-devel] [PATCH 441/622] lustre: osc: add preferred checksum
 type support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-442-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

Some checksum types might not work correctly even though they are
available options and have the best speeds during test. In these
circumstances, users might want to use a certain checksum type which
is known to be functional. However, "lctl conf_param XXX-YYY.osc.
checksum_type=ZZZ" won't help to enforce a certain checksum type,
because the selected checksum type is determined during OSC
connection, which will overwrite the LLOG parameter.

To solve this problem, whenever a valid checksum type is set by "lctl
conf_param" or "lctl set_param", it is remembered as the perferred
checksum type for the OSC. During connection process, if that
checksum type is available, that checksum type will be selected as
the RPC checksum type regardless of its speed.

The semantics of interface /proc/fs/lustre/osc/*/checksum_type is
changed for a little bit. If a wrong checksum name is being written
into this entry, -EINVAL will be returned as before. If the written
string is a valid checksum name, even though the checksum type is
not supported by this OSC/OST pair, the checksum type will still be
remembered as the perferred checksum type, and return value will be
-ENOTSUPP. Whenever connecting/reconnecting happens, if perferred
checksum type is available, it will be used for the RPC checksum.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11011
Lustre-commit: 9b6b5e479828 ("LU-11011 osc: add preferred checksum type support")
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/32349
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h       |  2 ++
 fs/lustre/include/obd_cksum.h | 13 ++++++++++---
 fs/lustre/ldlm/ldlm_lib.c     |  1 +
 fs/lustre/osc/lproc_osc.c     | 19 ++++++++++++-------
 fs/lustre/ptlrpc/import.c     |  3 ++-
 5 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 886c697..70dbaaf 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -339,6 +339,8 @@ struct client_obd {
 	u32			cl_supp_cksum_types;
 	/* checksum algorithm to be used */
 	enum cksum_type		cl_cksum_type;
+	/* preferred checksum algorithm to be used */
+	enum cksum_type		cl_preferred_cksum_type;
 
 	/* also protected by the poorly named _loi_list_lock lock above */
 	struct osc_async_rc     cl_ar;
diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index cc47c44..c03d0e6 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -109,10 +109,17 @@ static inline enum cksum_type obd_cksum_types_supported_client(void)
  * Caution is advised, however, since what is fastest on a single client may
  * not be the fastest or most efficient algorithm on the server.
  */
-static inline enum cksum_type
-obd_cksum_type_select(const char *obd_name, enum cksum_type cksum_types)
+static inline
+enum cksum_type obd_cksum_type_select(const char *obd_name,
+				       enum cksum_type cksum_types,
+				       enum cksum_type preferred)
 {
-	u32 flag = obd_cksum_type_pack(obd_name, cksum_types);
+	u32 flag;
+
+	if (preferred & cksum_types)
+		return preferred;
+
+	flag = obd_cksum_type_pack(obd_name, cksum_types);
 
 	return obd_cksum_type_unpack(flag);
 }
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index af74f97..127ed32 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -364,6 +364,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	atomic_set(&cli->cl_destroy_in_flight, 0);
 
 	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
+	cli->cl_preferred_cksum_type = 0;
 	/* Turn on checksumming by default. */
 	cli->cl_checksum = 1;
 	/*
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 775bf74..8e0088b 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -415,6 +415,7 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 	DECLARE_CKSUM_NAME;
 	char kernbuf[10];
 	int i;
+	int rc = -EINVAL;
 
 	if (!obd)
 		return 0;
@@ -423,22 +424,26 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 		return -EINVAL;
 	if (copy_from_user(kernbuf, buffer, count))
 		return -EFAULT;
+
 	if (count > 0 && kernbuf[count - 1] == '\n')
 		kernbuf[count - 1] = '\0';
 	else
 		kernbuf[count] = '\0';
 
 	for (i = 0; i < ARRAY_SIZE(cksum_name); i++) {
-		if (((1 << i) & obd->u.cli.cl_supp_cksum_types) == 0)
-			continue;
-		if (!strcmp(kernbuf, cksum_name[i])) {
-			obd->u.cli.cl_cksum_type = 1 << i;
-			return count;
+		if (strcmp(kernbuf, cksum_name[i]) == 0) {
+			obd->u.cli.cl_preferred_cksum_type = BIT(i);
+			if (obd->u.cli.cl_supp_cksum_types & BIT(i)) {
+				obd->u.cli.cl_cksum_type = BIT(i);
+				rc = count;
+			} else {
+				rc = -ENOTSUPP;
+			}
+			break;
 		}
 	}
-	return -EINVAL;
+	return rc;
 }
-
 LPROC_SEQ_FOPS(osc_checksum_type);
 
 static ssize_t resend_count_show(struct kobject *kobj,
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 0ade41e..a6d0b32 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -846,7 +846,8 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 		cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
 	}
 	cli->cl_cksum_type = obd_cksum_type_select(imp->imp_obd->obd_name,
-						   cli->cl_supp_cksum_types);
+						   cli->cl_supp_cksum_types,
+						   cli->cl_preferred_cksum_type);
 
 	if (ocd->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
 		cli->cl_max_pages_per_rpc =
-- 
1.8.3.1
