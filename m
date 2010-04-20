From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 19 Apr 2010 22:04:12 -0600
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <201004192230.48196.andrew.perepechko@sun.com>
References: <201004192230.48196.andrew.perepechko@sun.com>
Message-ID: <1E9320D1-3FC9-4F5F-889E-7A68CC7A4C08@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-04-19, at 12:30, Andrew Perepechko wrote:
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


If the application is expecting the "flush all outstanding data"  
semantics of fsync() on close, it should just call fsync() and use the  
return code of that instead of overloading close() to do it.  There  
will be no worse performance by waiting for fsync() to complete, than  
waiting for a close that is flushing all of the data.

In contrast, if an application is NOT expecting synchronous flushing  
on close, then making every close flush all data WILL be a major  
performance impact.  Better to have applications do what they mean,  
and system calls do what they are supposed to, instead of adding in  
extra semantics that not every application wants.

Also, as Oleg wrote, if an application is doing close/open when it is  
really just trying to flush the data to disk (which I saw some traces  
of recently) then this is even WORSE than just doing an fsync().

Cheers, Andreas
--
Andreas Dilger
Principal Engineer, Lustre Group
Oracle Corporation Canada Inc.
