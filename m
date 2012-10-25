From: Nathan Rutman <nathan_rutman@xyratex.com>
Date: Thu, 25 Oct 2012 11:04:55 -0700
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <1351185793.14408.283.camel@pip>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<1351185793.14408.283.camel@pip>
Message-ID: <EFAB2B2C-F4CB-4080-A787-83452C66C185@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There are several levels of "test framework" that are involved with automated testing of Lustre:
unit tests themselves, written in bash, e.g. sanity 1a
test-framework.sh & friends, which provides some support/setup/communal library for unit tests
automated test systems, which automatically execute the unit tests, record and report the results.

I'm only speaking about the language for the first of these items at the moment.
For more context, including the motivation for changing things, see my LAD'12 presentation (more narrowly focused) on the OpenSFS Wiki.



On Oct 25, 2012, at 10:23 AM, Brian Behlendorf <behlendorf1@llnl.gov> wrote:

> On Wed, 2012-10-24 at 15:05 -0700, Nathan Rutman wrote:
>> On Oct 24, 2012, at 1:02 PM, "Gearing, Chris" <chris.gearing@intel.com> wrote:
>> 
>>> Nathan,
>>> 
>>> I'm not 100% sure what you are proposing here, your LAD presentation suggested a 'tune-up' of the current test framework rather than a complete re-write. Which of the two are we discussing?
>> Both...
>>> 
>> The requirements on the framework language are more relaxed, but for ease of development and developer sanity, I assume that the framework language should match the test language.  So I'm using the test language as the requirements driver, and to gage community preference for that test language.
> 
> Before embarking on building yet another new and custom framework for
> Lustre we should evaluate some existing frameworks.  For example, the
> Autotest project was specifically designed to test the Linux kernel.
> It's open source, looks active, is flexible, and there is detailed
> documentation on how to write tests.  Plus it was designed specifically
> for testing the kernel so there are likely existing file system tests.
> 
>  http://autotest.github.com/
> 
>  "Autotest is a framework for fully automated testing. It is
>   designed primarily to test the Linux kernel, though it is useful
>   for many other functions such as qualifying new hardware. It's an
>   open-source project under the GPL and is used and developed by a
>   number of organizations, including Google, IBM, Red Hat, and many
>   others."
> 
>> Based on the responses so far, it seems that there is a fairly clear preference for Python as a test language, and so I'll propose that Python should be used shorter-term to start replacing test-framework.
> 
> If we decide the Autotest framework is a good fit then we'll want to
> write the tests in python to be consistent with the framework language.
> However, for a first cut it looks like you could use the existing bash
> tests largely unmodified.
> 
> -- 
> Thanks,
> Brian
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20121025/b8b4b1dd/attachment.htm>
