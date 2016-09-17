From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sat, 17 Sep 2016 21:24:08 +0800
Subject: [lustre-devel] [PATCH] staging/lustre: clean function declaration
	in cl_io.c up
Message-ID: <1474118648-27446-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, jinshan.xiong@intel.com, john.hammond@intel.com, bobijam.xu@intel.com, lai.siyao@intel.com, mike.rapoport@gmail.com, shivanib134@gmail.com, shraddha.6596@gmail.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 1 warning when building kernel with W=1:
drivers/staging/lustre/lustre/obdclass/cl_page.c:488:6: warning: no previous prototype for 'cl_page_disown0' [-Wmissing-prototypes]

In fact, this function is declared in
drivers/staging/lustre/lustre/obdclass/cl_io.c, but should be
removed in a header file. thus can be recognized in other file.

So this patch moves the declaration into
drivers/staging/lustre/lustre/include/cl_object.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 2 ++
 drivers/staging/lustre/lustre/obdclass/cl_io.c    | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 5e63a27..41e0801 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2254,6 +2254,8 @@ void cl_page_unassume(const struct lu_env *env,
 		      struct cl_io *io, struct cl_page *pg);
 void cl_page_disown(const struct lu_env *env,
 		    struct cl_io *io, struct cl_page *page);
+void cl_page_disown0(const struct lu_env *env,
+		     struct cl_io *io, struct cl_page *pg);
 int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io);
 
 /** @} ownership */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 4516fff..6643e78 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -936,8 +936,6 @@ void cl_page_list_splice(struct cl_page_list *list, struct cl_page_list *head)
 }
 EXPORT_SYMBOL(cl_page_list_splice);
 
-void cl_page_disown0(const struct lu_env *env,
-		     struct cl_io *io, struct cl_page *pg);
 
 /**
  * Disowns pages in a queue.
-- 
2.7.4
