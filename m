From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 15 Dec 2016 08:07:46 -0800
Subject: [lustre-devel] [PATCH] staging : osc : Remove braces from
	single-line body
In-Reply-To: <CA+JOspqNxVHU-xJcHhdbG5JvGYp=N1Rcm9hx9c2a1z4z42ffCw@mail.gmail.com>
References: <1481765632-29876-1-git-send-email-khan.tabrez21@gmail.com>
	<20161215013834.GA7055@kroah.com>
	<CA+JOspqNxVHU-xJcHhdbG5JvGYp=N1Rcm9hx9c2a1z4z42ffCw@mail.gmail.com>
Message-ID: <20161215160746.GB16790@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tabrez Khan <khan.tabrez21@gmail.com>
Cc: devel@driverdev.osuosl.org, andreas.dilger@intel.com, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Thu, Dec 15, 2016 at 08:09:16PM +0530, Tabrez Khan wrote:
> On Thu, Dec 15, 2016 at 7:08 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Thu, Dec 15, 2016 at 07:03:52AM +0530, Tabrez khan wrote:
> >> Remove unnecessary braces {} for single if statement block.
> >> This warning is found using checkpatch.pl.
> >>
> >> Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
> >> ---
> >>  drivers/staging/lustre/lustre/osc/osc_cache.c | 4 +---
> >>  1 file changed, 1 insertion(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> >> index 4bbe219..5ded31a 100644
> >> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> >> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> >> @@ -1420,10 +1420,8 @@ static void osc_release_write_grant(struct client_obd *cli,
> >>                                   struct brw_page *pga)
> >>  {
> >>       assert_spin_locked(&cli->cl_loi_list_lock);
> >> -     if (!(pga->flag & OBD_BRW_FROM_GRANT)) {
> >> +     if (!(pga->flag & OBD_BRW_FROM_GRANT))
> >>               return;
> >> -     }
> >> -
> >
> > Why did you also delete the blank line?
> 
> Because to keep the kernel coding style as close as possible and after
> deleting brace it leads to extra empty line so i delete it.
> Please guide if done something wrong.

The extra blank line is fine, please leave it, it makes the code more
readable, don't you think?
