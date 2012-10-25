From: Prakash Surya <surya1@llnl.gov>
Date: Thu, 25 Oct 2012 14:52:43 -0700
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <34F2324A-7C99-4B59-AB9D-9BDB60912BF3@xyratex.com>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<EA3A770421F31B4BB895DD3AB9224495709D89@fmsmsx119.amr.corp.intel.com>
	<3E3EE9AC-9DD4-4DBC-8045-E9E8323685EB@xyratex.com>
	<5089AB8A.9070402@llnl.gov>
	<34F2324A-7C99-4B59-AB9D-9BDB60912BF3@xyratex.com>
Message-ID: <20121025215243.GF2555@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Oct 25, 2012 at 02:28:52PM -0700, Nathan Rutman wrote:
>    On Oct 25, 2012, at 2:13 PM, Christopher J. Morrone
>    <[1]morrone2@llnl.gov> wrote:
> 
>      It really sounds like you are putting the cart before the horse.
>      Picking a favorite language is probably a bad way to go.  First we
>      should figure out why we're changing things, and what the scope and
>      goals of the new design are.
>      Brian Behlendorf pointed out the kernel Autotest system as an
>      option, which sounds worthy of investigation to me.  If we were to
>      decide on Perl today, that would make working with that Autotest
>      more difficult, because that is all done in Python.  But if choose
>      Python and then try to use an entirely Visual Basic based framework
>      (Ha! I kid!) we also probably made the wrong choice.
>      In other words, it is important to know something about where we are
>      going before we pick a language.
> 
>    As I said before:
> 
>    For more context, including the motivation for changing things, see my
>    LAD'12 presentation (more narrowly focused) on the [2]OpenSFS Wiki.

Commenting on your presentation slides (slide 3 specifically) as I think
it relates to this discusstion:

 * "Bash languages is not modular or portable"

Why do you think this? Bash is extremely modular using the "source"
command. Write code in a file, source it in another file, and there you
go. The "sourced" file is a separate reusable module, is it not? Sure it
might be global in the namespace, but that's another issue.

Not portable? Really? Bash is available on just about every Linux
distribution that comes to mind. Definitely every one Lustre cares
about.

 * "Test scripts are not coherent"

That is not Bash's fault. Bad code can be written in any language. It's
up to the programmer to write "coherent" test scripts.

How would switching languages improve on either of these two fronts?

-- 
Cheers, Prakash

> 
>    Also, see Chris' preso on a language:
> 
>      As promised:
>      [3]http://wiki.whamcloud.com/download/attachments/7634975/new+test+f
>      ramework.pdf
> 
>    Picking a language is just one part of it, and definitely not the most
>    important part.  I'll be posting more on some other proposed changes in
>    the future.
>    On Oct 25, 2012, at 10:23 AM, Brian Behlendorf
>    <[4]behlendorf1@llnl.gov> wrote:
> 
>      On Wed, 2012-10-24 at 15:05 -0700, Nathan Rutman wrote:
> 
>      On Oct 24, 2012, at 1:02 PM, "Gearing, Chris"
>      <[5]chris.gearing@intel.com> wrote:
> 
>      Nathan,
>      I'm not 100% sure what you are proposing here, your LAD presentation
>      suggested a 'tune-up' of the current test framework rather than a
>      complete re-write. Which of the two are we discussing?
> 
>      Both...
> 
>      The requirements on the framework language are more relaxed, but for
>      ease of development and developer sanity, I assume that the
>      framework language should match the test language.  So I'm using the
>      test language as the requirements driver, and to gage community
>      preference for that test language.
> 
>      Before embarking on building yet another new and custom framework
>      for
>      Lustre we should evaluate some existing frameworks.  For example,
>      the
>      Autotest project was specifically designed to test the Linux kernel.
>      It's open source, looks active, is flexible, and there is detailed
>      documentation on how to write tests.  Plus it was designed
>      specifically
>      for testing the kernel so there are likely existing file system
>      tests.
>       [6]http://autotest.github.com/
>       "Autotest is a framework for fully automated testing. It is
>        designed primarily to test the Linux kernel, though it is useful
>        for many other functions such as qualifying new hardware. It's an
>        open-source project under the GPL and is used and developed by a
>        number of organizations, including Google, IBM, Red Hat, and many
>        others."
> 
>      Based on the responses so far, it seems that there is a fairly clear
>      preference for Python as a test language, and so I'll propose that
>      Python should be used shorter-term to start replacing
>      test-framework.
> 
>      If we decide the Autotest framework is a good fit then we'll want to
>      write the tests in python to be consistent with the framework
>      language.
>      However, for a first cut it looks like you could use the existing
>      bash
>      tests largely unmodified.
>      --
>      Thanks,
>      Brian
>      _______________________________________________
>      Lustre-devel mailing list
>      [7]Lustre-devel at lists.lustre.org
>      [8]http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
>      On 10/25/2012 12:24 PM, Nathan Rutman wrote:
> 
>      On Oct 25, 2012, at 11:20 AM, "Gearing, Chris"
>      <[9]chris.gearing@intel.com
>      <[10]mailto:chris.gearing@intel.com>> wrote:
> 
>      Hi,
>      >Based on the responses so far, it seems that there is a fairly
>      clear
>      preference for Python as a test language, and so I'll propose that
>      Python should be used shorter-term to start replacing
>      test-framework.
>      I don?t think that is the case Nathan, because unless I am mistaken
>      Jacques-Charles, Kilian Cavalotti and if it is a binary choice today
>      my preference is Python (but please see below)
> 
>      Aurelien - python 2
> 
>      Bruce was neutral
>      Roman and Colin (after your email) expressed Perl as a choice.
>      So the preference would seem to be for Python, counting by people
>      and
>      organization although obviously it?s a statistically suspect poll.
> 
>      Indeed.  As I stated before, a poll is not the best way to choose
>      the
>      language; it's just one data point.  But as a) we must choose
>      something
>      to start making any headway toward improvements, and b) bash doesn't
>      meet the requirements, I'm trying to come up with some kind of
>      baseline.
> 
>      Chris
>      NOTES OF MY VOTE: Given the importance of the topic I believe a much
>      broader piece of analysis needs to be done to select the right
>      language,
> 
>      I'm just trying to keep things moving from theoretical optimum to
>      practical conclusion.  We feel a need today for much better Lustre
>      testing, and there's a huge pile of work waiting, and so I feel we
>      must
>      move forward.
> 
>      also if this is for an existing framework update the tests must all
>      be
>      in bash or all converted to the new language of choice.
> 
>      Short term the idea would be to translate one of the test suites,
>      for
>      example conf-sanity, to the new language/framework.  The two systems
>      (old and new) would live side-by-side for some period.  New tests
>      should
>      be implemented under the new system (e.g. sanity2).  Other old tests
>      could be converted piecemeal subsequently.
> 
>      --------------------------------------------------------------------
>      -
>      Intel Corporation (UK) Limited
>      Registered No. 1134945 (England)
>      Registered Office: Pipers Way, Swindon SN3 1RJ
>      VAT No: 860 2173 47
>      This e-mail and any attachments may contain confidential material
>      for
>      the sole use of the intended recipient(s). Any review or
>      distribution
>      by others is strictly prohibited. If you are not the intended
>      recipient, please contact the sender and delete all copies.
> 
>      _______________________________________________
>      Lustre-devel mailing list
>      [11]Lustre-devel at lists.lustre.org
>      http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> References
> 
>    1. mailto:morrone2 at llnl.gov
>    2. http://www.opensfs.org/foswiki/bin/view/Lustre/TestingImprovements
>    3. http://wiki.whamcloud.com/download/attachments/7634975/new+test+framework.pdf
>    4. mailto:behlendorf1 at llnl.gov
>    5. mailto:chris.gearing at intel.com
>    6. http://autotest.github.com/
>    7. mailto:Lustre-devel at lists.lustre.org
>    8. http://lists.lustre.org/mailman/listinfo/lustre-devel
>    9. mailto:chris.gearing at intel.com
>   10. mailto:chris.gearing at intel.com
>   11. mailto:Lustre-devel at lists.lustre.org

> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
