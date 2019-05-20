From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:44 -0400
Subject: [lustre-devel] [PATCH v2 02/29] lustre: llite: fix error in
 vvp_pgcache seqfile.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

The ->next function should increment the 'pos', but it doesn't.
This oversight causes the WARN_ON to fire.
Core seq_file code tries to handle this error, but it is
best not to make it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/llite/vvp_dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index c10ca6e..96262a1 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -565,6 +565,7 @@ static void *vvp_pgcache_next(struct seq_file *f, void *v, loff_t *pos)
 
 	WARN_ON(*pos != priv->vsp_prev_pos);
 
+	(*pos)++;
 	priv->vsp_prev_pos = *pos;
 	return vvp_pgcache_next_page(priv);
 }
-- 
1.8.3.1
