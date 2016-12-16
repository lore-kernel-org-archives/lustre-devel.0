From: Joe Perches <joe@perches.com>
Date: Fri, 16 Dec 2016 08:05:53 -0800
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
In-Reply-To: <1481898571-16842-1-git-send-email-khan.tabrez21@gmail.com>
References: <1481898571-16842-1-git-send-email-khan.tabrez21@gmail.com>
Message-ID: <1481904353.29291.87.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tabrez khan <khan.tabrez21@gmail.com>, andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Fri, 2016-12-16 at 19:59 +0530, Tabrez khan wrote:
> Remove unnecessary braces {} for single while statement.

Your patch is fine Tabrez, but to the lustre folk:

> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
[]
> @@ -1371,9 +1371,9 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
 
 	/* wait until cl_sync_io_note() has done wakeup */
-	while (unlikely(atomic_read(&anchor->csi_barrier) != 0)) {
+	while (unlikely(atomic_read(&anchor->csi_barrier) != 0))
 		cpu_relax();
-	}
+

What if the wakeup never occurs/succeeds?
Should there be a timeout?
