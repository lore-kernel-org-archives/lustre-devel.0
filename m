From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 5 Dec 2017 00:50:25 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: check result of
 register_shrinker
In-Reply-To: <908ca41a-4fba-1f0f-ddc5-c5e5e3fd1142@gmail.com>
References: <20171202184046.4338-1-akaraliou.dev@gmail.com>
 <985AF256-3022-45FB-BFCF-1E2B0F622AA8@intel.com>
 <babc0c09-2384-e277-1c68-e07457c6e5fd@gmail.com>
 <20171204084018.jxfunaapcx36jd6r@mwanda>
 <908ca41a-4fba-1f0f-ddc5-c5e5e3fd1142@gmail.com>
Message-ID: <F9B33034-A299-44F6-A202-9082F482F673@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 4, 2017, at 11:42, Aliaksei Karaliou <akaraliou.dev@gmail.com> wrote:
> 
> On 12/04/2017 11:40 AM, Dan Carpenter wrote:
>> On Sun, Dec 03, 2017 at 07:59:07PM +0300, ak wrote:
>>> Thank you for your extensive comments.
>>> 
>>> I've also thought about adding more protection into unregister_shrinker(),
>>> but not sure how to properly organize the patch set, because there will be
>>> three patches:
>>>     * change in mm/vmscan that adds protection and sanitizer.
>>>     * fixed change for Lustre driver
>>>     * there also two explicit usages of shrinker->nr_deferred in drivers -
>>>        good idea to fix too.
>>> All patches have different lists of maintainers, and second and third depend
>>> on first one. And I don't like to send them separately.
>>> So, I'm going to at least prepend this patch with mm/vmscan one.
>> Fix the style for the Lustre patch and resend.  Then patch
>> unregister_shrinker().  Then remove the checks.
>> 
>> The unregister_shrinker() changes seem like a good idea, but I haven't
>> really looked at it.  It might be more involved than it seems.
>> 
>> regards,
>> dan carpenter
> Thanks for the comments too.
> I'll send patch with accumulated fixes.
>>>  }
>>> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>>> index b938a3f9d50a..9e0256ca2079 100644
>>> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
>>> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>>> @@ -1951,7 +1951,7 @@ int lu_global_init(void)
>>>  	 * inode, one for ea. Unfortunately setting this high value results in
>>>  	 * lu_object/inode cache consuming all the memory.
>>>  	 */
>>> -	register_shrinker(&lu_site_shrinker);
>>> +	result = register_shrinker(&lu_site_shrinker);
>> There should be some error handling if the register fails. 
> Yeah, I think so, but it seems that it is out of scope of this patch.
> The whole negative branch in the mainline kernel looks broken (IMHO).
> In mainline Lustre's git there is a reworked version of upper function obdclass_init(),
> which at least calls lu_global_fini() before exiting `module_init` on further failure,
> but yeah, still lacks proper cleanup inside lu_global_initcall().
> I'll add one more patch in a patch-set so that maintainers may decide what to do with that.

I was looking at the lack of error handling as well, but then I wondered if the module_init() call returns an error, is module_exit() still called, or does the module not load at all in the error case?

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
