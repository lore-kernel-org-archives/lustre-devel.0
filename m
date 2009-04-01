From: Nic Henke <nic@cray.com>
Date: Wed, 01 Apr 2009 07:55:38 -0500
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
Message-ID: <49D3644A.9090001@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin wrote:
> Hello!
>
>    It came to my attention that seastar network does not implement  
> message priorities for various reasons.
>    I really think there is very valid case for the priorities of some  
> sort to allow MPI and other
>    latency-critical traffic to go in front of bulk IO traffic on the  
> wire.
>   
In the ptllnd, the bulk traffic is setup via short messages, so if the
barrier is sent right after the write() returns, it really isn't backed
up behind the bulk data.

>    Consider this test I was running the other day on Jaguar. The  
> application writes 250M of data from every
>    core with plain write() system call, the write() syscall returns  
> very fast (less than 0.5 sec == 400+Mb/sec
>    app-perceived bandwidth) because the data just goes to the memory  
> cache to be flushed later.
>    Then I do 2 barriers one by one with nothing in between.
>    If I run it at sufficient scale (say 1200 cores), the first barrier  
> takes 4.5 seconds to complete and
>    the second one 1.5 seconds, all due to MPI RPCs being stuck behind  
> huge bulk data requests on the clients,
>    presumably (I do not have any other good explanations at least).
>    This makes for a lot of wasted time in applications that would like  
> to use the buffering capabilities provided
>    by the OS.
>   
This sounds much more like barrier jitter than backup. The network is
capable of servicing the 250M in < .15s. It would be my guess that some
of the writes() are taking longer than others and this is causing the
barrier to be delayed.

A few questions:
- how many OSS/OSTs are you writing to ?
- can you post the MPI app you are using to do this ?

The application folks @ ORNL should be able to help you use Craypat or
Apprentice to get some runtime data on this app to find where the time
is going. Until we have hard data, I don't think we can blame the network.

Cheers,
Nic
