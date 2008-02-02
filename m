From: Eric Barton <eeb@sun.com>
Date: Sat, 02 Feb 2008 06:39:14 +0000
Subject: [Lustre-devel] Reducing amount of glimpses
In-Reply-To: <A1C83110-58BF-43A2-88F3-68C6C53BFB6C@sun.com>
References: <A1C83110-58BF-43A2-88F3-68C6C53BFB6C@sun.com>
Message-ID: <00dc01c86566$54235390$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg,

Reduction (as you describe) is an absolutely essential strategy
to achieve scalability.  So without having checked through all the
details of your idea, it feels like absolutely the right solution.

If your idea not only changes latencies but also significant orderings,
I'll feel less secure.  Have you thought it all through?

    Cheers,
              Eric

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org 
> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of 
> Oleg Drokin
> Sent: 02 February 2008 6:27 AM
> To: lustre-devel at clusterfs.com
> Subject: [Lustre-devel] Reducing amount of glimpses
> 
> Hello!
> 
>     Doing some large scale testing at ORNL, interesting 
> pattern came up.
>     Suppose we are doing large-scale IOR testing on a shared file.
>     Some unlucky client does its writing at highest offset 
> (or, at the  
> beginning,
>     was unlucky enough to grab whole-object PW lock).
>     As other clients do their writes, they would do glimpses 
> first to  
> find out file
>     size. Now those glimpses turn into thousands of glimpse requests  
> to that poor
>     client. And many of them actually coming in parallel.
>     So I was thinking - perhaps it would be nice for a  
> filter_intent_policy() to check
>     if there are any glimpse requests being in flight to that client  
> already for that
>     same lock, and if there are, just wait for the request to return  
> and use data from
>     there?
>     Of course potential caveat here is that we have no way to 
> tell if  
> the request reached
>     client by the time we started our processing or not, and so  
> potentially we might get
>     size data that is a bit stale, but I wonder if this is critical  
> enough in our case?
> 
>     Any ideas?
> 
> Bye,
>      Oleg
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
