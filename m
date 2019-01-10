From: NeilBrown <neilb@suse.com>
Date: Thu, 10 Jan 2019 16:04:19 +1100
Subject: [lustre-devel] [PATCH 02/29] lustre: osc_cache: use
 assert_spin_locked()
In-Reply-To: <87942812-3A47-49E3-B7C9-75DC2D426305@whamcloud.com>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504098.26726.7180667249484886220.stgit@noble>
 <87942812-3A47-49E3-B7C9-75DC2D426305@whamcloud.com>
Message-ID: <8736q1hzn0.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 10 2019, Andreas Dilger wrote:

> On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
>> 
>> assert_spin_locked() is preferred to
>> spin_is_locked() for affirming that a
>> spinlock is locked.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> We used to have an LASSERT_SPIN_LOCKED() macro, but it was removed a few
> years ago.  It is nice to get better checking in the kernel.
>
> One question inline below:
>
>> ---
>> drivers/staging/lustre/lustre/osc/osc_cache.c      |   29 +++++++++-----------
>> .../staging/lustre/lustre/osc/osc_cl_internal.h    |   15 +---------
>> 2 files changed, 15 insertions(+), 29 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> index fbf16547003d..1ce9f673f1bf 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> @@ -181,10 +181,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
>> 	size_t page_count;
>> 	int rc = 0;
>> 
>> -	if (!osc_object_is_locked(obj)) {
>> -		rc = 9;
>> -		goto out;
>> -	}
>> +	assert_osc_object_is_locked(obj);
>
> Is this actually a fatal error?  It looks like if the object is not
> locked then the checking isn't consistent and could just be skipped?

The assert is fatal (-> BUG_ON()).

>
> There is a macro that lends credence to this:
>
> #define sanity_check_nolock(ext) \
>         osc_extent_sanity_check0(ext, __func__, __LINE__)
>
> #define sanity_check(ext) ({                                   \
>         int __res;                                             \
>         osc_object_lock((ext)->oe_obj);                        \
>         __res = sanity_check_nolock(ext);                      \
>         osc_object_unlock((ext)->oe_obj);                      \
>         __res;                                                 \
> })
>
> However, reading deeper into the code sanity_check_nolock() looks
> like is only ever called when the object is already locked, so
> indeed it does seem like a valid change that should be described
> in the commit message like:

Agreed.

>
>     __osc_extent_sanity_check() is only ever called with obj
>     already locked, so change the check into an assertion.

Good suggestion - I've added this text.

>
> It might also be an improvement to rename sanity_check{,_nolock}()
> to osc_extent_sanity_check() and osc_extent_sanity_check_nolock(),
> and use __osc_extent_sanity_check() instead of ...0() (which is not
> standard)?  I was going to suggest making sanity_check() an inline
> function, but that would break the __func__ and __LINE__ expansion
> and isn't onerous.

That renaming makes sense - I'll add it as another patch.

>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190110/eb293c70/attachment.sig>
