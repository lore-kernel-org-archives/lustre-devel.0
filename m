From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Tue, 16 Feb 2016 02:41:43 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Fixed the parenthesis
In-Reply-To: <20160216022812.GA25122@kroah.com>
References: <1455507422-13568-1-git-send-email-shalinmehta85@gmail.com>
	<20160216022812.GA25122@kroah.com>
Message-ID: <6A47AD82-6A8F-44E1-9CB4-C10CF9F9D72E@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Shalin Mehta <shalinmehta85@gmail.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, "<kernel-janitors@lists.osdl.org>" <kernel-janitors@lists.osdl.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, "<lustre-devel@lists.lustre.org>" <lustre-devel@lists.lustre.org>


On Feb 15, 2016, at 9:28 PM, Greg KH wrote:

> On Sun, Feb 14, 2016 at 07:37:02PM -0800, Shalin Mehta wrote:
>> The parentehsis are fixed in the macro for the ldlm lock to set and
>> clear the flags.
> 
> "fixed" in what way?  Did you test-build this patch?  Also, you
> mispelled a word here?

The fix in the patch is to make sure number of parenthesis matches, as is
it appears there's one more opening one than the closing.

The original patch that add this had an error somehow, but back then none
of the users were later introduced, so the bug is "hidden" until
first user actually appears.

Compiles work with or without this fix as the result (I also just checked
just to be sure).
