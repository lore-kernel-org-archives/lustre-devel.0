From: Oleg Drokin <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:13:02 -0500
Subject: [lustre-devel] [PATCH v2 60/84] staging/lustre/llite: Fix style
	vs open parenthesis alignment
In-Reply-To: <20160226061016.GA3356@kroah.com>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
	<1456369267-904461-61-git-send-email-green@linuxhacker.ru>
	<20160226061016.GA3356@kroah.com>
Message-ID: <DB7D7B71-C3BB-4610-BBC0-A9294BA4C621@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Feb 26, 2016, at 1:10 AM, Greg Kroah-Hartman wrote:

> On Wed, Feb 24, 2016 at 10:00:43PM -0500, green at linuxhacker.ru wrote:
>> From: Oleg Drokin <green@linuxhacker.ru>
>> 
>> This mostly fixes checkpatch complaints about
>> "Alignment should match open parenthesis"
>> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> 
> This patch doesn't apply to the tree, so I've stopped applying this
> series here.  Please rebase and resend the rest of these.

It does not apply because of the NFS/fhandle patch that I was hoping you'll land
since it seems to have gotten the ACK you asked for.

I can rebase without that patch, but how do I get that other one accepted then?
http://permalink.gmane.org/gmane.linux.nfs/76298

Thanks.
