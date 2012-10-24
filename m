From: DEGREMONT Aurelien <aurelien.degremont@cea.fr>
Date: Wed, 24 Oct 2012 18:30:43 +0200
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <5087AA89.9040000@xyratex.com>
References: <9E235E88-FAD1-44BF-A4DC-12A5801E0467@xyratex.com>	<5086F285.6000809@cea.fr>
	<50878B5E.1090600@xyratex.com>	<CAJz=VjGhzRQZXAWYcRCRyRhLrnhv4J4d=73cijVL15vtqnLkUQ@mail.gmail.com>
	<5087AA89.9040000@xyratex.com>
Message-ID: <508817B3.6010008@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

I've developed in Perl and Python for several years in both languages. I 
enjoyed both.
Regarding starting a new project, for testing framework, here is several 
points which are the key points for choosing the right language.

- Longevity

Perl as a long history behind it, is available in all distros, that's 
true. But Perl is there for compatibility for running projects which 
were starting a long time ago. Nobody is starting a really big and fancy 
project in Perl nowadays. All new hackers are only speaking of Python or 
Ruby. You will not attract contributors with Perl. Perl 5 is very 
compatible because no new changes is really added to this language.
And do not tell me that Perl 6 is coming. If Perl 6 is an option, then 
there is no issue with Python 3 and forget your compatibility.

- Compat

Developping in Python, for a large number of environment means coding 
for Python 2.4+. This will run nicely on Python up to 2.7
As long as only Python 2 only is concerned, compat for Python is fine.
But I agree that Python 3 is coming, and at long term, it should be 
taken in account even if no major distro is using it right now.
(No Python 3 before RHEL7 or next Ubuntu LTS (14.04))

-Lustre is for system people

Lustre is developped by system guys, which mainly use vim or emacs to 
develop in Lustre. Very few of them are using IDE or stuff like Maven. 
Population developing Java with Maven is the exact opposite of guys 
coding in C, for Kernel code. Moreover, JVM are awful to install 
regarding a standard Python, Perl or Ruby interpreter in all major distro.


My choice would go for Python 2 with a clear path to migrate to Python 3 
when needed (in 1 year)


Aur?lien



Le 24/10/2012 10:44, Roman Grigoryev a ?crit :
> Hi Kilian,
>
> if you want I could try to explain why not bash from my point of view.
>
> I agree that bash is language which could be used for test frameworks
> and test-framework.sh prove it. But some
> bash feature make current framework support pretty hard. For example, I
> don't see good way to  use  bash unit tests for test-framework.sh
>
> More structured requests:
>
> 1) Language features. Perl/Python/Java has many features which allows
> simple write complex logic (OOP,AOP and so on)
> 2) Pretty wide set of libraries.
> 3) powerful and useful unit test frameworks.
> 4) support tools, e.g. inline documentation, schema generator based on
> code, coverage collectiors, copyright checkers
>
> Ubuntu is building by Intel
> (http://build.whamcloud.com/job/lustre-b2_3/), so looks like it is
> important platform.
>
> Thanks,
>      Roman
>> Hi Roman,
>>
>> On Wed, Oct 24, 2012 at 8:31 AM, Roman Grigoryev
>> <roman_grigoryev@xyratex.com>  wrote:
>>> RH5 has only python2.4, SL61  has python2.4 and python2.6, and looks like
>>> only last Fedora will have python3.
>> I agree that inter-version compatibility could be a problem with
>> Python. But to take this argument literally, the best way to avoid
>> compatibility issues is to use the widest-spread and most version
>> consistent language across supported distributions, ie. bash.
>>
>>> In same time, Ubuntu says that from next
>>> release want to have only Python 3.
>> Since only RHEL, CentOS and SLES are supported, should we really care
>> about python versions in Ubuntu?
>> When installing Lustre in Ubuntu, users already have to do their own
>> packaging, so I'm not sure that having to install a specific version
>> of a scripting language would make much of a difference.
>>
>>> Now Lustre tests compatibility for wide set of system is solved by shell and
>>> standard utilities. Perl also has great
>>> compatibility history, many scripts could work on latest version as 10 years
>>> ago. It is reason why I see Perl as
>>> good decision.
>> So what's wrong with bash again? If it's just "too flexible, easy to
>> abuse", I'm afraid there's little in Perl to prevent falling into the
>> same pitfalls. :)
>>
>> Cheers,
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
