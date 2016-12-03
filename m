From: gregkh at linuxfoundation.org <gregkh@linuxfoundation.org>
Date: Sat, 3 Dec 2016 09:55:50 +0100
Subject: [lustre-devel] Remaining work needed for moving Lustre out of
	staging
In-Reply-To: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
References: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
Message-ID: <20161203085550.GA5375@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "Drokin, Oleg" <oleg.drokin@intel.com>

On Fri, Dec 02, 2016 at 09:53:08PM +0000, Dilger, Andreas wrote:
> Al,
> Greg recently raised the issue of what still needs to be done to
> move the Lustre code out of staging/ and into the fs/ tree. 
> 
> James has been doing a great job of cleaning up various checkpatch
> issues and keeping the code updated with the latest fixes, but we
> were wondering what you were aware of that needed to be cleaned
> up in Lustre?

Is the whole "mixing kernel structures in userspace structures" all
resolved now?  For some reason I thought that you had kernel locks being
passed to userspace and then back into the kernel, but it's been a long
time since I last looked...

If you feel you are ready for a "real" review, I'll be glad to go over
the code before the vfs people look at it, just let me know.  No need to
bother them if you still have basic things wrong that I can find...

thanks,

greg k-h
