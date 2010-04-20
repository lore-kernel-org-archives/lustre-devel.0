From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 19 Apr 2010 20:34:36 -0600
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <201004192230.48196.andrew.perepechko@sun.com>
References: <201004192230.48196.andrew.perepechko@sun.com>
Message-ID: <5395043C-A24E-46B0-9E63-5F4DB570DDFD@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

One thing we can do to improve this situation a bit is to return any  
previous write error codes at close time.

Cheers, Andreas

On 2010-04-19, at 12:30, Andrew Perepechko <Andrew.Perepechko@Sun.COM>  
wrote:

> Some applications expect non-zero errno on close() for any errors  
> that may
> happen during flushing dirty cached data/metadata even though linux  
> manual
> page for close(2) suggests that fsync(2) should be used prior to  
> close(2) in
> order to detect problems like those.
>
> Since syncing may degrade performance to a large extent, what do you  
> think is
> the best/most convenient/least intrusive way to switch to that  
> behaviour?
> Should it be a mount option for the client or anything else?
>
> Andrew.
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
