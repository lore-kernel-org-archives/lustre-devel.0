From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Fri, 4 Dec 2009 21:19:27 +0300
Subject: [Lustre-devel] Lustre client I/O
In-Reply-To: <4B1873C7.3060600@sun.com>
References: <8acda98c0912031432j5747b1aaxeb49ec27885fbeaf@mail.gmail.com>
	<4250440D-BD4C-43D8-B619-86AA0F59ED2D@Sun.COM>
	<4B1873C7.3060600@sun.com>
Message-ID: <8acda98c0912041019m7bec896cp71e582325cc9066b@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

[Lustre-devel copied.]

Hello,

see comments below.

2009/12/4 jay <Jinshan.Xiong@sun.com>:
> Oleg Drokin wrote:
>>
>> Hello!
>>
>> On Dec 3, 2009, at 5:32 PM, Nikita Danilov wrote:
>>
>>
>>>
>>> Hello Oleg,
>>>
>>> Peter Braam told me you pointed him to some issues with CLIO. Could
>>> you provide details? I am probably owing an explanation of why things
>>> were done in this or that way. May be on lustre-devel?
>>>
>>
>> ? Actually I did not dig too much into details myself yet.
>> Jay and WangDi are the best people to ask about specific deficiencies,
>> I think I remember there were mentioned some missed state machine states,
>> then clio takes locks in random order for the same file, so it was
>> deadlock prone.
>> See bug 19906 for some of that. There are many more.
>>
>
> Mostly implementation defects. For 19906, it turns out to be lack of error
> handling at some point, for example, if lock wait fails, we have to
> de-referenced the enqueued sublocks.
>
>> I did some measurements and it is very slow too, over 30% slower than b1_8
>> code
>> for the case of local access.
>>
>
> We've never done any performance tune against clio.
>>
>> Certain questions are raised by Eric Barton if we ever need another cache
>> for compound locks if we already have ldlm cache for locks, since that
>> other
>> cache adds a lot of complications too. And I sort of agree the current
>> clio code
>> looks like a total overkill and very complicated.
>>
>
> Yes, the two-level cached lock mechanism makes cl_lock extremely complex and
> fragile - it can be simplified by removing the top level cache.

I agree that caching top- and bottom- locks adds considerable
complexity. Performance advantages of caching alone probably cannot
justify it. On the other hand, removing top-lock caching only makes
sense when layering is fixed: in a general IO stack layers must have
uniform caching behaviour.

>
> CLIO is still in its childhood, it has never been verified at customer's
> side. It's quite common that we meet new problems when running a new test
> suite. As a matter of fact, most clio bugs were found in new test suites -
> we don't have new issues in these days, because no new test suite is
> introduced.
>
> Before diving into the good and bad side of clio, let's check up what's the
> initiatives of having clio, and whether we have reached those targets or not
> in current implementation. We don't need to focus on those defects in
> implementation.
> This is the design goals of clio:
>
> clear layering;
> controlled state sharing;
> simplified layer interface;
> real stacking;
> reuse of mdt server layering;
> improving portability.

Those are mostly achieved. "Mostly" because few things, like
read-ahead, are still at a wrong level. As an example of advantages of
improved layering, implementation of lock-less IO in CLIO re-uses the
same code paths as a normal caching IO: DLM interaction details are
encapsulated within osc and it is possible to substitute "surrogate
locks" there without rest of the stack noticing. (As a note, CLIO
lock-less IO doesn't currently handle sub-page lockless read as
efficiently as 1.8, because it fetches the whole page from the server
first, but this is easy to fix or maybe it is already fixed.)

> support for:
> ?SNS;
> ?read-only p2p caching;
> ?lock-less IO and ost intents;
>
>> Feel free to add lustre-devel at any point.

One of the more confusing parts of CLIO is its file and stripe lock
implementation, even putting top-lock caching aside for a moment.
There are, I think, two main reasons for this:

    * locks are implemented as non-blocking state machines. This is
rather unusual and definitely not common programming style looking
somewhat inside-out-ish at first sight. The justification for this is
support for a "parallel IO", i.e., a mode where a write, instead of
blocking on a full per-OST cache, proceeds to the next stripe. The
upside is that once non-blocking infrastructure is in place in cl_lock
and cl_io, many other interesting things, like concurrent copy_*_user
and "lock-ahead", are easier to do;

    * concurrency control for cl_lock is fiendishly difficult. I now
think it was a mistake to strive for finer-grained locking. Eric
Barton noted that a lock on a top-object could protect state of all
locks on the object and its sub-objects. This would greatly simplify
things without intolerable decrease in concurrency.

>>
>> Bye,
>> ? ?Oleg
>>

Thank you,
Nikita.

>
>
