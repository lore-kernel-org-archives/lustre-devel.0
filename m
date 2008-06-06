From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 20:37:22 -0700
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <C756F41E-2CF2-4DAD-9920-F1CB2A2BECA6@sun.com>
Message-ID: <C46DFF02.587F%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 6/5/08 9:42 AM, "Robert Read" <rread@sun.com> wrote:

> 
> On Jun 4, 2008, at 21:12 , Oleg Drokin wrote:
> 
>> Hello!
>> 
>> On Jun 4, 2008, at 6:20 PM, Andreas Dilger wrote:
>> 
>>> I suspect this could be adapted to allowing a fixed number of
>>> retries for
>>> server-originated RPCs also.  In the case of LDLM blocking callbacks
>>> sent
>>> to a client, a resend is currently harmless (either the client is
>>> already
>>> processing the callback, or the lock was cancelled).
>> 
>> We need to be careful here and decide on a good strategy on when to
>> resend.
>> E.g. recent case at ORNL (even if a bit pathologic) is they pound
>> through
>> thousands of clients to 4 OSSes via 2 routers. That creates request
>> waiting
>> lists on OSSes well into tens of thousands. When we block on a lock
>> and send
>> blocking AST to the client, it quickly turns around and puts in his
>> data...
>> at the end of our list that takes hundreds of seconds (more than
>> obd_timeout,
>> obviously). No matter how much you resend, it won't help.
> 

I think this is an SNS issue.  Eric?

Peter


> 
> This looks like the poster child for adaptive timeouts, although we
> might want need some version of the early margin update patch on
> 15501.  Have you tried enabling AT?
> 
>> 
>> Now a good argument is before we kill such clients (or do any sort of
>> resend),
>> perhaps it makes sense to check incoming queue to see if there is
>> anything?
>> On the other hand that would be like half of request scheduler,
>> probably, and
>> with such queues, it would take ages, I guess.
>> BTW, AT code changes lock waiting from obd_timeout to obd_timeout/2,
>> why is that?
>> (when AT is disabled). All this is bug 15332.
>> 
> 
> Maybe that's was done to discourage people from disabling AT?
> Seriously, though, I don't know why that was changed. Perhaps it was
> done on b1_6 before to AT landed?
> 
> robert
> 
> 
>> Or was the resend meant just for initial RPC where we do not get a
>> confirmation
>> soon? Yes, there it makes sense to retry soon, but this case above
>> needs to be
>> still considered, since currently we do not retry writeouts too, which
>> has as
>> much of a bad effect on dirty client caches, and of course all the
>> above is very
>> true in such cases too.
>> Also without lnet patch in 15332, where small messages are prioritized
>> on routers,
>> it is way too easy to timeout ast response because of router
>> congestion and no
>> amount of resending would help then.
>> 
>> Bye,
>>     Oleg
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
