From: Roman Grigoryev <roman_grigoryev@xyratex.com>
Date: Wed, 24 Oct 2012 12:44:57 +0400
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <CAJz=VjGhzRQZXAWYcRCRyRhLrnhv4J4d=73cijVL15vtqnLkUQ@mail.gmail.com>
References: <9E235E88-FAD1-44BF-A4DC-12A5801E0467@xyratex.com>
	<5086F285.6000809@cea.fr> <50878B5E.1090600@xyratex.com>
	<CAJz=VjGhzRQZXAWYcRCRyRhLrnhv4J4d=73cijVL15vtqnLkUQ@mail.gmail.com>
Message-ID: <5087AA89.9040000@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Kilian,

if you want I could try to explain why not bash from my point of view.

I agree that bash is language which could be used for test frameworks
and test-framework.sh prove it. But some
bash feature make current framework support pretty hard. For example, I
don't see good way to  use  bash unit tests for test-framework.sh

More structured requests:

1) Language features. Perl/Python/Java has many features which allows
simple write complex logic (OOP,AOP and so on)
2) Pretty wide set of libraries.
3) powerful and useful unit test frameworks.
4) support tools, e.g. inline documentation, schema generator based on
code, coverage collectiors, copyright checkers

Ubuntu is building by Intel
(http://build.whamcloud.com/job/lustre-b2_3/), so looks like it is
important platform.

Thanks,
    Roman
> Hi Roman,
>
> On Wed, Oct 24, 2012 at 8:31 AM, Roman Grigoryev
> <roman_grigoryev@xyratex.com> wrote:
>> RH5 has only python2.4, SL61  has python2.4 and python2.6, and looks like
>> only last Fedora will have python3.
> I agree that inter-version compatibility could be a problem with
> Python. But to take this argument literally, the best way to avoid
> compatibility issues is to use the widest-spread and most version
> consistent language across supported distributions, ie. bash.
>
>> In same time, Ubuntu says that from next
>> release want to have only Python 3.
> Since only RHEL, CentOS and SLES are supported, should we really care
> about python versions in Ubuntu?
> When installing Lustre in Ubuntu, users already have to do their own
> packaging, so I'm not sure that having to install a specific version
> of a scripting language would make much of a difference.
>
>> Now Lustre tests compatibility for wide set of system is solved by shell and
>> standard utilities. Perl also has great
>> compatibility history, many scripts could work on latest version as 10 years
>> ago. It is reason why I see Perl as
>> good decision.
> So what's wrong with bash again? If it's just "too flexible, easy to
> abuse", I'm afraid there's little in Perl to prevent falling into the
> same pitfalls. :)
>
> Cheers,
