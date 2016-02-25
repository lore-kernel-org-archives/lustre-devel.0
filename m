From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:47 -0500
Subject: [lustre-devel] [PATCH v2 04/84] staging/lustre: Get rid of
	loc_flags_t typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with direct reference of enum loc_flags

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lu_object.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index c1c7aa1..23e5567 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -164,11 +164,11 @@ struct lu_device_operations {
 /**
  * For lu_object_conf flags
  */
-typedef enum {
+enum loc_flags {
 	/* This is a new object to be allocated, or the file
 	 * corresponding to the object does not exists. */
 	LOC_F_NEW	= 0x00000001,
-} loc_flags_t;
+};
 
 /**
  * Object configuration, describing particulars of object being created. On
@@ -179,7 +179,7 @@ struct lu_object_conf {
 	/**
 	 * Some hints for obj find and alloc.
 	 */
-	loc_flags_t     loc_flags;
+	enum loc_flags     loc_flags;
 };
 
 /**
-- 
2.1.0
