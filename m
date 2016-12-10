From: James Simmons <jsimmons@infradead.org>
Date: Sat, 10 Dec 2016 13:05:57 -0500
Subject: [lustre-devel] [PATCH v2 1/5] staging: lustre: obdclass: Create a
	header for obdo related functions
In-Reply-To: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1481393161-22623-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Remove all obdo related functions from lustre_idl.h
Create lustre_odbo.h. Include where appropriate.
Make the functions lustre_get_wire_obdo and
lustre_set_wire_obdo to not be inlined functions.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/16917
Reviewed-on: http://review.whamcloud.com/19266
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---

Changelog:

v1) Initial patch from earlier version that broke build

v2) Include lustre_obdo.h to osc_request.c so it can
    build. Next move style changes from moved functions
    to separate patch.

 .../lustre/lustre/include/lustre/lustre_idl.h      | 46 ------------------
 .../staging/lustre/lustre/include/lustre_obdo.h    | 54 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/obdclass/obdo.c      | 53 +++++++++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_io.c         |  2 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |  1 +
 5 files changed, 110 insertions(+), 46 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_obdo.h

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 65ce503..b0eb80d 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3130,52 +3130,6 @@ struct obdo {
 #define o_cksum   o_nlink
 #define o_grant_used o_data_version
 
-static inline void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
-					struct obdo *wobdo,
-					const struct obdo *lobdo)
-{
-	*wobdo = *lobdo;
-	wobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
-	if (!ocd)
-		return;
-
-	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
-	    fid_seq_is_echo(ostid_seq(&lobdo->o_oi))) {
-		/* Currently OBD_FL_OSTID will only be used when 2.4 echo
-		 * client communicate with pre-2.4 server
-		 */
-		wobdo->o_oi.oi.oi_id = fid_oid(&lobdo->o_oi.oi_fid);
-		wobdo->o_oi.oi.oi_seq = fid_seq(&lobdo->o_oi.oi_fid);
-	}
-}
-
-static inline void lustre_get_wire_obdo(const struct obd_connect_data *ocd,
-					struct obdo *lobdo,
-					const struct obdo *wobdo)
-{
-	__u32 local_flags = 0;
-
-	if (lobdo->o_valid & OBD_MD_FLFLAGS)
-		local_flags = lobdo->o_flags & OBD_FL_LOCAL_MASK;
-
-	*lobdo = *wobdo;
-	if (local_flags != 0) {
-		lobdo->o_valid |= OBD_MD_FLFLAGS;
-		lobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
-		lobdo->o_flags |= local_flags;
-	}
-	if (!ocd)
-		return;
-
-	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
-	    fid_seq_is_echo(wobdo->o_oi.oi.oi_seq)) {
-		/* see above */
-		lobdo->o_oi.oi_fid.f_seq = wobdo->o_oi.oi.oi_seq;
-		lobdo->o_oi.oi_fid.f_oid = wobdo->o_oi.oi.oi_id;
-		lobdo->o_oi.oi_fid.f_ver = 0;
-	}
-}
-
 /* request structure for OST's */
 struct ost_body {
 	struct  obdo oa;
diff --git a/drivers/staging/lustre/lustre/include/lustre_obdo.h b/drivers/staging/lustre/lustre/include/lustre_obdo.h
new file mode 100644
index 0000000..1e12f8c
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre_obdo.h
@@ -0,0 +1,54 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ *
+ * Copyright 2015 Cray Inc, all rights reserved.
+ * Author: Ben Evans.
+ *
+ * Define obdo associated functions
+ *   obdo:  OBject Device o...
+ */
+
+#ifndef _LUSTRE_OBDO_H_
+#define _LUSTRE_OBDO_H_
+
+#include "lustre/lustre_idl.h"
+
+/**
+ * Create an obdo to send over the wire
+ */
+void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
+			  struct obdo *wobdo,
+			  const struct obdo *lobdo);
+
+/**
+ * Create a local obdo from a wire based odbo
+ */
+void lustre_get_wire_obdo(const struct obd_connect_data *ocd,
+			  struct obdo *lobdo,
+			  const struct obdo *wobdo);
+
+#endif
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index c52b9e0..241e60b 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -40,6 +40,7 @@
 
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_idl.h"
+#include "../include/lustre_obdo.h"
 
 void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent)
 {
@@ -124,3 +125,55 @@ void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj)
 	ioobj->ioo_max_brw = 0;
 }
 EXPORT_SYMBOL(obdo_to_ioobj);
+
+/**
+ * Create an obdo to send over the wire
+ */
+void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
+			  struct obdo *wobdo, const struct obdo *lobdo)
+{
+	*wobdo = *lobdo;
+	wobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
+	if (!ocd)
+		return;
+
+	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
+	    fid_seq_is_echo(ostid_seq(&lobdo->o_oi))) {
+		/* Currently OBD_FL_OSTID will only be used when 2.4 echo
+		 * client communicate with pre-2.4 server
+		 */
+		wobdo->o_oi.oi.oi_id = fid_oid(&lobdo->o_oi.oi_fid);
+		wobdo->o_oi.oi.oi_seq = fid_seq(&lobdo->o_oi.oi_fid);
+	}
+}
+EXPORT_SYMBOL(lustre_set_wire_obdo);
+
+/**
+ * Create a local obdo from a wire based odbo
+ */
+void lustre_get_wire_obdo(const struct obd_connect_data *ocd,
+			  struct obdo *lobdo, const struct obdo *wobdo)
+{
+	__u32 local_flags = 0;
+
+	if (lobdo->o_valid & OBD_MD_FLFLAGS)
+		local_flags = lobdo->o_flags & OBD_FL_LOCAL_MASK;
+
+	*lobdo = *wobdo;
+	if (local_flags != 0) {
+		lobdo->o_valid |= OBD_MD_FLFLAGS;
+		lobdo->o_flags &= ~OBD_FL_LOCAL_MASK;
+		lobdo->o_flags |= local_flags;
+	}
+	if (!ocd)
+		return;
+
+	if (unlikely(!(ocd->ocd_connect_flags & OBD_CONNECT_FID)) &&
+	    fid_seq_is_echo(wobdo->o_oi.oi.oi_seq)) {
+		/* see above */
+		lobdo->o_oi.oi_fid.f_seq = wobdo->o_oi.oi.oi_seq;
+		lobdo->o_oi.oi_fid.f_oid = wobdo->o_oi.oi.oi_id;
+		lobdo->o_oi.oi_fid.f_ver = 0;
+	}
+}
+EXPORT_SYMBOL(lustre_get_wire_obdo);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 228a97c..164aec3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -37,6 +37,8 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
+#include "../include/lustre_obdo.h"
+
 #include "osc_cl_internal.h"
 
 /** \addtogroup osc
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7143564..99aefa5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -43,6 +43,7 @@
 #include "../include/lprocfs_status.h"
 #include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_debug.h"
+#include "../include/lustre_obdo.h"
 #include "../include/lustre_param.h"
 #include "../include/lustre_fid.h"
 #include "../include/obd_class.h"
-- 
1.8.3.1
