From: wangdi <di.wang@whamcloud.com>
Date: Wed, 15 Jun 2011 12:10:56 -0700
Subject: [Lustre-devel] extremely slow reads at 1024 procs
In-Reply-To: <4DF7F2B7.1010606@llnl.gov>
References: <4DF7F2B7.1010606@llnl.gov>
Message-ID: <4DF903C0.4050100@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 06/14/2011 04:45 PM, Dave Hysom wrote:
> All,
>
> I've just joined to list and will be searching the archives in case
> this has been addressed before -- so please point me to a past
> thread as appropriate.
>
> Scenario:
>
> We have ~100K files.  Each is 8Mb.  Each is read once, by a single
> processor, using fread.  Once we reach a certain number of processors
> (512 or 1024) some of the reads take enormous amounts of time, up to
> 15 minutes.  Our files have stripe=2, which I'm told should be adequate.
> Our application is I/O intensive.
>
> Has anyone had similar experience, and/or have a clue what might be
> going on, and/or let me know what additional details I should include?

How many processors(read threads?) on each client? What is the offset 
and bytes (> 1M) for each read in your application? Are they align with 
the stripe_size. Sometimes, Lustre read is very sensitive to these 
factors, especially for read intense application. These are steps you 
can try,

1. Check those read parameters of your application. bytes should >= 1M, 
and offset is better to be align with the stripe_size.

2. Check whether these files are distributed evenly over all OSTs?

3. Check rpc stats on client side(lctl get_param osc.*.rpc_stats) to see 
the quality of RPCs. Probably increase max_read_ahead_whole_mb and 
max_read_ahead_per_file_mb (lctl set_param llite.*.max_read_ahead_mb = XXX).

4. Disable read_cache on OST. (lctl conf_param 
lustre-OST000X.ost.read_cache_enable = 0), since it only read once.
     Or  shrink the readcache_max_filesize <8M  
(/proc/fs/lustre/obdfilter/lustre-OST0000/readcache_max_filesize = XXX).

5. There is a fix about read offset aligned 
(http://jira.whamcloud.com/browse/LU-15) landed in 1.8.6, which will 
probably help as well.

But doing 3, 4 needs to be sysadmin, and will likely affect other users. 
not sure you can do that.

Thanks
Wangdi

> thanks, David
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
