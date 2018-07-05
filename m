From: James Simmons <jsimmons@infradead.org>
Date: Fri, 6 Jul 2018 00:35:26 +0100 (BST)
Subject: [lustre-devel] [PATCH v3 04/13] lustre: libcfs: fix
 cfs_print_to_console()
In-Reply-To: <87h8li2wz7.fsf@notabene.neil.brown.name>
References: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
 <1530128322-32535-5-git-send-email-jsimmons@infradead.org>
 <FD87D2B8-27A8-45DF-9C7C-BA33CF940C1D@whamcloud.com>
 <alpine.LFD.2.21.1806291716050.26339@casper.infradead.org>
 <87h8li2wz7.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1807060034020.12665@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> > The original code for cfs_print_to_console() used printk() and
> >> > used tricks to select which printk level to use. Later a cleanup
> >> > patch landed the just converted printk directly to pr_info which
> >> > is not exactly correct. Instead of converting back to printk lets
> >> > move everything to pr_* type functions which simplify the code.
> >> > This allows us to fold both dbghdr_to_err_string() and the
> >> > function dbghdr_to_info_string() into cfs_print_to_console().
> >> > 
> >> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> > ---
> >> > .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 55 ++++++----------------
> >> > 1 file changed, 14 insertions(+), 41 deletions(-)
> >> > 
> >> > diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> >> > index 3af7722..c1747c4 100644
> >> > --- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> >> > +++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> >> > @@ -140,54 +140,27 @@ enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
> >> > void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
> >> > 			  const char *buf, int len, const char *file,
> >> > 			  const char *fn)
> >> > {
> >> > +	char *prefix = "Lustre";
> >> > +
> >> > +	if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
> >> > +		prefix = "LNet";
> >> > 
> >> > -	if (mask & D_EMERG) {
> >> > -		prefix = dbghdr_to_err_string(hdr);
> >> > -		ptype = KERN_EMERG;
> >> > +	if (mask & (D_CONSOLE | libcfs_printk)) {
> >> 
> >> This check is broken.  The default value of libcfs_printk (the mask
> >> that controls which messages should be printed to the console, and
> >> which ones should only be logged into the internal buffer) is:
> >> 
> >>     #define D_CANTMASK (D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
> >> 
> >> so that means virtually every console message will be printed with
> >> pr_info() because this is matched first, instead of pr_emerg() or
> >> pr_err() below.
> >> 
> >> That is why the previous code was matching D_EMERG and D_ERROR first,
> >> then D_WARNING, and (D_CONSOLE | libcfs_printk) at the end.
> >
> > So to do this right we need:
> >
> > static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
> >                                  const char *buf, int len, const char 
> > *file,
> >                                  const char *fn)
> > {
> >         char *prefix = "Lustre";
> >
> >         if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
> >                 prefix = "LNet";
> >
> >         if (mask & D_CONSOLE) {
> >                 if (mask & D_EMERG) {
> >                         pr_emerg("%sError: %.*s", prefix, len, buf);
> >                 } else if (mask & D_ERROR) {
> >                         pr_err("%sError: %.*s", prefix, len, buf);
> >                 } else if (mask & D_WARNING) {
> >                         pr_warn("%s: %.*s", prefix, len, buf);
> >                 } else if (mask & libcfs_printk) {
> >                         pr_info("%s: %.*s", prefix, len, buf);
> >                 }
> >         } else {
> >                 if (mask & D_EMERG) {
> >                         pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
> >                                  hdr->ph_pid, hdr->ph_extern_pid, file,
> >                                  hdr->ph_line_num, fn, len, buf);
> >                 } else if (mask & D_ERROR) {
> >                         pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
> >                                hdr->ph_pid, hdr->ph_extern_pid, file,
> >                                hdr->ph_line_num, fn, len, buf);
> >                 } else if (mask & D_WARNING) {
> >                         pr_warn("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
> >                                 hdr->ph_pid, hdr->ph_extern_pid, file,
> >                                 hdr->ph_line_num, fn, len, buf);
> >                 } else if (mask & libcfs_printk) {
> >                         pr_info("%s: %.*s", prefix, len, buf);
> >                 }
> >         }
> > }
> 
> That doesn't look right either.
> The original code would *always* print something.
> This code looks like it might not (e.g. for mask == 0).

Is that correct behavior? A mask of zero means don't do anything.
Also if you look at the original in the OpenSFS branch you can see
if mask was to be 0 then ptype would be NULl :-( 

Note a D_CANT_MASK prevents some fields in the mask from being disabled.

> What is "D_CONSOLE" suppose to mean?  It seems to me "make the messages
> less verbose" and it isn't clear to me that what is called "D_CONSOLE".

It means two things. If by itself then it means use pr_info. If it is one
field in the mask then it means less detail. Confusing no :-( That is my
understanding of it. Maybe someone else can clarify if I'm wrong.
