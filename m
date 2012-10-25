From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 25 Oct 2012 14:13:46 -0700
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <3E3EE9AC-9DD4-4DBC-8045-E9E8323685EB@xyratex.com>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<EA3A770421F31B4BB895DD3AB9224495709D89@fmsmsx119.amr.corp.intel.com>
	<3E3EE9AC-9DD4-4DBC-8045-E9E8323685EB@xyratex.com>
Message-ID: <5089AB8A.9070402@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It really sounds like you are putting the cart before the horse. 
Picking a favorite language is probably a bad way to go.  First we 
should figure out why we're changing things, and what the scope and 
goals of the new design are.

Brian Behlendorf pointed out the kernel Autotest system as an option, 
which sounds worthy of investigation to me.  If we were to decide on 
Perl today, that would make working with that Autotest more difficult, 
because that is all done in Python.  But if choose Python and then try 
to use an entirely Visual Basic based framework (Ha! I kid!) we also 
probably made the wrong choice.

In other words, it is important to know something about where we are 
going before we pick a language.

On 10/25/2012 12:24 PM, Nathan Rutman wrote:
>
> On Oct 25, 2012, at 11:20 AM, "Gearing, Chris" <chris.gearing@intel.com
> <mailto:chris.gearing@intel.com>> wrote:
>
>> Hi,
>>
>> >Based on the responses so far, it seems that there is a fairly clear
>> preference for Python as a test language, and so I'll propose that
>> Python should be used shorter-term to start replacing test-framework.
>>
>> I don?t think that is the case Nathan, because unless I am mistaken
>> Jacques-Charles, Kilian Cavalotti and if it is a binary choice today
>> my preference is Python (but please see below)
> Aurelien - python 2
>
>> Bruce was neutral
>> Roman and Colin (after your email) expressed Perl as a choice.
>> So the preference would seem to be for Python, counting by people and
>> organization although obviously it?s a statistically suspect poll.
> Indeed.  As I stated before, a poll is not the best way to choose the
> language; it's just one data point.  But as a) we must choose something
> to start making any headway toward improvements, and b) bash doesn't
> meet the requirements, I'm trying to come up with some kind of baseline.
>
>> Chris
>>
>> NOTES OF MY VOTE: Given the importance of the topic I believe a much
>> broader piece of analysis needs to be done to select the right language,
> I'm just trying to keep things moving from theoretical optimum to
> practical conclusion.  We feel a need today for much better Lustre
> testing, and there's a huge pile of work waiting, and so I feel we must
> move forward.
>
>> also if this is for an existing framework update the tests must all be
>> in bash or all converted to the new language of choice.
> Short term the idea would be to translate one of the test suites, for
> example conf-sanity, to the new language/framework.  The two systems
> (old and new) would live side-by-side for some period.  New tests should
> be implemented under the new system (e.g. sanity2).  Other old tests
> could be converted piecemeal subsequently.
>
>
>> ---------------------------------------------------------------------
>> Intel Corporation (UK) Limited
>> Registered No. 1134945 (England)
>> Registered Office: Pipers Way, Swindon SN3 1RJ
>> VAT No: 860 2173 47
>>
>> This e-mail and any attachments may contain confidential material for
>> the sole use of the intended recipient(s). Any review or distribution
>> by others is strictly prohibited. If you are not the intended
>> recipient, please contact the sender and delete all copies.
>>
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
