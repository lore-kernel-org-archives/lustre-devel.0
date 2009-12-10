From: Andreas Dilger <adilger@sun.com>
Date: Thu, 10 Dec 2009 00:33:25 -0700
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <1260341830.9521.132.camel@berloga.shadowland>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
	<5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
	<1260335244.9521.114.camel@berloga.shadowland>
	<20C3E301-9A42-47D9-A1A7-BA06814D396F@sun.com>
	<1260341830.9521.132.camel@berloga.shadowland>
Message-ID: <5F06E9CF-6386-4809-A6B1-1DA61502EC20@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-08, at 23:57, Alexey Lyashkov wrote:
> On Tue, 2009-12-08 at 23:35 -0700, Andreas Dilger wrote:
>> On 2009-12-08, at 22:07, Alexey Lyashkov wrote:
>>> This can be something similar as
>>
>>>
>>>    pattern $name $pool_name $operation [$stripe_size  
>>> [$stripe_count]]
>>
>> Please do not use positional parameters.  That makes it nearly
>> impossible to change the input format in the future, or to skip some
>> fields and leave them as defaults.  This needs to use getopt() and
>> named parameters:
>>
>>  --pool=pool_name, --stripe_size=N,  --stripe_count=N
>
> This possible, but unlikely. because need will be save current pool
> name, instead have parsed as single command.
>
> And I don't have plan to rewrite loadgen to use getopt, instead of
> current Parser() function which is used in lctl, lfs, and other.

Note that the existing parser function passes argc, argv to the helper  
function, which is free to use getopt() or getopt_long() internally as  
desired.  See, for example, lustre/utils/lfs.c::lfs_setstripe(), which  
handles the parsing of "lfs setstripe --count N --pool {pool} ...".

> How about this style
>>
> pool $name { targets:"OST1, OST2" }
> pattern $pat { stripe_count:X stripe_size:Y block_size:Z };
> clients $pattern { count:XX pattern: pat shared }


I have no objection to splitting up the functionality into multiple  
sub-commands.  Allowing declarations of pools and patterns that are re- 
used for each client definition makes a lot of sense.

What I dislike is the introduction of a completely new input format  
and parsing engine for no apparent benefit.  Why not change the above  
to:

loadgen> pool --targets="OST1,OST2,..." NAME
loadgen> pattern --stripe_count=X --stripe_size=Y --block_size=Z PATTERN
loadgen> clients --count=XX --pattern=PATTERN ...

and use well-known input conventions?

It also makes sense to look at how LNET Self Test handles the setup of  
testing loads, and try and make the loadgen usage similar to that, as  
much as possible?

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
