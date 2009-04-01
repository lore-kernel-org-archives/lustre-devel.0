From: Andrew C. Uselton <acuselton@lbl.gov>
Date: Tue, 31 Mar 2009 22:10:00 -0700
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
Message-ID: <49D2F728.80008@lbl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I wonder if that scenario may have some bearing on the results I've 
mentioned at:

	http://www.nersc.gov/~uselton/frank_jag/

It would be interesting to step through the logic if anyone is 
interested in doing so.  The web page itself is terse, so feel free to 
bug me for details if you have not seen this before.
Cheers,
Andrew


Oleg Drokin wrote:
> Hello!
> 
>    It came to my attention that seastar network does not implement  
> message priorities for various reasons.
>    I really think there is very valid case for the priorities of some  
> sort to allow MPI and other
>    latency-critical traffic to go in front of bulk IO traffic on the  
> wire.
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
>    Do you think something like this could be organized if not for  
> current revision then at least for the next
>    version?
> 
> Bye,
>      Oleg
>   
>   
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
