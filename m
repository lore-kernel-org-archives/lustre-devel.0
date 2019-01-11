From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 11 Jan 2019 03:54:23 +0000
Subject: [lustre-devel] [PATCH 26/29] lustre: osc_cache: simplify
 osc_page_gang_lookup()
In-Reply-To: <87a7k8gfr7.fsf@notabene.neil.brown.name>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504269.26726.8061168646539306509.stgit@noble>
 <AECE9036-4F2A-4330-A8AD-3105A3D4014C@whamcloud.com>
 <87a7k8gfr7.fsf@notabene.neil.brown.name>
Message-ID: <5E69C433-834D-48CF-BAE3-0F9D8F314D38@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 10, 2019, at 18:11, NeilBrown <neilb@suse.com> wrote:
> :
>> 
>> However, looking into the osc_page_gang_lookup() code more closely, I
>> see "end_of_region" would already be set in this case (it is just at
>> the start of the context in the above patch hunk) so CLP_GANG_RESCHED
>> should never be set in that case.  So it looks OK.
> 
> Oh good :-)
> Thanks.
> I love when a review includes what you saw as well as the "Reviewed-by".

Sometimes (IMHO) it points out that code "reads" in a misleading manner,
looking like it does one thing, but actually doing something else.  This
is mostly only obvious if you don't already know what the code is doing,
otherwise your own mental picture of the functionality guides you along.
I'm not really working on the CLIO code as it was developed for a project
that wanted to provide WinNT and MacOS code, and replaced the Lustre VFS
IO interface that I'd "grown up with".

>>> +static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
>>> +		     struct osc_page *ops, void *cbdata)
>>> {
>>> 	struct cl_page *page = ops->ops_cl.cpl_page;
>>> 
>>> 	if (cl_page_is_vmlocked(env, page) ||
>>> 	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
>>> 	   )
>> 
>> This is a bit oddly formatted.  I see in our tree it looks like:
>> 
>>        if (cl_page_is_vmlocked(env, page) || PageDirty(page->cp_vmpage) ||
>>            PageWriteback(page->cp_vmpage))
>> 
>> which is more normal.
> 
> It has only been this way in OpenSFS since July this year.

I didn't know that when I was looking at the patch, just that the above
was looking strange with the lone closing parenthesis on the line.

> Commit b44b1ff8c7fc ("LU-10961 ldlm: don't cancel DoM locks before replay")
> made the change without any comment.  I guess we aren't up to that 2.11
> yet :-)

Sure, but I figured if you are changing the formatting anyway you may as
well make it consistent.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
