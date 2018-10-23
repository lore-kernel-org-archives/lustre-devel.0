From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Oct 2018 00:07:08 +0100 (BST)
Subject: [lustre-devel] [PATCH 11/28] lustre: llite: use security
 context if it's enabled in the kernel
In-Reply-To: <87k1ma8wxd.fsf@notabene.neil.brown.name>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-12-git-send-email-jsimmons@infradead.org>
 <87pnw8cflq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1810201836580.16676@casper.infradead.org>
 <87k1ma8wxd.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810240006170.25521@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> > diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> >> > index 22b545e..153aa12 100644
> >> > --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> >> > +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> >> > @@ -243,8 +243,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
> >> >  	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
> >> >  		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
> >> >  
> >> > +#ifdef CONFIG_SECURITY
> >> >  	data->ocd_connect_flags2 |= OBD_CONNECT2_FILE_SECCTX;
> >> > -
> >> > +#endif
> >> 
> >> Policy is to avoid #ifdef in .c files where possible.
> >> If we put something like
> >> #ifdef CONFIG_SECURITY
> >>  #define OBD_CONNECT2_FILE_SECURITY (OBD_CONNECT2_FILE_SECCTX)
> >> #else
> >>  #define OBD_CONNECT2_FILE_SECURITY (0)
> >> #endif
> >> 
> >> in a .h file, then use OBD_CONNECT2_FILE_SECURITY both here and in
> >> obd_connect_has_secctx(),
> >> then the latter could would be optimized away by the compiler.  Wouldn't
> >> be a big win I guess as it is only used once in a trivial context.
> >
> > I suggest that we move obd_connect_has_secctx() to llite_internal.h. Also
> > that function should return bool. Besides this create an inline function
> > obd_connect_set_secctx() for llite_internal.h. Will submit a patch for
> > OpenSFS branch. Shall I redo this patch or submit a cleanup later?
> 
> Sounds like a good plan.  Please submit a cleanup.  I'll commit this
> patch as-is (as it isn't exactly "broken", and a resolution has been
> agreed).

New patch is at https://review.whamcloud.com/#/c/33410. Will be coming
to linux client soon.
