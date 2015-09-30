From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 30 Sep 2015 20:06:17 +0000
Subject: [lustre-devel] lprocfs Helper Issues
In-Reply-To: <560B4800.6070103@llnl.gov>
References: <974262C966B9F640899A48EB96313E9A2C9DAA@PRDEXMBX-08.the-lab.llnl.gov>
	<560B4800.6070103@llnl.gov>
Message-ID: <D2319BAA.10E1BF%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/09/29, 8:25 PM, "lustre-devel on behalf of Christopher J. Morrone"
<lustre-devel-bounces at lists.lustre.org on behalf of morrone2@llnl.gov>
wrote:

>I looked through the code a bit, and I think that the even bigger issues
>are the lack of reasonable naming, lack of comments, and a puzzling
>semantic inconsistency.
>
>Before working on any of the issues I mention below though, we should
>probably make sure that these functions still have a purpose once /proc
>goes away.  They seem generic enough helpers that they will still be
>used with the non-/proc methods, but it is worth checking.

Chris, definitely a lot of separate issues raised here. I'm in support of
Giuseppe replacing these functions with a single implementation that gets
it right.  This is something that I've wanted for a long time, but it
hasn't
been a priority.

It makes sense to handle the special cases (-1) in the callers, and then
remove the old functions.  I don't see any value in keeping the old
versions
of the function around either, and I don't think there are so many users
that it is onerous to understand their usage and replace them all.

Cheers, Andreas

>First, consider this pair of names:
>
>lprocfs_write_frac_helper
>lprocfs_write_frac_u64_helper
>
>One might reasonably suspect that the major difference between these two
>functions is that the latter deails with a u64, and the former does not.
>  But that is already pretty darn clear from the full function
>prototype, and really the main difference is that
>lprocfs_write_frac_u64_helper can parse a units character in the string.
>  Maybe the name should be lprocfs_write_frac_units_helper.
>
>Also, the semantics surrounding the multiplier are field are different.
>  For lprocfs_write_frac_helper the mult parameter is always enforced,
>and there is code that replies on that.  With
>lprocfs_write_frac_u64_helper mult is merely a default, and the caller
>can't rely on it being used.  Two functions with similar names but
>difference semantics (and not in the way implied by the name
>difference), and no function comments...not a good idea.
>
>Next there is the naming difference between these:
>
>lprocfs_write_frac_u64_helper
>lprocfs_write_u64_helper
>
>One might reasonably expect that when using the latter function one
>loses the ability to handle fractional numbers.  But no, actually it
>just sets the multiplier to a default of 1.  How does that naming make
>any sense?
>
>I suppose that with lprocfs_write_helper that naming style almost makes
>sense, because a multiplier of 1 will result in anything after the
>decimal point being calculated out to 0.  So  the fractional part is, in
>effect, ignored.  But, strangely enough, fractions are still _accepted_
>by the function.
>
>This semantic distinction is important to consider.  It means that you
>can't just do a naive combination of the two functions into your
>proposed lprocfs_write_frac_helper_internal() function.  There are
>callers of lprocfs_write_frac_helper that assume that the multiplier can
>be only the one specified and would result in incorrect number if there
>were user-specified units in the string.
>
>By the was, I'm not really in favor of duplicating the existing
>functions with a hope to remove the old ones at some time in the future.
>  I think (despite current evidence to the contrary) that these
>functions are not so difficult to review that we would need a transition
>period.  We would just need to audit every caller to make sure that any
>semantic changes are handled.
>
>And frankly, there would appear to be code that _already_ gets this
>wrong, so an audit is really needed already.  For instance,
>ll_max_readahead_mb_seq_write() tries to be too clever by assuming that
>users can only provide an integer that represents number of MiB, and
>then passes in a multiplier that will have it convert into number of
>pages.  But the since they used lprocfs_write_frac_u64_helper(), the
>user can specify their own units, and then the number returned number
>will be bytes instead of pages.  Here are the callers that I found that
>are doing it wrong:
>
>   ll_max_readahead_mb_seq_write
>   ll_max_cached_mb_seq_write
>   proc_max_dirty_pages_in_mb
>   osc_cached_mb_seq_write
>
>4 out of 5 are doing it wrong.  Not a good track record.
>
>And getting back to the point, franctions and units are both accepted
>and handled by lprocfs_write_u64_helper, so the lack of "_frac_" in the
>name is misleading at best.
>
>Why does lprocfs_write_frac_helper do its own handling of negatives and
>then call the unsigned simple_strtoul function?  Why not just use the
>signed simple_strtol function?  As far as I can tell the signed version
>of the function has been in Linux as long as the unsigned version.
>
>Why is mult declared as a signed int?  I think it should almost
>certainly be unsigned.  I think it might only be signed because the
>function author reuses mult as a local variable to stored the negative
>sign when parsed from the string.  If so, that is a poor choice.  The
>function declaration is a contract with the caller.  If it makes no
>sense to pass in a negative multiplier, then the declaration should make
>that clear by declaring it unsigned.
>
>Why do the unsigned versions of the helper functions allow and parse
>negative numbers?  I think that this gets to the heart of your
>suggestion about special handling for -1.  I think that knowing that -1
>has special meaning for something things is too specialized for the
>helper function.  I think we are better off letting the caller decided
>what special handling to do and when.
>
>I would suggest that the main helper that does handling of
>user-specified units should not be casting the number to an unsigned
>value.  Leave the casting to the caller, or perhaps provide a simple
>wrapper to cast away the sign.  I don't think we are going to miss that
>one extra bit for positive numbers.
>
>So maybe we need the most generic function prototype be be something like:
>
>int lprocfs_write_helper(char *buffer, unsigned long count, __s64 *val,
>unsigned int mult, bool units_allowed);
>
>The function comment would explain that if units are allowed, then the
>multiplier is only a default and will be overridden by the
>user-specificed unit.
>
>Chris
>
>On 09/28/2015 01:08 PM, Di Natale, Giuseppe wrote:
>> Greetings,
>>
>> Recently, I've noticed that the lprocfs write frac int and u64 helpers
>> have a few issues. The biggest issue is that neither function handles
>> overflow/wrap. I also noticed very similar code that should be
>> consolidated down and leveraged by both helpers.
>>
>> I was thinking of refactoring the functions in the fashion described
>>below.
>>
>> int lprocfs_write_frac_helper_internal(char *buffer, unsigned long
>> count, __u64 *val, int mult);
>> int lprocfs_write_frac_u64_helper_safe(const char __user *buffer,
>> unsigned long count, __u64 *val, int mult);
>> int lprocfs_write_frac_helper_safe(const char __user *buffer, unsigned
>> long count, int *val, int mult);
>>
>> lprocfs_write_frac_helper_internal would handle parsing an unsigned long
>> long from the kernel char buffer passed in. It will be responsible for
>> detecting if a uint wrap occurs.
>>
>> For lprocfs_write_frac_u64_helper_safe, the string "-1" will
>> automatically return ULLONG_MAX. If any other string representing a
>> negative number is passed in, an invalid value error code should be
>> returned. If the multiplier is negative, that would also be treated as
>> invalid. The units and multiplier logic can also be consolidated. It
>> will use lprocfs_write_frac_helper_internal to handle the parsing.
>>
>> lprocfs_write_frac_helper_safe will leverage
>> lprocfs_write_frac_helper_internal. If
>> lprocfs_write_frac_helper_internal indicates a wrap occurred, then we
>> also have an invalid integer. Checks for integer overflow happen after a
>> successful call to the internal helper. This is similar to how the
>> current lprocfs_write_frac_helper functions.
>>
>> It is also worth nothing, I plan to maintain the old helpers and their
>> use can be gradually phased out once we are confident the refactored
>> version is doing what it is supposed to.
>>
>> Also, unrelated to the above, quick question about lctl. Is there a
>> particular reason why the setting to be changed when using lctl
>> set_param is echoed back to the user? I think it can be misleading in
>> cases where the value set is not necessarily what is being reflected to
>> the user (i.e. -1 for max value). That could be confusing to a user and
>> they should be using lctl get_param to confirm their value was set
>> anyways. Also, it would follow convention that unless an error happens,
>> nothing is printed to console. Any disagreements on silencing lctl
>> set_param?
>>
>> Thanks,
>> Giuseppe Di Natale
>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
