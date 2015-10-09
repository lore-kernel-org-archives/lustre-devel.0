From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 09 Oct 2015 16:43:39 -0700
Subject: [lustre-devel] lprocfs Helper Issues
In-Reply-To: <974262C966B9F640899A48EB96313E9A2CC1C9@PRDEXMBX-08.the-lab.llnl.gov>
References: <974262C966B9F640899A48EB96313E9A2C9DAA@PRDEXMBX-08.the-lab.llnl.gov>	<560B4800.6070103@llnl.gov>	<974262C966B9F640899A48EB96313E9A2CA46B@PRDEXMBX-08.the-lab.llnl.gov>	<560C7F1A.30004@llnl.gov>
	<560F2174.2040003@llnl.gov>	<FF7D8D24-EC8A-4073-AEA7-DDEC419B2999@intel.com>	<5612F106.1070601@llnl.gov>,
	<D2385771.10F34A%andreas.dilger@intel.com>
	<974262C966B9F640899A48EB96313E9A2CC1C9@PRDEXMBX-08.the-lab.llnl.gov>
Message-ID: <5618512B.7000605@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All of presented functions reject negative numbers, and some proc files 
need to accept negative numbers.  So that is an issue.  I still 
recommend making the helper function return a signed number and making 
it the calling function's responsibility to handle negative values as 
appropriate.

Yes, I think that all four of these functions can be replaced:

   lprocfs_write_helper
   lprocfs_write_frac_helper
   lprocfs_write_u64_helper
   lprocfs_write_frac_u64_helper

My recommendation for a prototype is now:

int str_to_s64(char *buffer, unsigned long count, __s64 *val, char units);

It is not clear to me that the enum adds enough value to be worth while.

Chris

On 10/09/2015 10:27 AM, Di Natale, Giuseppe wrote:
> Greetings,
>
> I've implemented a working version of the new helper, but I need an opinion on what the interface should ultimately be. I'm trying to find a good middle ground based on everyone's suggestions. So below is a list of options with descriptions for how the functionality is exposed outside of lprocfs.
>
> This enum is used as a way of defining which "units" are supported or are standard. The enum is used to lookup multipliers for these units. Alignment could also be the incorrect term for what it is achieving. I'm attempting to avoid the potential confusion around units and multiplier.
> typedef enum {
> 	ALIGN_NONE = 0,
> 	ALIGN_BYTE = 1,
> 	...
> 	ALIGN_PAGE_CACHE_MB = 7,
> 	ALIGN_COUNT
> } alignment;
>
> int lprocfs_str_to_u64(const char __user *buffer, unsigned long count, __u64 *val)
>
> lprocfs_str_to_u64 expects at most a single decimal and only numeric characters in the string buffer. It will return an error code if string represents a negative number, string is invalid, or value represented by string wraps.
>
> int lprocfs_str_to_u64_aligned(const char __user *buffer, unsigned long count, __u64 *val, alignment align)
>
> lprocfs_str_to_u64_aligned expects at most a single decimal and only numeric characters in the string buffer. It will return an error code if the string represents a negative number, is invalid, or the final value wraps. The align argument is used to designate what unit (ultimately becomes a multiplier) should be applied to the number represented by the string.
>
> int lprocfs_str_to_u64_mult(const char __user *buffer, unsigned long count, __u64 *val, __u64 mult)
>
> lprocfs_str_to_u64_mult expects at most a single decimal and only numeric characters in the string buffer. It will return an error code if the string represents a negative number, is invalid, or the final value wraps. The mult argument is the multiplier to apply to the value represented by the string. This could be included to provide more flexibility instead of strictly allowing certain multipliers.
>
> int lprocfs_str_with_units_to_u64(const char __user *buffer, unsigned long count, __u64 *val, alignment default_align)
>
> lprocfs_str_with_units_to_u64 expects at most a single decimal, numeric characters, and only one non numeric character which must be at the end of the string. It will return an error code if the string represents a negative number, is invalid, contains an invalid unit, or the final value wraps. The default_align argument is the default unit to apply to the value represented by the string if it does not contain a char representing a unit. This could be included to provide more flexibility instead of strictly allowing certain multipliers.
>
>
> So the question is, would all of these be suitable or perhaps only some? I was leaning towards keeping the interface as flexible as possible. lprocfs_str_to_u64_aligned could be removed and a utility function to obtain the appropriate multiplier for a given unit can be used in conjunction with lprocfs_str_to_u64_mult for example. Is there really a need to consider other multipliers outside of the widely used units?
>
> Also, I've begun wondering why lprocfs_write_helper exists and if I should incorporate it in the refactor. Currently, it is similar to the u64 helper with the exception that the value returned is an int. It appears that most callers to the function eventually check if the int value is positive before proceeding to do work. Would it be unwise to replace all those calls to lprocfs_write_helper with one of the u64 helpers and then attempt to refactor/handle the areas in the codebase that expected an int? I feel it may be messy and, in some cases, difficult to remove the use of an integer in some of the calling functions, but is that really a good reason to implement a lprocfs_str_to_int function?
>
> Thanks,
> Giuseppe Di Natale
> ________________________________________
> From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf of Dilger, Andreas [andreas.dilger at intel.com]
> Sent: Monday, October 05, 2015 9:23 PM
> To: Morrone, Chris
> Cc: lustre-devel at lists.lustre.org
> Subject: Re: [lustre-devel] lprocfs Helper Issues
>
> On 2015/10/05, 3:52 PM, "Christopher J. Morrone" <morrone2@llnl.gov> wrote:
>
>> I don't recall any proc files that accepted pages.
>
> max_pages_per_rpc is probably the main one.
>
>
>> I certainly remember callers sending a multiplier that resulted in the
>> string parsing function doing the conversion to pages.  But those very
>> callers are the ones that break when the string specifies a unit.  The
>> code authors failed to realize that, so this would let us avoid that
>> mistake in the future.
>
> I'm not against fixing the bugs and improving the interface.
>
>> I don't think it is terribly onerous to do the bit shifting in the
>> caller instead of passing the multiplier as parameter to the string
>> conversion function.  I think it might even make the code a little more
>> readable.
>
> The question is - how to have the caller do the conversion?  If each
> caller handles the units conversion (KMGTP) then that duplicates a lot of
> code.  If the caller doesn't handle the unit conversion, how does it know
> whether the result needs to be shifted or not (i.e. was the input value in
> units of pages or MB)?
>
> I'm not against doing it as you propose, if it is an improvement over the
> current code.
>
> Cheers, Andreas
>
>>
>> Chris
>>
>> On 10/03/2015 02:54 AM, Dilger, Andreas wrote:
>>> What if the default unit is in pages?  I don't think there is a common
>>> suffix for pages.
>>>
>>> Cheers, Andreas
>>>
>>>> On Oct 2, 2015, at 18:29, Christopher J. Morrone <morrone2@llnl.gov>
>>>> wrote:
>>>>
>>>> It also occurs to me that we shouldn't really have a an integer
>>>> multiplier parameter in the function definition.  There should just be
>>>> a simple "char default_units" parameter.  The caller can specify which
>>>> character is the default, and then there is no possibility of the
>>>> multiplier being misused the way it currently is.
>>>>
>>>> Chris
>>>>
>>>>> On 09/30/2015 05:32 PM, Christopher J. Morrone wrote:
>>>>>> On 09/30/2015 12:46 PM, Di Natale, Giuseppe wrote:
>>>>>> I looked around to see where the helpers are used. It looks to me
>>>>>> that
>>>>>> they are always used in proc related functions. I agree with the
>>>>>> issues you mentioned at the top of the email as well.
>>>>>
>>>>> Yes, but I meant to say we need to consider future use.  Largely
>>>>> motivated by the effort to upstream the Lustre client into Linux, the
>>>>> /proc interfaces are slowly going away.  So I was just suggesting that
>>>>> we should check that these functions will still be used by the new
>>>>> debugfs/sysfs/whatever interfaces in the future.  Nothing really
>>>>> needed
>>>>> to consider though; they are generic enough to still be used well into
>>>>> the future.
>>>>>
>>>>> With that in mind, we should probably change the function names even
>>>>> further.  Instead of naming the functions after the current primary
>>>>> callers, we should name them according to what they do.  Perhaps
>>>>> something along the lines of: str_to_u64().
>>>>>
>>>>> That is just good naming practice anyway.  When you are reading code
>>>>> and
>>>>> you hit a call to a function named "helper", that doesn't give you
>>>>> much
>>>>> of a clue as to what it does.
>>>>>
>>>>>> It also appears that the multiplier is never negative, so making it
>>>>>> an
>>>>>> unsigned int seems like the right way to go. I also noticed that
>>>>>> lprocfs_write_frac_helper calls are always followed by a check if the
>>>>>> value produced is greater than 0 and if not an error is thrown. This
>>>>>> implies the signed version may not be necessary (and that maybe the
>>>>>> unsigned helper should error with strings representing negative
>>>>>> numbers?).
>>>>>>
>>>>>> Also, I think both the unsigned and signed methods parse the numeric
>>>>>> portion of the string in a very similar fashion. At the very least,
>>>>>> they appear to attempt to do the same thing. That is the portion I
>>>>>> was
>>>>>> going to consolidate down.
>>>>>
>>>>> Yes, the _u64_ functions almost certainly started out as a
>>>>> cut-and-paste
>>>>> of the other functions.
>>>>>
>>>>>> You didn't comment on detecting overflow/underflow/wrapping. I still
>>>>>> think those are a valid concern as well.
>>>>>
>>>>> I agree.  It is completely reasonable to add those checks during the
>>>>> refactoring.
>>>>>
>>>>>> Giuseppe
>>>>>> ________________________________________
>>>>>> From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf
>>>>>> of Christopher J. Morrone [morrone2 at llnl.gov]
>>>>>> Sent: Tuesday, September 29, 2015 7:25 PM
>>>>>> To: lustre-devel at lists.lustre.org
>>>>>> Subject: Re: [lustre-devel] lprocfs Helper Issues
>>>>>>
>>>>>> I looked through the code a bit, and I think that the even bigger
>>>>>> issues
>>>>>> are the lack of reasonable naming, lack of comments, and a puzzling
>>>>>> semantic inconsistency.
>>>>>>
>>>>>> Before working on any of the issues I mention below though, we should
>>>>>> probably make sure that these functions still have a purpose once
>>>>>> /proc
>>>>>> goes away.  They seem generic enough helpers that they will still be
>>>>>> used with the non-/proc methods, but it is worth checking.
>>>>>>
>>>>>> First, consider this pair of names:
>>>>>>
>>>>>> lprocfs_write_frac_helper
>>>>>> lprocfs_write_frac_u64_helper
>>>>>>
>>>>>> One might reasonably suspect that the major difference between these
>>>>>> two
>>>>>> functions is that the latter deails with a u64, and the former does
>>>>>> not.
>>>>>>     But that is already pretty darn clear from the full function
>>>>>> prototype, and really the main difference is that
>>>>>> lprocfs_write_frac_u64_helper can parse a units character in the
>>>>>> string.
>>>>>>     Maybe the name should be lprocfs_write_frac_units_helper.
>>>>>>
>>>>>> Also, the semantics surrounding the multiplier are field are
>>>>>> different.
>>>>>>     For lprocfs_write_frac_helper the mult parameter is always
>>>>>> enforced,
>>>>>> and there is code that replies on that.  With
>>>>>> lprocfs_write_frac_u64_helper mult is merely a default, and the
>>>>>> caller
>>>>>> can't rely on it being used.  Two functions with similar names but
>>>>>> difference semantics (and not in the way implied by the name
>>>>>> difference), and no function comments...not a good idea.
>>>>>>
>>>>>> Next there is the naming difference between these:
>>>>>>
>>>>>> lprocfs_write_frac_u64_helper
>>>>>> lprocfs_write_u64_helper
>>>>>>
>>>>>> One might reasonably expect that when using the latter function one
>>>>>> loses the ability to handle fractional numbers.  But no, actually it
>>>>>> just sets the multiplier to a default of 1.  How does that naming
>>>>>> make
>>>>>> any sense?
>>>>>>
>>>>>> I suppose that with lprocfs_write_helper that naming style almost
>>>>>> makes
>>>>>> sense, because a multiplier of 1 will result in anything after the
>>>>>> decimal point being calculated out to 0.  So  the fractional part
>>>>>> is, in
>>>>>> effect, ignored.  But, strangely enough, fractions are still
>>>>>> _accepted_
>>>>>> by the function.
>>>>>>
>>>>>> This semantic distinction is important to consider.  It means that
>>>>>> you
>>>>>> can't just do a naive combination of the two functions into your
>>>>>> proposed lprocfs_write_frac_helper_internal() function.  There are
>>>>>> callers of lprocfs_write_frac_helper that assume that the multiplier
>>>>>> can
>>>>>> be only the one specified and would result in incorrect number if
>>>>>> there
>>>>>> were user-specified units in the string.
>>>>>>
>>>>>> By the was, I'm not really in favor of duplicating the existing
>>>>>> functions with a hope to remove the old ones at some time in the
>>>>>> future.
>>>>>>     I think (despite current evidence to the contrary) that these
>>>>>> functions are not so difficult to review that we would need a
>>>>>> transition
>>>>>> period.  We would just need to audit every caller to make sure that
>>>>>> any
>>>>>> semantic changes are handled.
>>>>>>
>>>>>> And frankly, there would appear to be code that _already_ gets this
>>>>>> wrong, so an audit is really needed already.  For instance,
>>>>>> ll_max_readahead_mb_seq_write() tries to be too clever by assuming
>>>>>> that
>>>>>> users can only provide an integer that represents number of MiB, and
>>>>>> then passes in a multiplier that will have it convert into number of
>>>>>> pages.  But the since they used lprocfs_write_frac_u64_helper(), the
>>>>>> user can specify their own units, and then the number returned number
>>>>>> will be bytes instead of pages.  Here are the callers that I found
>>>>>> that
>>>>>> are doing it wrong:
>>>>>>
>>>>>>      ll_max_readahead_mb_seq_write
>>>>>>      ll_max_cached_mb_seq_write
>>>>>>      proc_max_dirty_pages_in_mb
>>>>>>      osc_cached_mb_seq_write
>>>>>>
>>>>>> 4 out of 5 are doing it wrong.  Not a good track record.
>>>>>>
>>>>>> And getting back to the point, franctions and units are both accepted
>>>>>> and handled by lprocfs_write_u64_helper, so the lack of "_frac_" in
>>>>>> the
>>>>>> name is misleading at best.
>>>>>>
>>>>>> Why does lprocfs_write_frac_helper do its own handling of negatives
>>>>>> and
>>>>>> then call the unsigned simple_strtoul function?  Why not just use the
>>>>>> signed simple_strtol function?  As far as I can tell the signed
>>>>>> version
>>>>>> of the function has been in Linux as long as the unsigned version.
>>>>>>
>>>>>> Why is mult declared as a signed int?  I think it should almost
>>>>>> certainly be unsigned.  I think it might only be signed because the
>>>>>> function author reuses mult as a local variable to stored the
>>>>>> negative
>>>>>> sign when parsed from the string.  If so, that is a poor choice.  The
>>>>>> function declaration is a contract with the caller.  If it makes no
>>>>>> sense to pass in a negative multiplier, then the declaration should
>>>>>> make
>>>>>> that clear by declaring it unsigned.
>>>>>>
>>>>>> Why do the unsigned versions of the helper functions allow and parse
>>>>>> negative numbers?  I think that this gets to the heart of your
>>>>>> suggestion about special handling for -1.  I think that knowing that
>>>>>> -1
>>>>>> has special meaning for something things is too specialized for the
>>>>>> helper function.  I think we are better off letting the caller
>>>>>> decided
>>>>>> what special handling to do and when.
>>>>>>
>>>>>> I would suggest that the main helper that does handling of
>>>>>> user-specified units should not be casting the number to an unsigned
>>>>>> value.  Leave the casting to the caller, or perhaps provide a simple
>>>>>> wrapper to cast away the sign.  I don't think we are going to miss
>>>>>> that
>>>>>> one extra bit for positive numbers.
>>>>>>
>>>>>> So maybe we need the most generic function prototype be be something
>>>>>> like:
>>>>>>
>>>>>> int lprocfs_write_helper(char *buffer, unsigned long count, __s64
>>>>>> *val,
>>>>>> unsigned int mult, bool units_allowed);
>>>>>>
>>>>>> The function comment would explain that if units are allowed, then
>>>>>> the
>>>>>> multiplier is only a default and will be overridden by the
>>>>>> user-specificed unit.
>>>>>>
>>>>>> Chris
>>>>>>
>>>>>>> On 09/28/2015 01:08 PM, Di Natale, Giuseppe wrote:
>>>>>>> Greetings,
>>>>>>>
>>>>>>> Recently, I've noticed that the lprocfs write frac int and u64
>>>>>>> helpers
>>>>>>> have a few issues. The biggest issue is that neither function
>>>>>>> handles
>>>>>>> overflow/wrap. I also noticed very similar code that should be
>>>>>>> consolidated down and leveraged by both helpers.
>>>>>>>
>>>>>>> I was thinking of refactoring the functions in the fashion described
>>>>>>> below.
>>>>>>>
>>>>>>> int lprocfs_write_frac_helper_internal(char *buffer, unsigned long
>>>>>>> count, __u64 *val, int mult);
>>>>>>> int lprocfs_write_frac_u64_helper_safe(const char __user *buffer,
>>>>>>> unsigned long count, __u64 *val, int mult);
>>>>>>> int lprocfs_write_frac_helper_safe(const char __user *buffer,
>>>>>>> unsigned
>>>>>>> long count, int *val, int mult);
>>>>>>>
>>>>>>> lprocfs_write_frac_helper_internal would handle parsing an unsigned
>>>>>>> long
>>>>>>> long from the kernel char buffer passed in. It will be responsible
>>>>>>> for
>>>>>>> detecting if a uint wrap occurs.
>>>>>>>
>>>>>>> For lprocfs_write_frac_u64_helper_safe, the string "-1" will
>>>>>>> automatically return ULLONG_MAX. If any other string representing a
>>>>>>> negative number is passed in, an invalid value error code should be
>>>>>>> returned. If the multiplier is negative, that would also be treated
>>>>>>> as
>>>>>>> invalid. The units and multiplier logic can also be consolidated. It
>>>>>>> will use lprocfs_write_frac_helper_internal to handle the parsing.
>>>>>>>
>>>>>>> lprocfs_write_frac_helper_safe will leverage
>>>>>>> lprocfs_write_frac_helper_internal. If
>>>>>>> lprocfs_write_frac_helper_internal indicates a wrap occurred, then
>>>>>>> we
>>>>>>> also have an invalid integer. Checks for integer overflow happen
>>>>>>> after a
>>>>>>> successful call to the internal helper. This is similar to how the
>>>>>>> current lprocfs_write_frac_helper functions.
>>>>>>>
>>>>>>> It is also worth nothing, I plan to maintain the old helpers and
>>>>>>> their
>>>>>>> use can be gradually phased out once we are confident the refactored
>>>>>>> version is doing what it is supposed to.
>>>>>>>
>>>>>>> Also, unrelated to the above, quick question about lctl. Is there a
>>>>>>> particular reason why the setting to be changed when using lctl
>>>>>>> set_param is echoed back to the user? I think it can be misleading
>>>>>>> in
>>>>>>> cases where the value set is not necessarily what is being
>>>>>>> reflected to
>>>>>>> the user (i.e. -1 for max value). That could be confusing to a user
>>>>>>> and
>>>>>>> they should be using lctl get_param to confirm their value was set
>>>>>>> anyways. Also, it would follow convention that unless an error
>>>>>>> happens,
>>>>>>> nothing is printed to console. Any disagreements on silencing lctl
>>>>>>> set_param?
>>>>>>>
>>>>>>> Thanks,
>>>>>>> Giuseppe Di Natale
>>>>>>>
>>>>>>>
>>>>>>>
>
>
> Cheers, Andreas
> --
> Andreas Dilger
>
> Lustre Software Architect
> Intel High Performance Data Division
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> .
>
