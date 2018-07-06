From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 6 Jul 2018 17:09:40 +0000
Subject: [lustre-devel] [PATCH v3 04/13] lustre: libcfs: fix
 cfs_print_to_console()
In-Reply-To: <alpine.LFD.2.21.1807060034020.12665@casper.infradead.org>
References: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
 <1530128322-32535-5-git-send-email-jsimmons@infradead.org>
 <FD87D2B8-27A8-45DF-9C7C-BA33CF940C1D@whamcloud.com>
 <alpine.LFD.2.21.1806291716050.26339@casper.infradead.org>
 <87h8li2wz7.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1807060034020.12665@casper.infradead.org>
Message-ID: <1C8DA303-7F46-4E26-9B13-42A3F491EB5B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 5, 2018, at 17:35, James Simmons <jsimmons@infradead.org> wrote:
> 
>>>>> void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
>>>>> 			  const char *buf, int len, const char *file,
>>>>> 			  const char *fn)
>>>>> {
>>>>> +	char *prefix = "Lustre";
>>>>> +
>>>>> +	if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
>>>>> +		prefix = "LNet";
>>>>> 
>>>>> -	if (mask & D_EMERG) {
>>>>> -		prefix = dbghdr_to_err_string(hdr);
>>>>> -		ptype = KERN_EMERG;
>>>>> +	if (mask & (D_CONSOLE | libcfs_printk)) {
>>>> 
>>>> This check is broken.  The default value of libcfs_printk (the mask
>>>> that controls which messages should be printed to the console, and
>>>> which ones should only be logged into the internal buffer) is:
>>>> 
>>>>    #define D_CANTMASK (D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
>>>> 
>>>> so that means virtually every console message will be printed with
>>>> pr_info() because this is matched first, instead of pr_emerg() or
>>>> pr_err() below.
>>>> 
>>>> That is why the previous code was matching D_EMERG and D_ERROR first,
>>>> then D_WARNING, and (D_CONSOLE | libcfs_printk) at the end.
>>> 
>>> 
>> 
>> The original code would *always* print something.
>> This code looks like it might not (e.g. for mask == 0).
> 
> Is that correct behavior? A mask of zero means don't do anything.
> Also if you look at the original in the OpenSFS branch you can see
> if mask was to be 0 then ptype would be NULl :-(
> 
> Note a D_CANT_MASK prevents some fields in the mask from being disabled.

Typically, users will set "lctl set_param debug=0" to disable debugging
messages for performance, but we still want critical error messages to
be printed to the console, so D_CANT_MASK is always checked for messages
to be printed to the console.

>> What is "D_CONSOLE" suppose to mean?  It seems to me "make the messages
>> less verbose" and it isn't clear to me that what is called "D_CONSOLE".
> 
> It means two things. If by itself then it means use pr_info. If it is one
> field in the mask then it means less detail. Confusing no :-( That is my
> understanding of it. Maybe someone else can clarify if I'm wrong.

The D_CONSOLE mask is used for "pretty" messages on the console, that will
not print out the file/function/line/timestamp and other debugging fields.
The D_CONSOLE flag doesn't necessarily mean "more" or "less" information,
but is intended more for "ease of understanding".

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180706/7b8454f0/attachment.sig>
