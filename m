From: James Simmons <jsimmons@infradead.org>
Date: Tue, 23 Feb 2016 11:48:29 -0500
Subject: [lustre-devel] [PATCH 4/6] staging: lustre: update the
	MODULE_DESCRIPTION for all lustre modules
In-Reply-To: <1456246111-26263-1-git-send-email-jsimmons@infradead.org>
References: <1456246111-26263-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456246111-26263-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Fixup the MODULE_DESCRIPTION for several lustre modules. Some wrongly
place the version in the string or they are not descriptive enough.
Broken out of patch http://review.whamcloud.com/16787.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6204
Reviewed-on: http://review.whamcloud.com/16787
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |    2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |    2 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |    2 +-
 drivers/staging/lustre/lustre/llite/super25.c      |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 11 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 80f7985..b883b67 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2867,7 +2867,7 @@ static int __init kiblnd_module_init(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Kernel OpenIB gen2 LND v2.00");
+MODULE_DESCRIPTION("OpenIB gen2 LNet Network Driver");
 MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 0cf1e43..b2a104f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2925,7 +2925,7 @@ ksocknal_module_init(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Kernel TCP Socket LND v3.0.0");
+MODULE_DESCRIPTION("TCP Socket LNet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("2.7.0");
 
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 4923339..da3eb33 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -224,7 +224,7 @@ fini_lnet(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("LNet v3.1");
+MODULE_DESCRIPTION("Lustre Networking layer");
 MODULE_VERSION(LNET_VERSION);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 0d044b5..1683da9 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -463,7 +463,7 @@ static void __exit fid_mod_exit(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre FID Module");
+MODULE_DESCRIPTION("Lustre File IDentifier");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 8d93fee..2ddeb59 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -500,7 +500,7 @@ static void __exit fld_mod_exit(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre FLD");
+MODULE_DESCRIPTION("Lustre FID Location Database");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 778cfe3..d856b55 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -665,7 +665,7 @@ static void exit_libcfs_module(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Portals v3.1");
+MODULE_DESCRIPTION("Lustre helper library");
 MODULE_VERSION(LIBCFS_VERSION);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 8fde9bc..9d287db 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -207,7 +207,7 @@ static void __exit exit_lustre_lite(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Lite Client File System");
+MODULE_DESCRIPTION("Lustre Client File System");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 2ee8044..0a5931c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2816,7 +2816,7 @@ static void lmv_exit(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Logical Metadata Volume OBD driver");
+MODULE_DESCRIPTION("Lustre Logical Metadata Volume");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index dcaa5a1..b422b93 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2353,7 +2353,7 @@ static void /*__exit*/ lov_exit(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Logical Object Volume OBD driver");
+MODULE_DESCRIPTION("Lustre Logical Object Volume");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 9b6fd25..06649b1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -579,7 +579,7 @@ static void cleanup_obdclass(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Class Driver Build Version: " BUILD_VERSION);
+MODULE_DESCRIPTION("Lustre Class Driver");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 9f14183..562ef65 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1886,7 +1886,7 @@ static void /*__exit*/ obdecho_exit(void)
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Testing Echo OBD driver");
+MODULE_DESCRIPTION("Lustre Echo Client test driver");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
-- 
1.7.1
