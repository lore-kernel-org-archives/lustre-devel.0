From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 20 Feb 2016 14:34:04 -0800
Subject: [lustre-devel] [PATCH 43/45] staging/lustre/libcfs: Replace use
 of printk with pr_<level>
In-Reply-To: <142FFAE8-57BF-4B57-9959-4A1BFB5463AA@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
	<1455601637-3847710-44-git-send-email-green@linuxhacker.ru>
	<1455602117.4046.45.camel@perches.com>
	<142FFAE8-57BF-4B57-9959-4A1BFB5463AA@linuxhacker.ru>
Message-ID: <20160220223404.GA19692@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Joe Perches <joe@perches.com>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Feb 16, 2016 at 11:12:14AM -0500, Oleg Drokin wrote:
> 
> On Feb 16, 2016, at 12:55 AM, Joe Perches wrote:
> 
> > On Tue, 2016-02-16 at 00:47 -0500, green at linuxhacker.ru wrote:
> >> From: Oleg Drokin <green@linuxhacker.ru>
> >> 
> >> This pacifies checkpatch amongst other things, also is shorter to write
> >> and avoiding calls to printk_ratelimit() is also good.
> > []
> >> diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
> > []
> >> @@ -244,11 +244,11 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
> >>  	}
> >>  
> >>  	if ((mask & D_CONSOLE) != 0) {
> >> -		printk("%s%s: %.*s", ptype, prefix, len, buf);
> >> +		pr_err("%s%s: %.*s", ptype, prefix, len, buf);
> >>  	} else {
> >> -		printk("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
> >> -		       hdr->ph_pid, hdr->ph_extern_pid, file, hdr->ph_line_num,
> >> -		       fn, len, buf);
> >> +		pr_warn("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
> >> +			hdr->ph_pid, hdr->ph_extern_pid, file, hdr->ph_line_num,
> >> +			fn, len, buf);
> >>  	}
> >>  }
> > 
> > This breaks the currently correct output.
> 
> Hm, you are right. Thanks!
> I guess this patch just needs some redoing.
> 
> Greg, if you can skip this patch but still apply the rest of the series, that would be great.
> I just tested that the whole thing builds and runs fine with this patch omitted.

Ok, now skipped, thanks.

greg k-h
