From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 13 Aug 2008 16:28:33 -0600
Subject: [Lustre-devel] Completion callbacks
In-Reply-To: <48A2BFD3.2070900@sun.com>
Message-ID: <C4C8BC31.6CC1%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think it's a requirement that software using the API's is not aware of
this (ie no significant changes in ptlrpc).  As long as the solution is
compatible with that, this looks fine.

Peter


On 8/13/08 5:04 AM, "Maxim V. Patlasov" <Maxim.Patlasov@Sun.COM> wrote:

> Folks,
> 
>> Liang Zhen ??:
>>   
>>>> 
>>>> 2. we change ptlrpc_master_callback so that: it makes a copy of EV and
>>>> queue it in a
>>>> FIFO and return, another thread process ev's in this FIFO and callback
>>>> one by one and
>>>> we can guarantee events order and call real callbacks without lnet_lock
>>>>   
>>>     
>> 
>> We can even have an eq_callback_thread (or threads pool) in LNet,
>> lnet_enq_event_locked() enqueue event and wakeup the callback_thread,
>> so we don't need change ptlrpc at all.
>>   
> 
> I dislike the idea of introducing any additional callback-devoted
> threads because 1) it would spoil the original design of callbacks as
> light-weight notifications and 2) introduce additional latency. I'd
> prefer to see per-MD locks (or per-EQ array of locks, that's quite
> equivalent) to serialize calling callbacks associated with any
> particular MD. This approach looks more natural and "right" than
> inventing callback-threads.
> 
> Sincerely,
> Maxim
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
