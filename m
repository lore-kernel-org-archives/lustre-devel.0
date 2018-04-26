From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 26 Apr 2018 08:58:27 +0300
Subject: [lustre-devel] [PATCH] staging: kernel.h: Prevent macro expantion
 bug in container_of_safe()
Message-ID: <20180426055827.GA18346@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There aren't many users of this so it doesn't cause a problem, but we
obviously want to use "__mptr" here instead of "ptr" to prevent the
parameter from being executed twice.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index b5a8e78c6c75..593fb8d250a2 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -978,7 +978,7 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
 	BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) &&	\
 			 !__same_type(*(ptr), void),			\
 			 "pointer type mismatch in container_of()");	\
-	IS_ERR_OR_NULL(ptr) ? ERR_CAST(ptr) :				\
+	IS_ERR_OR_NULL(__mptr) ? ERR_CAST(__mptr) :			\
 		((type *)(__mptr - offsetof(type, member))); })
 
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
