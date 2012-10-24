From: Roman Grigoryev <roman_grigoryev@xyratex.com>
Date: Wed, 24 Oct 2012 10:31:58 +0400
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <5086F285.6000809@cea.fr>
References: <9E235E88-FAD1-44BF-A4DC-12A5801E0467@xyratex.com>
	<5086F285.6000809@cea.fr>
Message-ID: <50878B5E.1090600@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi JC, all,

I should say more words about compatibility.

In comparing with server-only tools(which are often pretty good
maintained and controlled
on limited node set),  test tools often work on wider sets. Minimally,
it should work
on some clients and  also on clients with different versions then
servers, include clients in real clusters,
developers virtual clusters and so on.

As I know, Lustre users could have environment with Lustre latest
servers and  1.8 clients,
some companies use RedHat5.x clients and RedHat6.x(SL6.x) server, other
use Ubuntu. 

RH5 has only python2.4, SL61  has python2.4 and python2.6, and looks
like only
last Fedora will have python3. In same time, Ubuntu says that from next
release want to have only Python 3.
Which version should we use and how long backward compatibility will be
supported by Python and distros//for
selected version/?/

Precision Python version could be installed from non standard repos,
compiled from sources also as used
"non standard installation". Last item also mean testing own
installation on wide set of distros. Also we should
remember about external Python libraries which also could be touched by
breaking legacy compatibility.

I think, testing system should be friendly to developers as possible and
pushing to install precision version while
one or more pythons already in os could not be the simplest solution.

Now Lustre tests compatibility for wide set of system is solved by shell
and standard utilities. Perl also has great
compatibility history, many scripts could work on latest version as 10
years ago. It is reason why I see Perl as
good decision.

From compatibility(and my) point of view, also Java is preferable
solution then Python. It has few good described ways
of installation, proved compatibility, great library managers (maven,
ant+ivy) and could support scripting
languages(JPython, JRuby and more).
But it needs more memory and pretty big start time.  

Thanks,
    Roman
On 10/23/2012 11:39 PM, Jacques-Charles Lafoucriere wrote:
> hello all
.......
> about python, what do you mean by non standard installation ?
> if your python configuration is right, the local differences should be
> hidden to the test framework
>
> Bye
>
> JC
>
> On 10/23/2012 08:36 PM, Nathan Rutman wrote:
>> At LAD'12 we proposed a plan for improving the Lustre test framework
>> as an important part of the Lustre quality story.  One of the
>> discussion points there was that the bash language of the current
>> tests was lacking in a variety of areas.  We're moving forward with
>> this work but need community agreement on the best course.  
>>
>> Given the requirements and language options below, the reasonable
>> choices rapidly diminish to a showdown between perl and python.  I
>> think we're leaning at this point toward perl, based on it's superior
>> speed and inter-version compatibility.  The final piece of the puzzle
>> is the knowledge of existing Lustre test writers, so please chime in.
>>  (But note that "popularity" is the reason we chose bash the first
>> time, and look where that got us...)
>>
>> requirements
>> 1. easy to use
>> 2. strict structure
>> 3. universally available
>> 4. widely maintained
>> 5. widely understood
>> 6. good filesystem interface: posix API
>> 7. fast - replace e.g. createmany with embedded function
>> 8. operate remote instances
>> 9. inter-version compatibility
>> options
>> bash - capable, but too flexible, easy to abuse
>> perl - forward compatible, universal, more widely understood,
>> xperior, compact; hard to read later
>> posix::open, opendir, lseek, etc.
>> parallel::MPI
>> ~2x faster than python
>> more version compatible
>> python - very clear structure, swig module for c inclusion;
>> non-standard installations, support
>> os.open: all c flags
>> MPI bindings
>> tab/space requirements make remote editing more difficult
>> cucumber - ruby based, difficult deployment
>> java - easy deployment, dev environ, debugger, fast; must compile
>> ruby - compact
>>
>>
>> http://silicainsilico.wordpress.com/2012/03/26/switching-from-perl-to-python-speed/
>> http://tenser.typepad.com/tenser_said_the_tensor/2006/08/python_vs_perl_.html
>> http://opennomad.com/content/performance-different-scripting-languages-shell-v-perl-v-python-v-ruby
>> http://hentenaar.com/serendipity/index.php?/archives/27-Benchmark-PHP-vs.-Python-vs.-Perl-vs.-Ruby.html
>>
>>
>>
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20121024/75f5193c/attachment.htm>
