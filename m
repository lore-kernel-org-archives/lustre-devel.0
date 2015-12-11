From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Fri, 11 Dec 2015 18:04:20 -0500
Subject: [lustre-devel] [PATCH v2 1/6] staging/lustre: Silence warning about
	'inline'
In-Reply-To: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
References: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
Message-ID: <1449875065-35182-2-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Low-hanging fruit first:

  CC [M]  drivers/staging/lustre/lustre/fid/fid_request.o
In file included from drivers/staging/lustre/lustre/fid/../include/lustre_net.h:66:0,
                 from drivers/staging/lustre/lustre/fid/../include/lustre_lib.h:64,
                 from drivers/staging/lustre/lustre/fid/../include/obd.h:52,
                 from drivers/staging/lustre/lustre/fid/fid_request.c:48:
drivers/staging/lustre/lustre/fid/../include/lu_object.h:765:1: warning: 'inline' is not at beginning of declaration [-Wold-style-declaration]
 static const inline struct lu_device_operations *
 ^

So we just swap inline and const.  272 warnings gone. :)

Signed-off-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---
 drivers/staging/lustre/lustre/include/lu_object.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index fa78689748a9..176724f60c1b 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -756,7 +756,7 @@ static inline const struct lu_fid *lu_object_fid(const struct lu_object *o)
 /**
  * return device operations vector for this object
  */
-static const inline struct lu_device_operations *
+static inline const struct lu_device_operations *
 lu_object_ops(const struct lu_object *o)
 {
 	return o->lo_dev->ld_ops;
-- 
2.6.3
