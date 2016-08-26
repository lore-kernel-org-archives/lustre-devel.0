From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 26 Aug 2016 15:48:27 -0400
Subject: [lustre-devel] [PATCH] staging/lustre: avoid zero buf for the
	first time
In-Reply-To: <20160822100408.GA11890@kroah.com>
References: <1471855564-15962-1-git-send-email-shawn.lin@rock-chips.com>
	<20160822100408.GA11890@kroah.com>
Message-ID: <5498CEC3-3AB9-487B-9899-3E9372D2C575@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Shawn Lin <shawn.lin@rock-chips.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hello!

On Aug 22, 2016, at 6:04 AM, Greg Kroah-Hartman wrote:

> On Mon, Aug 22, 2016 at 04:46:04PM +0800, Shawn Lin wrote:
>> We only need to zero it when repeating in order to
>> avoid old garbage. Let's improve it by moving this
>> before we repeat the calculation to save some cpu
>> cycle.
>> 
>> Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
> 
> Have you noticed a change with this in a benchmark?
> 
> If not, is it really worth it?

The other problem is we would need to remember to memset it
should there be more paths jumping to the repeat label
which might be easy to miss,
so we are probably better off without this patch.

> I need an ack from the lustre developers before taking patches like
> this...
> 
> thanks,
> 
> greg k-h
