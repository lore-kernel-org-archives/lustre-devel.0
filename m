From: Alexey Lyahkov <alexey_lyashkov@xyratex.com>
Date: Fri, 14 Dec 2012 12:19:03 +0400
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
References: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
Message-ID: <B96EB845-0B4F-42DD-9CDF-FDF358A1BD0F@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Please don't kill a portability code.
We have spend many times in past to introduce it's but now you want to kill that work and make portable to systems other then Linux too hard.
That is wrong way as supporting a compatibility code have no cost.

On Dec 5, 2012, at 17:54, Oleg Drokin wrote:

> Hello!
> 
>   I just landed first patch of the series to reduce usage of our libcfs_ wrappers for kernel primitives like libcfs_spin_lock/unlock...
>   You can see actual change here: http://review.whamcloud.com/#change,2829
> 
>   It's highly likely that plenty of patches will be affected. To make our job easier, there is a
>   build/libcfs_cleanup.sed script included, you can run it on all your .c and .h files to make necessary replacements:
>   sed -i -f build/libcfs_cleanup.sed3  `find . -name "*.h" -or -name "*.c"`
> 
>   Please be also advised that there are more changes like this are coming (timeline is not very clear ATM, we might be able to wait with the rest until
>   after feature freeze) and the sed script will be updated accordingly.
> 
> Bye,
>    Oleg
> --
> Oleg Drokin
> Senior Software Engineer
> Whamcloud, Inc.
> 

----------------------------------------------
Alexey Lyahkov
alexey_lyashkov at xyratex.com
