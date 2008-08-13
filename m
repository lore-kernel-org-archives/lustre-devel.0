From: Maxim V. Patlasov <Maxim.Patlasov@Sun.COM>
Date: Wed, 13 Aug 2008 15:04:51 +0400
Subject: [Lustre-devel] Completion callbacks
Message-ID: <48A2BFD3.2070900@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Folks,

> Liang Zhen ??:
>   
>> >
>> > 2. we change ptlrpc_master_callback so that: it makes a copy of EV and 
>> > queue it in a
>> > FIFO and return, another thread process ev's in this FIFO and callback 
>> > one by one and
>> > we can guarantee events order and call real callbacks without lnet_lock
>> >   
>>     
>
> We can even have an eq_callback_thread (or threads pool) in LNet,
> lnet_enq_event_locked() enqueue event and wakeup the callback_thread,
> so we don't need change ptlrpc at all.
>   

I dislike the idea of introducing any additional callback-devoted 
threads because 1) it would spoil the original design of callbacks as 
light-weight notifications and 2) introduce additional latency. I'd 
prefer to see per-MD locks (or per-EQ array of locks, that's quite 
equivalent) to serialize calling callbacks associated with any 
particular MD. This approach looks more natural and "right" than 
inventing callback-threads.

Sincerely,
Maxim
