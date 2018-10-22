From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Oct 2018 14:47:26 +1100
Subject: [lustre-devel] [PATCH 11/28] lustre: llite: use security
 context if it's enabled in the kernel
In-Reply-To: <alpine.LFD.2.21.1810201836580.16676@casper.infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-12-git-send-email-jsimmons@infradead.org>
 <87pnw8cflq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1810201836580.16676@casper.infradead.org>
Message-ID: <87k1ma8wxd.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 20 2018, James Simmons wrote:

>> On Sun, Oct 14 2018, James Simmons wrote:
>> 
>> > From: Alex Zhuravlev <bzzz@whamcloud.com>
>> >
>> > if it's disabled, then Lustre stop to work properly (can not create
>> > files, etc)
>> >
>> > Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
>> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9578
>> > Reviewed-on: https://review.whamcloud.com/27364
>> > Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
>> > Reviewed-by: Chris Horn <hornc@cray.com>
>> > Reviewed-by: James Simmons <uja.ornl@yahoo.com>
>> > Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
>> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
>> > Signed-off-by: James Simmons <jsimmons@infradead.org>
>> > ---
>> >  drivers/staging/lustre/lustre/llite/llite_lib.c | 3 ++-
>> >  1 file changed, 2 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
>> > index 22b545e..153aa12 100644
>> > --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
>> > +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
>> > @@ -243,8 +243,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
>> >  	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
>> >  		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
>> >  
>> > +#ifdef CONFIG_SECURITY
>> >  	data->ocd_connect_flags2 |= OBD_CONNECT2_FILE_SECCTX;
>> > -
>> > +#endif
>> 
>> Policy is to avoid #ifdef in .c files where possible.
>> If we put something like
>> #ifdef CONFIG_SECURITY
>>  #define OBD_CONNECT2_FILE_SECURITY (OBD_CONNECT2_FILE_SECCTX)
>> #else
>>  #define OBD_CONNECT2_FILE_SECURITY (0)
>> #endif
>> 
>> in a .h file, then use OBD_CONNECT2_FILE_SECURITY both here and in
>> obd_connect_has_secctx(),
>> then the latter could would be optimized away by the compiler.  Wouldn't
>> be a big win I guess as it is only used once in a trivial context.
>
> I suggest that we move obd_connect_has_secctx() to llite_internal.h. Also
> that function should return bool. Besides this create an inline function
> obd_connect_set_secctx() for llite_internal.h. Will submit a patch for
> OpenSFS branch. Shall I redo this patch or submit a cleanup later?

Sounds like a good plan.  Please submit a cleanup.  I'll commit this
patch as-is (as it isn't exactly "broken", and a resolution has been
agreed).

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181022/ec00008e/attachment.sig>
