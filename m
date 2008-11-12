From: Robert Latham <robl@mcs.anl.gov>
Date: Wed, 12 Nov 2008 11:35:48 -0600
Subject: [Lustre-devel] [Lustre-discuss] a new Lustre ADIO driver
In-Reply-To: <49114151.10908@sun.com>
References: <49110B1A.5030201@sun.com> <49114151.10908@sun.com>
Message-ID: <20081112173548.GC16693@mcs.anl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Nov 05, 2008 at 02:46:41PM +0800, emoly.liu wrote:
> Hi,
>
> Here is some description and performance results for the new Lustre ADIO  
> driver. You might be interested.
>
> The main purpose of the new lustre adio driver is to collect the small  
> size I/O requests into fewer number of larger ones according to Lustre's  
> striping feature with low overhead automatically. We also provide some  
> hints for performance tuning.
>
> In the following graph, the recent FLASH I/O benchmarking result shows  
> that the new driver performs much better than the old one, especially  
> for a large-scale system.
> In this test, FLASH I/O blocksize is 4*4*4 that means each 3 clients  
> write 40KB, 40.5KB and 42KB respectively. The I/O operation iteration  
> (nvar) is set to 1024.

Hi LiuYing

Since this patch is for ROMIO and not really for Lustre, could you
send this to romio-maint at mcs.anl.gov ?  It will reach more of the
ROMIO developers that way.

Thanks
==rob

-- 
Rob Latham
Mathematics and Computer Science Division    A215 0178 EA2D B059 8CDF
Argonne National Lab, IL USA                 B29D F333 664A 4280 315B
