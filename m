From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 23 Jun 2015 08:25:05 +0000
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: fid: Use !x to
 check for kzalloc failure
In-Reply-To: <1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
Message-ID: <D1AECA61.F8DE5%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/06/20, 10:58 AM, "Julia Lawall" <Julia.Lawall@lip6.fr> wrote:

>!x is more normal for kzalloc failure in the kernel.

While "!x" might be more normal for kzalloc(), I don't see that as an
improvement over explicitly checking against NULL, which is what kzalloc()
and other memory-allocating functions return on error.

I've found in the past that developers can introduce bugs when they treat
return values as boolean when they really aren't.  I'd prefer that the
code is kept with explicit comparisons against NULL, as it is today.
Most of the cases that are now using "!x" are from your previous patches.

Cheers, Andreas

>Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
>---
> drivers/staging/lustre/lustre/fid/fid_request.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff -u -p a/drivers/staging/lustre/lustre/fid/fid_request.c
>b/drivers/staging/lustre/lustre/fid/fid_request.c
>--- a/drivers/staging/lustre/lustre/fid/fid_request.c
>+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
>@@ -498,11 +498,11 @@ int client_fid_init(struct obd_device *o
> 	int rc;
> 
> 	cli->cl_seq = kzalloc(sizeof(*cli->cl_seq), GFP_NOFS);
>-	if (cli->cl_seq == NULL)
>+	if (!cli->cl_seq)
> 		return -ENOMEM;
> 
> 	prefix = kzalloc(MAX_OBD_NAME + 5, GFP_NOFS);
>-	if (prefix == NULL) {
>+	if (!prefix) {
> 		rc = -ENOMEM;
> 		goto out_free_seq;
> 	}
>
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
