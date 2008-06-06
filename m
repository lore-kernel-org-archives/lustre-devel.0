From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 06 Jun 2008 06:23:30 -0600
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <20080606044135.GJ2961@webber.adilger.int>
Message-ID: <C46E8862.589F%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Sorry yes, network request scheduling; which is btw the most basic instance
of a secondary resource management protocol as Eric described in his post.

Peter


On 6/5/08 10:41 PM, "Andreas Dilger" <adilger@sun.com> wrote:

> On Jun 05, 2008  20:40 -0700, Peter J. Braam wrote:
>> Ah yes.  So monitoring progress is the only thing we can do and with SNS you
>> will be able to get that information long before the request is being
>> handled.
> 
> You mean NRS, instead of SNS, right?
> 
>> On 6/5/08 8:38 PM, "Oleg Drokin" <Oleg.Drokin@Sun.COM> wrote:
>>>     Because there is no way to deliver them. We send our first
>>> acknowledge of ast reception and it is delivered fast, this is the
>>> reply.
>>>     Now what left is to send actual dirty data and then cancel
>>> request. These are not replies, but stand-alone client-generated RPCs,
>>>     we cannot cancel locks while dirty data is not flushed. Just
>>> inventing some sort of ldlm "I am still alive" RPCs to send periodically
>>>     instead of cancels is dangerous - data-sending part could be
>>> wedged for unrelated reasons, for example, not only because of
>>> contention, but due
>>>     to some client problems, and if we prolong locks by other means,
>>> that potentially can wedge all access to that part of a file forever.
>>>     And dirty data itself takes too long to get to the actual server
>>> processing.
>>>     On of the solutions here is request scheduler, or some stand-alone
>>> part of it that could peek early into RPCs as they arrive, so that
>>>     when the decision is being made about client eviction, we can
>>> quickly see what is in the queue from that client and perhaps
>>>     based on this data to postpone the eviction. This was discussed on
>>> ORNL call.
>>>     Andreas said that AT is currently already looking into incoming
>>> RPCs before processing, to get ideas about expected service times,
>>> perhaps
>>>     it would not be too hard to add some logic that would link
>>> requests into actual exports they came from for further analysis if
>>> the need for
>>>     it arises.
> 
> I think hooking the requests into the exports at arrival time is fairly
> straight forward, and is a easy first step toward implementing the NRS.
> 
>>> Bye,
>>>      Oleg
>>> On Jun 5, 2008, at 11:29 PM, Peter Braam wrote:
>>> 
>>>> Why can we not send early replies?
>>>> 
>>>> 
>>>> On 6/5/08 9:59 AM, "Oleg Drokin" <Oleg.Drokin@Sun.COM> wrote:
>>>> 
>>>>> Hello!
>>>>> 
>>>>> On Jun 5, 2008, at 12:42 PM, Robert Read wrote:
>>>>> 
>>>>>>>> I suspect this could be adapted to allowing a fixed number of
>>>>>>>> retries for
>>>>>>>> server-originated RPCs also.  In the case of LDLM blocking
>>>>>>>> callbacks
>>>>>>>> sent
>>>>>>>> to a client, a resend is currently harmless (either the client is
>>>>>>>> already
>>>>>>>> processing the callback, or the lock was cancelled).
>>>>>>> We need to be careful here and decide on a good strategy on when to
>>>>>>> resend.
>>>>>>> E.g. recent case at ORNL (even if a bit pathologic) is they pound
>>>>>>> through
>>>>>>> thousands of clients to 4 OSSes via 2 routers. That creates request
>>>>>>> waiting
>>>>>>> lists on OSSes well into tens of thousands. When we block on a lock
>>>>>>> and send
>>>>>>> blocking AST to the client, it quickly turns around and puts in his
>>>>>>> data...
>>>>>>> at the end of our list that takes hundreds of seconds (more than
>>>>>>> obd_timeout,
>>>>>>> obviously). No matter how much you resend, it won't help.
>>>>>> This looks like the poster child for adaptive timeouts, although we
>>>>>> might want need some version of the early margin update patch on
>>>>>> 15501.  Have you tried enabling AT?
>>>>> 
>>>>> The problem is AT does not handle this specific case, there is no
>>>>> way to
>>>>> deliver "early replay" from a client to server that "I am working on
>>>>> it" outside of
>>>>> just sending dirty data. But dirty data gets into a queue for way too
>>>>> long.
>>>>> There re no timed out requests, the only thing timing out is lock
>>>>> that
>>>>> is not
>>>>> cancelled in time.
>>>>> AT was not tried - this is hard to do at ORNL, as client side is Cray
>>>>> XT4 machine,
>>>>> and updating clients is hard. So they are on 1.4.11 of some sort.
>>>>> They can easily update servers, but this won't help, of course.
>>>>> 
>>>>>> Maybe that's was done to discourage people from disabling AT?
>>>>>> Seriously, though, I don't know why that was changed. Perhaps it was
>>>>>> done on b1_6 before to AT landed?
>>>>> 
>>>>> hm, indeed. I see this change in 1.6.3.
>>>>> 
>>>>> Bye,
>>>>>     Oleg
>>>>> _______________________________________________
>>>>> Lustre-devel mailing list
>>>>> Lustre-devel at lists.lustre.org
>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>> 
>>>> 
>>> 
>> 
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
