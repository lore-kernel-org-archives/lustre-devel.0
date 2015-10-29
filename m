From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Thu, 29 Oct 2015 02:26:56 +0200
Subject: [lustre-devel] [RESEND PATCH v2 2/5] staging: lustre: hash.c:
 Replace IS_PO2 by is_power_of_2
In-Reply-To: <20151028064159.GB3649@sudip-pc>
References: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
	<36db1862a6b63ac07f3b1ed3a1f7f39a772399c6.1445967419.git.mahfouz.saif.elyazal@gmail.com>
	<20151028064159.GB3649@sudip-pc>
Message-ID: <20151029002656.GA12848@waves>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 28, 2015 at 12:11:59PM +0530, Sudip Mukherjee wrote:
> On Tue, Oct 27, 2015 at 07:43:34PM +0200, Aya Mahfouz wrote:
> > Replaces IS_PO2 by is_power_of_2. It is more accurate to use
> > is_power_of_2 since it returns 1 for numbers that are powers
> > of 2 only whereas IS_PO2 returns 1 for 0 and numbers that are
> > powers of 2.
> > 
> > Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> > Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> > ---
> > v2:
> >         -changed commit message
> >         -added Andreas Reviewed by tag
> > 
> >  drivers/staging/lustre/lustre/libcfs/hash.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
> > index 6f4c7d4..4b5e79a 100644
> > --- a/drivers/staging/lustre/lustre/libcfs/hash.c
> > +++ b/drivers/staging/lustre/lustre/libcfs/hash.c
> > @@ -109,6 +109,8 @@
> >  
> >  #include "../../include/linux/libcfs/libcfs.h"
> >  #include <linux/seq_file.h>
> > +#include <linux/log2.h>
> > +
> 
> This extra blank line will introduce new checkpatch error of "multiple
> blank lines"
> 
> regards
> sudip
Thanks Sudip! I will handle your comments on the patchset and resend it.

-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
