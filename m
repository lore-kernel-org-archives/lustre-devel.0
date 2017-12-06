From: Luis de Bethencourt <luisbg@kernel.org>
Date: Wed,  6 Dec 2017 19:16:59 +0000
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: llite: Remove redundant
 else keyword
In-Reply-To: <20171206191700.26532-1-luisbg@kernel.org>
References: <20171206191700.26532-1-luisbg@kernel.org>
Message-ID: <20171206191700.26532-2-luisbg@kernel.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Lai Siyao <lai.siyao@intel.com>, Ernestas Kulik <ernestas.kulik@gmail.com>, Aastha Gupta <aastha.gupta4104@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Luis de Bethencourt <luisbg@kernel.org>

There is no need to use 'else' if in main branch 'goto' is present.

Signed-off-by: Luis de Bethencourt <luisbg@kernel.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 8666f1e81ade..e84719662edf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -236,7 +236,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				   "An MDT (md %s) is performing recovery, of which this client is not a part. Please wait for recovery to complete, abort, or time out.\n",
 				   md);
 		goto out;
-	} else if (err) {
+	}
+
+	if (err) {
 		CERROR("cannot connect to %s: rc = %d\n", md, err);
 		goto out;
 	}
-- 
2.15.1
