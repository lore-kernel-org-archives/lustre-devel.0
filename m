From: NeilBrown <neilb@suse.com>
Date: Wed, 02 Aug 2017 13:06:18 +1000
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: llite: handle
 DCACHE_PAR_LOOKUP in ll_dcompare
In-Reply-To: <150164273003.13199.7841976922211510658.stgit@noble>
References: <150164273003.13199.7841976922211510658.stgit@noble>
Message-ID: <150164317820.13199.2285361769402624601.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

ll_dcompare is used in two slightly different contexts.
It is called (from __d_lookup, __d_lookup_rcu, and d_exact_alias)
to compare a name against a dentry that is already in the dcache.
It is also called (from d_alloc_parallel) to compare a name against
a dentry that is not in the dcache yet, but is part of an active
"lookup" or "atomic_open" call.

In the first case we need to avoid matching against "invalid" dentries
as a match implies something about ldlm locks which is not accurate.
In the second case we need to allow matching against "invalid" dentries
as the dentry will always be invalid (set by ll_d_init()) but we still
want to guard against multiple concurrent lookups of the same name.
d_alloc_parallel() will repeat the call to ll_dcompare() after
the lookup has finished, and if the dentry is still invalid, the whole
d_alloc_parallel() process is repeated.  This assures us that it is safe
to report success whenever d_in_lookup().

With this patch, there will never be two threads concurrently in
ll_lookup_nd(), looking up the same name in the same directory.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/dcache.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index d20425fb8cbe..7cfe0babf99e 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -73,6 +73,12 @@ static void ll_release(struct dentry *de)
  * an AST before calling d_revalidate_it().  The dentry still exists (marked
  * INVALID) so d_lookup() matches it, but we have no lock on it (so
  * lock_match() fails) and we spin around real_lookup().
+ *
+ * This race doesn't apply to lookups in d_alloc_parallel(), and for
+ * those we want to ensure that only one dentry with a given name is
+ * in ll_lookup_nd() at a time.  So allow invalid dentries to match
+ * while d_in_lookup().  We will be called again when the lookup
+ * completes, and can give a different answer then.
  */
 static int ll_dcompare(const struct dentry *dentry,
 		       unsigned int len, const char *str,
@@ -92,6 +98,10 @@ static int ll_dcompare(const struct dentry *dentry,
 	if (d_mountpoint((struct dentry *)dentry))
 		return 0;
 
+	/* ensure exclusion against parallel lookup of the same name */
+	if (d_in_lookup((struct dentry*)dentry))
+		return 0;
+
 	if (d_lustre_invalid(dentry))
 		return 1;
 
