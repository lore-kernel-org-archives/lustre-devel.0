From: James Simmons <jsimmons@infradead.org>
Date: Mon, 29 Oct 2018 03:42:10 +0000 (GMT)
Subject: [lustre-devel] [PATCH 12/28] lustre: ptlrpc: do not wakeup
 every second
In-Reply-To: <87pnvt325a.fsf@notabene.neil.brown.name>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-13-git-send-email-jsimmons@infradead.org>
 <87va5l39hl.fsf@notabene.neil.brown.name>
 <MWHPR11MB148802D76D49E06343462260CBF30@MWHPR11MB1488.namprd11.prod.outlook.com>
 <87pnvt325a.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810290338580.6811@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Neil,
> >
> > Does your statement imply this would spin?  It definitely doesn?t just
> > spin (that behavior in a main ?wait for work? spot of a (depending on
> > settings) ~per-CPU daemon would render systems unusable and this patch
> > has been in testing for a while).  So what is the detailed behavior of
> > a ?timeout that expires immediately??
> 
> Hi Patrick,
>  it definitely spins for me.

Ah that is where the high cpu load is coming from.
 
>  I should have clarified that the SFS patch
> 
>    e81847bd0651 LU-9660 ptlrpc: do not wakeup every second
> 
>  is correct, as __l_wait_event() treats a timeout value of 0 as meaning an
>  indefinite timeout.
>  The error was in the conversion to wait_event_idle_timeout().  The
>  various wait_event*timeout() functions treat 0 as 1 less than 1.
>  If you want to not have a timeout, you need to not use the *_timeout()
>  version.
>  If a timeout is undesirable rather than fatal, then
>  MAX_SCHEDULE_TIMEOUT can be used.  In this case, that seemed best.

I missed that in the conversion. Now that I know that the mapping I will
do the future server code port correctly ;-)

> > - Patrick
> >
> >
> > ________________________________
> > From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
> > Sent: Sunday, October 28, 2018 7:03:02 PM
> > To: James Simmons; Andreas Dilger; Oleg Drokin
> > Cc: Lustre Development List
> > Subject: Re: [lustre-devel] [PATCH 12/28] lustre: ptlrpc: do not wakeup every second
> >
> > On Sun, Oct 14 2018, James Simmons wrote:
> >
> >> From: Alex Zhuravlev <bzzz@whamcloud.com>
> >>
> >> Even if there are no RPC requests on the set, there is no need to
> >> wake up every second. The thread is woken up when a request is added
> >> to the set or when the STOP bit is set, so it is sufficient to only
> >> wake up when there are requests on the set to worry about.
> >>
> >> Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
> >> WC-bug-id: https://jira.whamcloud.com/browse/LU-9660
> >> Reviewed-on: https://review.whamcloud.com/28776
> >> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> >> Reviewed-by: Patrick Farrell <paf@cray.com>
> >> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> >> Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> ---
> >>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> >> index c201a88..5b4977b 100644
> >> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> >> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> >> @@ -371,7 +371,7 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
> >>                }
> >>        }
> >>
> >> -     return rc;
> >> +     return rc || test_bit(LIOD_STOP, &pc->pc_flags);
> >>  }
> >>
> >>  /**
> >> @@ -441,7 +441,7 @@ static int ptlrpcd(void *arg)
> >>                lu_context_enter(env.le_ses);
> >>                if (wait_event_idle_timeout(set->set_waitq,
> >>                                            ptlrpcd_check(&env, pc),
> >> -                                         (timeout ? timeout : 1) * HZ) == 0)
> >> +                                         timeout * HZ) == 0)
> >>                        ptlrpc_expired_set(set);
> >
> > This is incorrect.
> > A timeout of zero means the timeout happens after zero jiffies
> > (immediately), it doesn't mean there is no timeout.
> > If we want a "timeout" of zero to mean "Wait forever", we need something
> > like:
> >
> >   wait_event_idle_timeout(.....,
> >                           timeout ? (timeout * HZ) : MAX_SCHEDULE_TIMEOUT) == 0
> >
> > I've updated the patch accordingly.
> >
> > Thanks,
> > NeilBrown
> >
> >>
> >>                lu_context_exit(&env.le_ctx);
> >> --
> >> 1.8.3.1
> 
