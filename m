From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 15:57:13 -0400
Subject: [lustre-devel] [PATCH v4 7/7] staging:lustre: Update license and
	copyright for lib-socket.c
In-Reply-To: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433361433-24976-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Point to the right place for GNU license. Update Intel copyright.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index f0b187d..2f8443c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -15,11 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
@@ -27,11 +23,11 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
+ * Lustre is a trademark of Seagate, Inc.
  */
 #define DEBUG_SUBSYSTEM S_LNET
 
-- 
1.7.1
