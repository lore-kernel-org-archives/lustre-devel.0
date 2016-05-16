From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 16 May 2016 18:35:50 +0000
Subject: [lustre-devel] [PATCH v2] staging/lustre/ptlrpc: Removes
 potential null dereference
In-Reply-To: <alpine.LFD.2.20.1605161912310.9721@casper.infradead.org>
References: <1463408271-18079-1-git-send-email-lidza.louina@oracle.com>
	<573A0A23.2010705@cray.com>
	<alpine.LFD.2.20.1605161912310.9721@casper.infradead.org>
Message-ID: <8AEE9006-6CF8-4BB7-A236-808ACE3AB302@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2016/05/16, 12:16, "James Simmons" <jsimmons@infradead.org> wrote:

>
>> This looks wrong - You return -EINVAL from sptlrpc_pack_user_desc, but then
>> the caller checks "!desc".  Desc will not be null, since you've returned
>> -EINVAL.
>
>Actually 'if (!desc)' is equal to 'if (desc != 0). Yes it can be confusing.

Very confusing indeed. :-)  "if (!desc)" actually means "if (desc == 0)"...

That is the main reason why I don't like those shortcuts since they require
an extra mental step by the reader to determine the logic.  Having the
explicit comparisons like "if (desc == 0)" or "if (desc != 0)" makes the
code more clear, and doesn't make the compiled binary any slower.

>I recommend 'if (desc < 0)' instead to make it clearer what is being 
>tested for.

That would actually fix the problem.  Patrick is correct that the current
patch is broken, since it is either returning zero "if (!desc)" is true,
or zero at the end of the function.  The error is never returned.

Lidza,
to improve this patch further, the function should really use "rc" to hold
the error return instead of "desc", since "rc" is typically used for error
returns, and "desc" is normally a pointer to a bulk descriptor in this code.

Also, as Oleg previously mentioned, please declare "int rc;" inside the
"if (req->rq_pack_udesc)" block instead of at the top of the function,
since it isn't used anywhere else.

Cheers, Andreas

>> - Patrick
>> 
>> On 05/16/2016 09:17 AM, Lidza Louina wrote:
>> > The lustre_msg_buf method could return NULL. Subsequent code didn't
>> > check if it's null before using it. This patch adds two checks.
>> >
>> > Signed-off-by: Lidza Louina <lidza.louina@oracle.com>
>> > ---
>> >   drivers/staging/lustre/lustre/ptlrpc/sec.c       | 2 ++
>> >   drivers/staging/lustre/lustre/ptlrpc/sec_plain.c | 9 +++++++--
>> >   2 files changed, 9 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c
>> > b/drivers/staging/lustre/lustre/ptlrpc/sec.c
>> > index 187fd1d..e6fedc3 100644
>> > --- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
>> > +++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
>> > @@ -2195,6 +2195,8 @@ int sptlrpc_pack_user_desc(struct lustre_msg *msg, int
>> > offset)
>> >    struct ptlrpc_user_desc *pud;
>> >   
>> >   	pud = lustre_msg_buf(msg, offset, 0);
>> > +	if (!pud)
>> > +		return -EINVAL;
>> >   
>> >    pud->pud_uid = from_kuid(&init_user_ns, current_uid());
>> >    pud->pud_gid = from_kgid(&init_user_ns, current_gid());
>> > diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
>> > b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
>> > index 37c9f4c..51741c8 100644
>> > --- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
>> > +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
>> > @@ -542,6 +542,7 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
>> >   {
>> >    __u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
>> >    int alloc_len;
>> > +	int desc;
>> >   
>> >    buflens[PLAIN_PACK_HDR_OFF] = sizeof(struct plain_header);
>> >    buflens[PLAIN_PACK_MSG_OFF] = msgsize;
>> > @@ -574,8 +575,12 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
>> >    lustre_init_msg_v2(req->rq_reqbuf, PLAIN_PACK_SEGMENTS, buflens, NULL);
>> >    req->rq_reqmsg = lustre_msg_buf(req->rq_reqbuf, PLAIN_PACK_MSG_OFF, 0);
>> >   -	if (req->rq_pack_udesc)
>> > -		sptlrpc_pack_user_desc(req->rq_reqbuf, PLAIN_PACK_USER_OFF);
>> > +	if (req->rq_pack_udesc) {
>> > +		desc = sptlrpc_pack_user_desc(req->rq_reqbuf,
>> > +					      PLAIN_PACK_USER_OFF);
>> > +		if (!desc)
>> > +			return desc;
>> > +	}
>> >   
>> >   	return 0;
>> >   }
>> 
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>> 
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Principal Architect
Intel High Performance Data Division
