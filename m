From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:08 -0400
Subject: [lustre-devel] [PATCH v4 2/9] staging:lustre: remove
	lnet/include/lnet/linux/
In-Reply-To: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1434050295-10986-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Remove the linux specific headers from lnet/include/lnet/linux/,
moving whatever was worthwhile from them to their parent headers or
elsewhere.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/12932
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/lnet/api-support.h        |   44 ------
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 -
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 -
 .../lustre/include/linux/lnet/linux/api-support.h  |   42 ------
 .../lustre/include/linux/lnet/linux/lib-lnet.h     |   71 ----------
 .../lustre/include/linux/lnet/linux/lib-types.h    |   45 ------
 .../staging/lustre/include/linux/lnet/linux/lnet.h |   56 --------
 .../lustre/include/linux/lnet/lnet-sysctl.h        |   49 -------
 drivers/staging/lustre/include/linux/lnet/lnet.h   |    2 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    5 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    1 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    1 -
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |    3 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 -
 drivers/staging/lustre/lnet/lnet/router.c          |  145 --------------------
 15 files changed, 4 insertions(+), 466 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h

diff --git a/drivers/staging/lustre/include/linux/lnet/api-support.h b/drivers/staging/lustre/include/linux/lnet/api-support.h
deleted file mode 100644
index 8f7fa28..0000000
--- a/drivers/staging/lustre/include/linux/lnet/api-support.h
+++ /dev/null
@@ -1,44 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_API_SUPPORT_H__
-#define __LNET_API_SUPPORT_H__
-
-#include "linux/api-support.h"
-
-#include "../libcfs/libcfs.h"
-#include "types.h"
-#include "lnet.h"
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index ffe88f6..c46e0e6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -41,7 +41,6 @@
 #ifndef __LNET_LIB_LNET_H__
 #define __LNET_LIB_LNET_H__
 
-#include "linux/lib-lnet.h"
 #include "../libcfs/libcfs.h"
 #include "types.h"
 #include "lnet.h"
@@ -654,7 +653,6 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 		      __u32 peer_ip, int peer_port);
 void libcfs_sock_release(struct socket *sock);
 
-void lnet_get_tunables(void);
 int lnet_peers_start_down(void);
 int lnet_peer_buffer_credits(lnet_ni_t *ni);
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index ad6df88..4b862d3 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -42,8 +42,6 @@
 #ifndef __LNET_LIB_TYPES_H__
 #define __LNET_LIB_TYPES_H__
 
-#include "linux/lib-types.h"
-
 #include "../libcfs/libcfs.h"
 #include <linux/list.h>
 #include "types.h"
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/api-support.h b/drivers/staging/lustre/include/linux/lnet/linux/api-support.h
deleted file mode 100644
index e237ad6..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/api-support.h
+++ /dev/null
@@ -1,42 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LINUX_API_SUPPORT_H__
-#define __LINUX_API_SUPPORT_H__
-
-#ifndef __LNET_API_SUPPORT_H__
-#error Do not #include this file directly. #include <lnet /api-support.h> instead
-#endif
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
deleted file mode 100644
index 0f8f04d..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
+++ /dev/null
@@ -1,71 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_LINUX_LIB_LNET_H__
-#define __LNET_LINUX_LIB_LNET_H__
-
-#ifndef __LNET_LIB_LNET_H__
-#error Do not #include this file directly. #include <linux/lnet/lib-lnet.h> instead
-#endif
-
-# include <asm/page.h>
-# include <linux/string.h>
-# include <asm/io.h>
-#include "../../libcfs/libcfs.h"
-
-static inline __u64
-lnet_page2phys(struct page *p)
-{
-	/* compiler optimizer will elide unused branches */
-
-	switch (sizeof(typeof(page_to_phys(p)))) {
-	case 4:
-		/* page_to_phys returns a 32 bit physical address.  This must
-		 * be a 32 bit machine with <= 4G memory and we must ensure we
-		 * don't sign extend when converting to 64 bits. */
-		return (unsigned long)page_to_phys(p);
-
-	case 8:
-		/* page_to_phys returns a 64 bit physical address :) */
-		return page_to_phys(p);
-
-	default:
-		LBUG();
-		return 0;
-	}
-}
-
-#define LNET_ROUTER
-
-#endif /* __LNET_LINUX_LIB_LNET_H__ */
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/lib-types.h b/drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
deleted file mode 100644
index 669e8c0..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
+++ /dev/null
@@ -1,45 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_LINUX_LIB_TYPES_H__
-#define __LNET_LINUX_LIB_TYPES_H__
-
-#ifndef __LNET_LIB_TYPES_H__
-#error Do not #include this file directly. #include <linux/lnet/lib-types.h> instead
-#endif
-
-# include <linux/uio.h>
-# include <linux/types.h>
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/linux/lnet.h b/drivers/staging/lustre/include/linux/lnet/linux/lnet.h
deleted file mode 100644
index 1e888f1..0000000
--- a/drivers/staging/lustre/include/linux/lnet/linux/lnet.h
+++ /dev/null
@@ -1,56 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_LINUX_LNET_H__
-#define __LNET_LINUX_LNET_H__
-
-#ifndef __LNET_H__
-#error Do not #include this file directly. #include <linux/lnet/lnet.h> instead
-#endif
-
-/*
- * lnet.h
- *
- * User application interface file
- */
-
-#include <linux/uio.h>
-#include <linux/types.h>
-
-#define cfs_tcp_sendpage(sk, page, offset, size, flags) \
-	tcp_sendpage(sk, page, offset, size, flags)
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h b/drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
deleted file mode 100644
index 2dee1b9..0000000
--- a/drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
+++ /dev/null
@@ -1,49 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LNET_SYSCTL_H__
-#define __LNET_SYSCTL_H__
-
-#if defined(CONFIG_SYSCTL)
-
-#define CTL_KRANAL      201
-#define CTL_O2IBLND     205
-#define CTL_PTLLND      206
-#define CTL_QSWNAL      207
-#define CTL_SOCKLND     208
-#define CTL_GNILND      210
-
-#endif
-
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lnet.h b/drivers/staging/lustre/include/linux/lnet/lnet.h
index 75c0ab9..8d054a1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnet.h
@@ -40,8 +40,6 @@
  *
  * User application interface file
  */
-#include "linux/lnet.h"
-
 #include "types.h"
 #include "api.h"
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 2a72427..48454a5 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -38,8 +38,9 @@
  * Author: Eric Barton <eric@bartonsoftware.com>
  */
 
-#include "o2iblnd.h"
 #include <asm/div64.h>
+#include <asm/page.h>
+#include "o2iblnd.h"
 
 static lnd_t the_o2iblnd = {
 	.lnd_type     = O2IBLND,
@@ -1176,7 +1177,7 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 
 		CDEBUG(D_NET, "rx %d: %p %#llx(%#llx)\n",
 		       i, rx->rx_msg, rx->rx_msgaddr,
-		       lnet_page2phys(pg) + pg_off);
+		       (__u64)(page_to_phys(pg) + pg_off));
 
 		pg_off += IBLND_MSG_SIZE;
 		LASSERT(pg_off <= PAGE_SIZE);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 7f52c69..f5d1d9f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -65,7 +65,6 @@
 #include "../../../include/linux/libcfs/libcfs.h"
 #include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
-#include "../../../include/linux/lnet/lnet-sysctl.h"
 
 #include <rdma/rdma_cm.h>
 #include <rdma/ib_cm.h>
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 06531c1..53275f9 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -34,7 +34,6 @@
 #include "../../../include/linux/lnet/lnet.h"
 #include "../../../include/linux/lnet/lib-lnet.h"
 #include "../../../include/linux/lnet/socklnd.h"
-#include "../../../include/linux/lnet/lnet-sysctl.h"
 
 #define SOCKNAL_PEER_HASH_SIZE  101   /* # peer lists */
 #define SOCKNAL_RESCHED         100   /* # scheduler loops before reschedule */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
index 34c6a72..2b40a9f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
@@ -146,8 +146,7 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 			rc = sk->sk_prot->sendpage(sk, page,
 						   offset, fragsize, msgflg);
 		} else {
-			rc = cfs_tcp_sendpage(sk, page, offset, fragsize,
-					      msgflg);
+			rc = tcp_sendpage(sk, page, offset, fragsize, msgflg);
 		}
 	} else {
 #if SOCKNAL_SINGLE_FRAG_TX || !SOCKNAL_RISK_KMAP_DEADLOCK
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 9fc3bf6..a2d0d10 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1218,8 +1218,6 @@ LNetNIInit(lnet_pid_t requested_pid)
 		goto out;
 	}
 
-	lnet_get_tunables();
-
 	if (requested_pid == LNET_PID_ANY) {
 		/* Don't instantiate LNET just for me */
 		rc = -ENETDOWN;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 96886a2..4fbae5e 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -24,8 +24,6 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include "../../include/linux/lnet/lib-lnet.h"
 
-#if  defined(LNET_ROUTER)
-
 #define LNET_NRB_TINY_MIN	512	/* min value for each CPT */
 #define LNET_NRB_TINY		(LNET_NRB_TINY_MIN * 4)
 #define LNET_NRB_SMALL_MIN	4096	/* min value for each CPT */
@@ -70,15 +68,6 @@ lnet_peer_buffer_credits(lnet_ni_t *ni)
 
 /* forward ref's */
 static int lnet_router_checker(void *);
-#else
-
-int
-lnet_peer_buffer_credits(lnet_ni_t *ni)
-{
-	return 0;
-}
-
-#endif
 
 static int check_routers_before_use;
 module_param(check_routers_before_use, int, 0444);
@@ -1163,9 +1152,6 @@ lnet_prune_rc_data(int wait_unlink)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
-
-#if  defined(LNET_ROUTER)
-
 static int
 lnet_router_checker(void *arg)
 {
@@ -1573,134 +1559,3 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	return 0;
 }
 EXPORT_SYMBOL(lnet_notify);
-
-void
-lnet_get_tunables(void)
-{
-}
-
-#else
-
-int
-lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
-{
-	return -EOPNOTSUPP;
-}
-
-void
-lnet_router_checker(void)
-{
-	static time_t last;
-	static int running;
-
-	time_t now = get_seconds();
-	int interval = now - last;
-	int rc;
-	__u64 version;
-	lnet_peer_t *rtr;
-
-	/* It's no use to call me again within a sec - all intervals and
-	 * timeouts are measured in seconds */
-	if (last != 0 && interval < 2)
-		return;
-
-	if (last != 0 &&
-	    interval > max(live_router_check_interval,
-			   dead_router_check_interval))
-		CNETERR("Checker(%d/%d) not called for %d seconds\n",
-			live_router_check_interval, dead_router_check_interval,
-			interval);
-
-	LASSERT(LNET_CPT_NUMBER == 1);
-
-	lnet_net_lock(0);
-	LASSERT(!running); /* recursion check */
-	running = 1;
-	lnet_net_unlock(0);
-
-	last = now;
-
-	if (the_lnet.ln_rc_state == LNET_RC_STATE_STOPPING)
-		lnet_prune_rc_data(0); /* unlink all rcd and nowait */
-
-	/* consume all pending events */
-	while (1) {
-		int i;
-		lnet_event_t ev;
-
-		/* NB ln_rc_eqh must be the 1st in 'eventqs' otherwise the
-		 * recursion breaker in LNetEQPoll would fail */
-		rc = LNetEQPoll(&the_lnet.ln_rc_eqh, 1, 0, &ev, &i);
-		if (rc == 0)   /* no event pending */
-			break;
-
-		/* NB a lost SENT prevents me from pinging a router again */
-		if (rc == -EOVERFLOW) {
-			CERROR("Dropped an event!!!\n");
-			abort();
-		}
-
-		LASSERT(rc == 1);
-
-		lnet_router_checker_event(&ev);
-	}
-
-	if (the_lnet.ln_rc_state == LNET_RC_STATE_STOPPING) {
-		lnet_prune_rc_data(1); /* release rcd */
-		the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
-		running = 0;
-		return;
-	}
-
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
-
-	lnet_net_lock(0);
-
-	version = the_lnet.ln_routers_version;
-	list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
-		lnet_ping_router_locked(rtr);
-		LASSERT(version == the_lnet.ln_routers_version);
-	}
-
-	lnet_net_unlock(0);
-
-	running = 0; /* lock only needed for the recursion check */
-}
-
-/* NB lnet_peers_start_down depends on me,
- * so must be called before any peer creation */
-void
-lnet_get_tunables(void)
-{
-	char *s;
-
-	s = getenv("LNET_ROUTER_PING_TIMEOUT");
-	if (s != NULL)
-		router_ping_timeout = atoi(s);
-
-	s = getenv("LNET_LIVE_ROUTER_CHECK_INTERVAL");
-	if (s != NULL)
-		live_router_check_interval = atoi(s);
-
-	s = getenv("LNET_DEAD_ROUTER_CHECK_INTERVAL");
-	if (s != NULL)
-		dead_router_check_interval = atoi(s);
-
-	/* This replaces old lnd_notify mechanism */
-	check_routers_before_use = 1;
-	if (dead_router_check_interval <= 0)
-		dead_router_check_interval = 30;
-}
-
-void
-lnet_rtrpools_free(void)
-{
-}
-
-int
-lnet_rtrpools_alloc(int im_a_arouter)
-{
-	return 0;
-}
-
-#endif
-- 
1.7.1
