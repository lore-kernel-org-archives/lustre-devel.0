From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 23 May 2015 00:07:42 +0000
Subject: [lustre-devel] [PATCH v4 10/13] staging: lustre: lnet: lnet:
 checkpatch.pl fixes
In-Reply-To: <1432339030.29657.20.camel@perches.com>
References: <1432237849-53947-1-git-send-email-shuey@purdue.edu>
	<1432237849-53947-11-git-send-email-shuey@purdue.edu>
	<1432242004.20840.68.camel@perches.com>
	<alpine.DEB.2.10.1505212328500.5370@hadrien>
	<CABqvwjuKypiacf3336j-q450FGKaO4wh0Ld7PF8MGz0VPsYBbw@mail.gmail.com>
	<alpine.DEB.2.10.1505220704541.2672@hadrien>
	<15C0AFDB-CA69-40E5-B65E-C559A5B5CE47@intel.com>
	<1432309337.29657.16.camel@perches.com>
	<05DE4AF3-20A6-40F6-BAC6-79C140E490AF@intel.com>
	<1432339030.29657.20.camel@perches.com>
Message-ID: <863F0D66-99B1-4658-8A99-E3A843E0E8FC@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On May 22, 2015, at 7:57 PM, Joe Perches wrote:

> On Fri, 2015-05-22 at 21:16 +0000, Drokin, Oleg wrote:
>> On May 22, 2015, at 11:42 AM, Joe Perches wrote:
>> 
>>> On Fri, 2015-05-22 at 08:08 +0000, Drokin, Oleg wrote:
>>>> On May 22, 2015, at 1:06 AM, Julia Lawall wrote:
>>>> 
>>>>> On Thu, 21 May 2015, Michael Shuey wrote:
>>>>> 
>>>>>> That's a task (of many) I've been putting on the back burner until the code
>>>>>> is cleaner.  It's also a HUGE change, since there are debug macros
>>>>>> everywhere, and they all check a #define'd mask to see if they should fire,
>>>>>> and the behavior is likely governed by parts of the lustre user land tools
>>>>>> as well.
>>>>>> 
>>>>>> Suggestions are welcome.  Do other parts of the linux kernel define complex
>>>>>> debugging macros like these, or is this a lustre-ism?  Any suggestions on
>>>>>> how to handle this more in line with existing drivers?
>>>>> 
>>>>> Once you decide what to do, you can use Coccinelle to make the changes for
>>>>> you.  So you shouldn't be put off by the number of code sites to change.
>>>>> 
>>>>> The normal functions are pr_err, pr_warn, etc.  Perhaps you can follow
>>>>> Joe's suggestions if you really need something more complicated.
>>>> 
>>>> Ideally leaving CERROR/CDEBUG in Lustre would be desirable from my perspective.
>>> 
>>> My issue with CERROR is the name is little misleading.
>>> It's actually a debugging message.
>>> #define CERROR(format, ...)  CDEBUG_LIMIT(D_ERROR, format, ## __VA_ARGS__)
>> 
>> Except it's not a debugging message.
>> There is a clear distinction.
> 
> Not really.  If the first reading sjows that the mechanism it
> goes through is called CDEBUG, a reasonable expectation should
> be that it's a debugging message.

Well, various pr_err/pr_dbg for example, go through printk in the end too.
Do that make them the same?

> 
>> CERROR is something that get's printed on the console, because it's believed
>> to be serious error (At least that's how the theory for it's usage goes).
>> It also gets rate-limited so that the console does not get overflown.
>> (but the debug buffer gets the full version).
>> (there's also LCONSOLE that always get's printed, but it does not get the
>> prefixes like line numbers and stuff).
>> 
>> CDEBUG on the other hand is a debugging message (of which ERROR messages are
>> sort of a subset (D_ERROR mask)). You can fine-tune those to be noops or
>> to go into console or to debug buffer only. Most of those are doing nothing
>> because they are off in the default debug mask, until actually enabled.
>> 
>> That CERROR usees CDEBUG underneath is just to share some common infrastructure.
>> 
>>> I think it'd be clearer as
>>> 	lustre_debug(ERROR, ...
>>> even if the name and use style is a little longer.
>> 
>> I wonder what is more clear about that in your opinion ve
>> lustre_error/lustre_debug?
> 
> The fact that you have to explain this shows that it's
> at least misleading unless you completely understand the
> code.

Or you know, you might take the function name at the face value
and assume that CERROR means it's an error and CDEBUG means it's a debug message?

> It'd be more intelligible if this CERROR became lustre_err
> and the actual debugging uses were lustre_dbg

But the actual underlying call is hidden by the macro anyway and you never
get to see it. You see CDEBUG/CERROR and how is that different
from lustre_debug/lustre_err?


> Perhaps it needs a better explanation somewhere not in the
> code but in some external documentation.  I haven't looked.
> 
