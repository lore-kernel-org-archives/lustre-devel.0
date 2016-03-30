From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:49:07 -0400
Subject: [lustre-devel] [PATCH v2 46/46] staging/lustre: lov_io_init()
	should return error code
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-47-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bobi Jam <bobijam.xu@intel.com>

lov_io_init_empty/release() should returns error code instead of
true on error case.

Fault IO needs to handle restart in the case of accessing HSM released
file

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reviewed-on: http://review.whamcloud.com/17240
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7446
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_mmap.c | 4 ++++
 drivers/staging/lustre/lustre/lov/lov_io.c       | 4 ++--
 drivers/staging/lustre/lustre/obdclass/cl_io.c   | 1 +
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 83d7006..5b4382c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -123,6 +123,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 
 	*env_ret = env;
 
+restart:
 	io = vvp_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
 	LASSERT(io->ci_obj);
@@ -157,6 +158,9 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 	} else {
 		LASSERT(rc < 0);
 		cl_io_fini(env, io);
+		if (io->ci_need_restart)
+			goto restart;
+
 		cl_env_nested_put(nest, env);
 		io = ERR_PTR(rc);
 	}
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index ba79955..4151237 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -916,7 +916,7 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 	}
 
 	io->ci_result = result < 0 ? result : 0;
-	return result != 0;
+	return result;
 }
 
 int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
@@ -959,7 +959,7 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 	}
 
 	io->ci_result = result < 0 ? result : 0;
-	return result != 0;
+	return result;
 }
 
 /** @} lov */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 7655dc4..f4b3178 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -133,6 +133,7 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 	case CIT_WRITE:
 		break;
 	case CIT_FAULT:
+		break;
 	case CIT_FSYNC:
 		LASSERT(!io->ci_need_restart);
 		break;
-- 
2.1.0
