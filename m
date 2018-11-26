From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 26 Nov 2018 20:53:17 +0000
Subject: [lustre-devel] Do we need LOOKUP_CONTINUE in
 ll_revalidate_dentry()
In-Reply-To: <alpine.LFD.2.21.1811261950090.25858@casper.infradead.org>
References: <alpine.LFD.2.21.1811260404040.32255@casper.infradead.org>
 <87pnusqozl.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811261950090.25858@casper.infradead.org>
Message-ID: <F28BADFF-E5B5-4E3F-81B7-46B33A951C64@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 26, 2018, at 12:51, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
>> On Mon, Nov 26 2018, James Simmons wrote:
>> 
>>> Doing a compare to the OpenSFS branch I noticed this difference:
>>> 
>>> diff --git a/drivers/staging/lustre/lustre/llite/dcache.c 
>>> b/drivers/staging/lustre/lustre/llite/dcache.c
>>> index 11b82c63..6ee0ec9 100644
>>> --- a/drivers/staging/lustre/lustre/llite/dcache.c
>>> +++ b/drivers/staging/lustre/lustre/llite/dcache.c
>>> @@ -254,7 +254,7 @@ static int ll_revalidate_dentry(struct dentry *dentry,
>>>         * to this dentry, then its lock has not been revoked and the
>>>         * path component is valid.
>>>         */
>>> -       if (lookup_flags & LOOKUP_PARENT)
>>> +       if (lookup_flags & (LOOKUP_CONTINUE | LOOKUP_PARENT))
>>>                return 1;
>>> 
>>>        /* Symlink - always valid as long as the dentry was found */
>>> 
>>> Is that needed for newer kernels?
>> 
>> LOOKUP_CONTINUE disappeared in 2011
>> 
>> Commit: 49084c3bb205 ("kill LOOKUP_CONTINUE")
>> 
>> LOOKUP_PARENT is the new LOOKUP_CONTINUE.
> 
> So its really
> 
> if (lookup_flags & (LOOKUP_PARENT | LOOKUP_PARENT))
> 	return  1;
> 
> in OpenSFS branch :-/

/* Kernel 3.1 kills LOOKUP_CONTINUE, LOOKUP_PARENT is equivalent to it.
 * seem kernel commit 49084c3bb2055c401f3493c13edae14d49128ca0 */
#ifndef LOOKUP_CONTINUE
#define LOOKUP_CONTINUE LOOKUP_PARENT
#endif

That commit is in the 3.0 release, so LOOKUP_CONTINUE is needed for older
kernels.  Having the same value specified twice for newer kernels is not harmful, but this isn't needed for the upstream client.

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
