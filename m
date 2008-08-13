From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Wed, 13 Aug 2008 14:32:01 +0800
Subject: [Lustre-devel] Completion callbacks
In-Reply-To: <48A2769E.1060001@sun.com>
References: <7B72F4D61F2D44C6ADCCF1BC952B9365@ebpc> <48A2769E.1060001@sun.com>
Message-ID: <48A27FE1.8080208@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Liang Zhen ??:
>
> 2. we change ptlrpc_master_callback so that: it makes a copy of EV and 
> queue it in a
> FIFO and return, another thread process ev's in this FIFO and callback 
> one by one and
> we can guarantee events order and call real callbacks without lnet_lock
>   

We can even have an eq_callback_thread (or threads pool) in LNet,
lnet_enq_event_locked() enqueue event and wakeup the callback_thread,
so we don't need change ptlrpc at all.

>
> -devel
>   
