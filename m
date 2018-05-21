From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 27/30] staging: lustre: remove libcfs_all.h
 from fid, fld, obdclass
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731340.24196.10418954578125073950.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

None of these files seem to nee libcfs_all.h

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/fid_lib.c        |    1 -
 drivers/staging/lustre/lustre/fid/fid_request.c    |    1 -
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    1 -
 drivers/staging/lustre/lustre/fld/fld_cache.c      |    1 -
 drivers/staging/lustre/lustre/fld/fld_request.c    |    1 -
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    1 -
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    1 -
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    1 -
 .../lustre/lustre/obdclass/linux/linux-module.c    |    1 -
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 --
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    |    2 --
 drivers/staging/lustre/lustre/obdclass/uuid.c      |    2 --
 12 files changed, 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index c2074beec5e9..ac52b378c155 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -40,7 +40,6 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 #include <lustre_fid.h>
 
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 693dc96f4175..c674652af03a 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -39,7 +39,6 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 528b659cd9e8..0aabf473c9bd 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -39,7 +39,6 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 63e6909a3edd..a7415c9a1c28 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -40,7 +40,6 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 05ec4afa7513..7b7ba93a4db6 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -39,7 +39,6 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 49ea18d74cb2..0bcfb26ef8aa 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -40,7 +40,6 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index c42ddd50b6e3..42cce2dc5a45 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -47,7 +47,6 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs_all.h>
 /* class_put_type() */
 #include <obd_class.h>
 #include <obd_support.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 0712d795788a..916cf81c5997 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -38,7 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs_all.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 0a21a27c1a3a..d3196439985b 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -60,7 +60,6 @@
 #include <linux/seq_file.h>
 #include <linux/kobject.h>
 
-#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lnet/lnetctl.h>
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 55efd704c9e8..8dd57eab57be 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -41,8 +41,6 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <linux/module.h>
 #include <linux/processor.h>
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index bb90e6c0011c..f67cb89ea0ba 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -39,8 +39,6 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd.h>
 #include <obd_class.h>
 #include <obd_support.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
index 8d14a0177a3f..ec8c6dc5c9a7 100644
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ b/drivers/staging/lustre/lustre/obdclass/uuid.c
@@ -35,8 +35,6 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd_support.h>
 #include <obd_class.h>
 
