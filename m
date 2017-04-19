From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 19 Apr 2017 01:04:52 +0000
Subject: [lustre-devel] [Patch v3 2/2] lustre: CONSTANTS put on right
 side of comparison test
In-Reply-To: <VI1PR0901MB1616B50DC6C192D8E47BF49DA4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
References: <677c0d437ce8d9f27213e408751a1058b5c9e482.1492263580.git.manwatkar@outlook.com>
	<VI1PR0901MB1616B50DC6C192D8E47BF49DA4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
Message-ID: <F6F1175F-2DFB-4C9F-9E70-4278FE18D862@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rishiraj Manwatkar <manwatkar@outlook.com>
Cc: "greg@kroah.com" <greg@kroah.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>

On Apr 15, 2017, at 07:50, Rishiraj Manwatkar <manwatkar@outlook.com> wrote:
> 
> Comparison should have the CONSTANT on the right side of the test

I don't think this change really improves things.  For standalone comparisons I agree
that having the constant on the RHS is best, but here it is like a normal mathematical
expression "X <= type < Y" which I think is reasonable to keep even if checkpatch.pl
complains a bit.

That said, I don't have strong feelings about this and Greg can apply it or not as he
sees fit.  I guess the benefit of applying it is that it stops anyone else from sending
the same patch in the future...

Cheers, Andreas

> Signed-off-by: Rishiraj Manwatkar <manwatkar@outlook.com>
> ---
> v1 -> v2: Added mailing list in cc.
> v2 -> v3: Improved Subject line.
> drivers/staging/lustre/lustre/obdclass/cl_io.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index 0997254..bec112f 100755
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -58,7 +58,7 @@
> 
> static inline int cl_io_type_is_valid(enum cl_io_type type)
> {
> -	return CIT_READ <= type && type < CIT_OP_NR;
> +	return type >= CIT_READ && type < CIT_OP_NR;
> }
> 
> static inline int cl_io_is_loopable(const struct cl_io *io)
> @@ -389,7 +389,7 @@ void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
> 	const struct cl_io_slice *scan;
> 
> 	LASSERT(cl_io_is_loopable(io));
> -	LASSERT(CIS_IT_STARTED <= io->ci_state && io->ci_state < CIS_UNLOCKED);
> +	LASSERT(io->ci_state >= CIS_IT_STARTED && io->ci_state < CIS_UNLOCKED);
> 	LINVRNT(cl_io_invariant(io));
> 
> 	set = &io->ci_lockset;
> -- 
> 2.1.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
