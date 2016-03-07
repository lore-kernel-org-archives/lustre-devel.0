From: Simmons, James A. <simmonsja@ornl.gov>
Date: Mon, 7 Mar 2016 19:34:54 +0000
Subject: [lustre-devel] [PATCH 00/10] Last batch of fixes for LNet
In-Reply-To: <20160305195256.GA8126@kroah.com>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
	<20160305195256.GA8126@kroah.com>
Message-ID: <eb04d2ccb6ef4fe98df59ecb9f75afa9@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

>On Fri, Mar 04, 2016 at 09:09:40PM -0500, James Simmons wrote:
>> This batch merges the remaining LNet patches from the OpenSFS
>> branch for the upstream client. Once merged the LNet code
>> will be up to date with the latest production code. Only style
>> issues are remaining. Still future patches being developed
>> for LNet will be landed to the upstream client as soon as they
>> are ready after extensive testing.
>
>Please fix up the build issue, and figure out what went wrong with the
>__user patch that you sent and resend this series after reworking them.

I had a discussion with Oleg about the __user patch. It  appears that is
a bug in the production branch so that patch can be dropped.  As for the
build issues this has been a know issue for a awhile but nobody has
gotten around to fixing all the 32 bit issues. I guess it is time to fix that up.
I will send out new patches later after I'm doing testing them.
