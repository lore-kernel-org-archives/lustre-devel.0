From: Julia Lawall <julia.lawall@lip6.fr>
Date: Sun, 5 Mar 2017 18:43:32 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] [PATCH 2/5] staging: lustre:
 ptlrpc: Use list_for_each_entry_safe
In-Reply-To: <CALrZqyO2XF80KZoYQiM_zCJe42c_W_AyhJQ7-JBQZsoeYBkK1w@mail.gmail.com>
References: <1488733610-22289-1-git-send-email-singhalsimran0@gmail.com>
	<1488733610-22289-3-git-send-email-singhalsimran0@gmail.com>
	<alpine.DEB.2.20.1703051838110.3052@hadrien>
	<CALrZqyO2XF80KZoYQiM_zCJe42c_W_AyhJQ7-JBQZsoeYBkK1w@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1703051843060.3052@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, Greg KH <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com



On Sun, 5 Mar 2017, SIMRAN SINGHAL wrote:

> On Sun, Mar 5, 2017 at 11:09 PM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> >
> >
> > On Sun, 5 Mar 2017, simran singhal wrote:
> >
> >> Doubly linked lists which are  iterated  using list_empty
> >> and list_entry macros have been replaced with list_for_each_entry_safe
> >> macro.
> >> This makes the iteration simpler and more readable.
> >>
> >> This patch replaces the while loop containing list_empty and list_entry
> >> with list_for_each_entry_safe.
> >>
> >> This was done with Coccinelle.
> >>
> >> @@
> >> expression E1;
> >> identifier I1, I2;
> >> type T;
> >> iterator name list_for_each_entry_safe;
> >> @@
> >>
> >> T *I1;
> >> + T *tmp;
> >> ...
> >> - while (list_empty(&E1) == 0)
> >> + list_for_each_entry_safe (I1, tmp, &E1, I2)
> >> {
> >> ...when != T *I1;
> >> - I1 = list_entry(E1.next, T, I2);
> >> ...
> >> }
> >>
> >> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> >> ---
> >>  drivers/staging/lustre/lustre/ptlrpc/sec_gc.c | 5 ++---
> >>  1 file changed, 2 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> >> index 8ffd000..fe1c0af 100644
> >> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> >> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> >> @@ -98,12 +98,11 @@ void sptlrpc_gc_del_sec(struct ptlrpc_sec *sec)
> >>  static void sec_process_ctx_list(void)
> >>  {
> >>       struct ptlrpc_cli_ctx *ctx;
> >> +     struct ptlrpc_cli_ctx *tmp;
> >
> > Another improvement would be to define both variables at once:
> >
> > T *I1
> > + , *tmp
> >   ;
> >
> This is particulary for this patch or for all the patches of this patch-series.

All, I would guess.  Unless the line gets too long.

julia

>
> > julia
> >
> >>
> >>       spin_lock(&sec_gc_ctx_list_lock);
> >>
> >> -     while (!list_empty(&sec_gc_ctx_list)) {
> >> -             ctx = list_entry(sec_gc_ctx_list.next,
> >> -                              struct ptlrpc_cli_ctx, cc_gc_chain);
> >> +     list_for_each_entry_safe(ctx, tmp, &sec_gc_ctx_list, cc_gc_chain) {
> >>               list_del_init(&ctx->cc_gc_chain);
> >>               spin_unlock(&sec_gc_ctx_list_lock);
> >>
> >> --
> >> 2.7.4
> >>
> >> --
> >> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> >> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> >> To post to this group, send email to outreachy-kernel at googlegroups.com.
> >> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1488733610-22289-3-git-send-email-singhalsimran0%40gmail.com.
> >> For more options, visit https://groups.google.com/d/optout.
> >>
>
