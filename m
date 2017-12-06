From: Luis de Bethencourt <luisbg@kernel.org>
Date: Wed,  6 Dec 2017 19:17:00 +0000
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: llite: Remove redundant
 else keyword
In-Reply-To: <20171206191700.26532-1-luisbg@kernel.org>
References: <20171206191700.26532-1-luisbg@kernel.org>
Message-ID: <20171206191700.26532-3-luisbg@kernel.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Lai Siyao <lai.siyao@intel.com>, Ernestas Kulik <ernestas.kulik@gmail.com>, Aastha Gupta <aastha.gupta4104@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Luis de Bethencourt <luisbg@kernel.org>

There is no need to use 'else' if in main branch 'return' is present.

Signed-off-by: Luis de Bethencourt <luisbg@kernel.org>
---
 drivers/staging/lustre/lustre/llite/vvp_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index bfae98e82d6f..e7a4778e02e4 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -699,7 +699,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	result = vvp_prep_size(env, obj, io, pos, tot, &exceed);
 	if (result != 0)
 		return result;
-	else if (exceed != 0)
+	if (exceed != 0)
 		goto out;
 
 	LU_OBJECT_HEADER(D_INODE, env, &obj->co_lu,
-- 
2.15.1
