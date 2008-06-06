From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 20:29:48 -0700
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <1F3456C3-7172-4762-93DB-8589B44189D2@Sun.COM>
Message-ID: <C46DFD3C.587B%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Why can we not send early replies?


On 6/5/08 9:59 AM, "Oleg Drokin" <Oleg.Drokin@Sun.COM> wrote:

> Hello!
> 
> On Jun 5, 2008, at 12:42 PM, Robert Read wrote:
> 
>>>> I suspect this could be adapted to allowing a fixed number of
>>>> retries for
>>>> server-originated RPCs also.  In the case of LDLM blocking callbacks
>>>> sent
>>>> to a client, a resend is currently harmless (either the client is
>>>> already
>>>> processing the callback, or the lock was cancelled).
>>> We need to be careful here and decide on a good strategy on when to
>>> resend.
>>> E.g. recent case at ORNL (even if a bit pathologic) is they pound
>>> through
>>> thousands of clients to 4 OSSes via 2 routers. That creates request
>>> waiting
>>> lists on OSSes well into tens of thousands. When we block on a lock
>>> and send
>>> blocking AST to the client, it quickly turns around and puts in his
>>> data...
>>> at the end of our list that takes hundreds of seconds (more than
>>> obd_timeout,
>>> obviously). No matter how much you resend, it won't help.
>> This looks like the poster child for adaptive timeouts, although we
>> might want need some version of the early margin update patch on
>> 15501.  Have you tried enabling AT?
> 
> The problem is AT does not handle this specific case, there is no way to
> deliver "early replay" from a client to server that "I am working on
> it" outside of
> just sending dirty data. But dirty data gets into a queue for way too
> long.
> There re no timed out requests, the only thing timing out is lock that
> is not
> cancelled in time.
> AT was not tried - this is hard to do at ORNL, as client side is Cray
> XT4 machine,
> and updating clients is hard. So they are on 1.4.11 of some sort.
> They can easily update servers, but this won't help, of course.
> 
>> Maybe that's was done to discourage people from disabling AT?
>> Seriously, though, I don't know why that was changed. Perhaps it was
>> done on b1_6 before to AT landed?
> 
> hm, indeed. I see this change in 1.6.3.
> 
> Bye,
>      Oleg
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
