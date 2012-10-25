From: Prakash Surya <surya1@llnl.gov>
Date: Thu, 25 Oct 2012 15:13:09 -0700
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <84D2B1BF-DE95-4A17-B7E7-8984E389CD9F@xyratex.com>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<1351185793.14408.283.camel@pip>
	<EFAB2B2C-F4CB-4080-A787-83452C66C185@xyratex.com>
	<20121025211744.GE2555@llnl.gov>
	<84D2B1BF-DE95-4A17-B7E7-8984E389CD9F@xyratex.com>
Message-ID: <20121025221309.GG2555@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Oct 25, 2012 at 02:36:02PM -0700, Nathan Rutman wrote:
> 
> On Oct 25, 2012, at 2:17 PM, Prakash Surya <surya1@llnl.gov> wrote:
> 
> > On Thu, Oct 25, 2012 at 11:04:55AM -0700, Nathan Rutman wrote:
> >>   There are several levels of "test framework" that are involved with
> >>   automated testing of Lustre:
> >> 
> >>     * unit tests themselves, written in bash, e.g. sanity 1a
> > 
> > What do you mean by "unit tests" here? Because as I understand it,
> > Lustre has no unit testing at all. It is all functional testing,
> > which is related but completely different.
> Let's please not get into this.  I just meant the individual tests.

OK, I just wanted to make sure we're on the same page. I would *love*
to see unit testing incorporated into the test suite. I think that would
greatly benefit the stability of the project.

> 
> > 
> >>     * test-framework.sh & friends, which provides some
> >>       support/setup/communal library for unit tests
> >>     * automated test systems, which automatically execute the unit tests,
> >>       record and report the results.
> > 
> > I don't quite understand why there is so much discussion regarding a new
> > testing framework specifically designed for testing Lustre. Is there
> > really nothing already out there we can make use of?
> > 
> > Brian linked to the Autotest framework, does that not do what we want?
> 
> That covers the third meaning, but not the first two.   I'm only concerned about the
> first two at the moment. 

Well, I think it spills into the first and second as well.

1. Since Autotest is already implemented in python, it would make sense to use
   that as the language for the individual tests as well.

2. And it _may_ deal with set up of tests. But I haven't looked into
   Autotest enough to know its limitations. The shared library would, of
   course, be specific to Lustre.

> 
> > If it doesn't work, why not?
> It doesn't contain a Lustre-specific functional library, it doesn't safely limit the tests
> that may be run on a specific system, it doesn't handle interoperability testing, etc.

Right, the test library will be specific to Lustre.

Limiting the number of tests to run, which ones run, and interoperability
might be partially handled by whatever automated framework is used. Of
course it might not, as well.

> 
> > And how is our home brewed solution going
> > to differ? Are there any other alternatives out there? I don't see
> > benefit in spending development on a new framework if it's unnecessary.
> > 
> > There is a lot of discussion regarding a tool (the language) and little
> > involving the problem (lack of useful functional and unit tests to
> > properly stress the system). Pick something, move on, and start
> > improving the codes stability.
> That was what I was trying to do.

Great! :). I'm really looking forward to seeing a solid testing
infrastructure implemented.

> 
> > 
> > And if somebody *really* wants to build a new testing framework, have it
> > live out of tree. Create it as a standalone project which interfaces
> > with Lustre.
> As stated in my presentation, that is part of the plan.

Ah, I didn't catch that part. Good to know.

-- 
Cheers, Prakash

> 
> > 
> > -- 
> > Cheers, Prakash
> > 
> > 
> >> 
> >>   I'm only speaking about the language for the first of these items at
> >>   the moment.
> >>   For more context, including the motivation for changing things, see my
> >>   LAD'12 presentation (more narrowly focused) on the [1]OpenSFS Wiki.
> >>   On Oct 25, 2012, at 10:23 AM, Brian Behlendorf
> >>   <[2]behlendorf1@llnl.gov> wrote:
> >> 
> >>     On Wed, 2012-10-24 at 15:05 -0700, Nathan Rutman wrote:
> >> 
> >>     On Oct 24, 2012, at 1:02 PM, "Gearing, Chris"
> >>     <[3]chris.gearing@intel.com> wrote:
> >> 
> >>     Nathan,
> >>     I'm not 100% sure what you are proposing here, your LAD presentation
> >>     suggested a 'tune-up' of the current test framework rather than a
> >>     complete re-write. Which of the two are we discussing?
> >> 
> >>     Both...
> >> 
> >>     The requirements on the framework language are more relaxed, but for
> >>     ease of development and developer sanity, I assume that the
> >>     framework language should match the test language.  So I'm using the
> >>     test language as the requirements driver, and to gage community
> >>     preference for that test language.
> >> 
> >>     Before embarking on building yet another new and custom framework
> >>     for
> >>     Lustre we should evaluate some existing frameworks.  For example,
> >>     the
> >>     Autotest project was specifically designed to test the Linux kernel.
> >>     It's open source, looks active, is flexible, and there is detailed
> >>     documentation on how to write tests.  Plus it was designed
> >>     specifically
> >>     for testing the kernel so there are likely existing file system
> >>     tests.
> >>      [4]http://autotest.github.com/
> >>      "Autotest is a framework for fully automated testing. It is
> >>       designed primarily to test the Linux kernel, though it is useful
> >>       for many other functions such as qualifying new hardware. It's an
> >>       open-source project under the GPL and is used and developed by a
> >>       number of organizations, including Google, IBM, Red Hat, and many
> >>       others."
> >> 
> >>     Based on the responses so far, it seems that there is a fairly clear
> >>     preference for Python as a test language, and so I'll propose that
> >>     Python should be used shorter-term to start replacing
> >>     test-framework.
> >> 
> >>     If we decide the Autotest framework is a good fit then we'll want to
> >>     write the tests in python to be consistent with the framework
> >>     language.
> >>     However, for a first cut it looks like you could use the existing
> >>     bash
> >>     tests largely unmodified.
> >>     --
> >>     Thanks,
> >>     Brian
> >>     _______________________________________________
> >>     Lustre-devel mailing list
> >>     [5]Lustre-devel at lists.lustre.org
> >>     http://lists.lustre.org/mailman/listinfo/lustre-devel
> >> 
> >> References
> >> 
> >>   1. http://www.opensfs.org/foswiki/bin/view/Lustre/TestingImprovements
> >>   2. mailto:behlendorf1 at llnl.gov
> >>   3. mailto:chris.gearing at intel.com
> >>   4. http://autotest.github.com/
> >>   5. mailto:Lustre-devel at lists.lustre.org
> > 
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel
> > 
