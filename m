From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 6 Dec 2016 10:34:03 -0500
Subject: [lustre-devel] Remaining work needed for moving Lustre out of
	staging
In-Reply-To: <20161203085550.GA5375@kroah.com>
References: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
	<20161203085550.GA5375@kroah.com>
Message-ID: <0F617FFB-4BD0-4477-890B-2CDC56436DCC@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@linuxfoundation.org
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "jsimmons@infradead.org" <jsimmons@infradead.org>


On Dec 3, 2016, at 3:55 AM, gregkh at linuxfoundation.org wrote:

> On Fri, Dec 02, 2016 at 09:53:08PM +0000, Dilger, Andreas wrote:
>> Al,
>> Greg recently raised the issue of what still needs to be done to
>> move the Lustre code out of staging/ and into the fs/ tree. 
>> 
>> James has been doing a great job of cleaning up various checkpatch
>> issues and keeping the code updated with the latest fixes, but we
>> were wondering what you were aware of that needed to be cleaned
>> up in Lustre?
> 
> Is the whole "mixing kernel structures in userspace structures" all
> resolved now?  For some reason I thought that you had kernel locks being
> passed to userspace and then back into the kernel, but it's been a long
> time since I last looked...

While we certainly had our share of mixing user/kernelspace structures,
I don't think we ever passed anything with locks around back and forth.

I just did a brief check and I don't see anything glaring on this particular front.

> If you feel you are ready for a "real" review, I'll be glad to go over
> the code before the vfs people look at it, just let me know.  No need to
> bother them if you still have basic things wrong that I can find?

I think this would be beneficial at this stage.
Thanks.

Bye,
    Oleg
