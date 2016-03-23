From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 23 Mar 2016 20:29:49 +0000
Subject: [lustre-devel] [PATCH] Revert "Staging: lustre: o2iblnd: Use
 sizeof type *pointer instead of sizeof type."
In-Reply-To: <1458758864.18165.4.camel@perches.com>
References: <1458685264-22755-1-git-send-email-jsimmons@infradead.org>
	<20160323014916.GF3190@kroah.com>
	<D317846B.138487%andreas.dilger@intel.com>
	<20160323134107.GA4356@kroah.com>
	<bb9ab572a3944b38814b0533323e0299@EXCHCS32.ornl.gov>
	<1458758864.18165.4.camel@perches.com>
Message-ID: <7dcad179d49c4535b4f24d3ceb85607a@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Joe Perches' <joe@perches.com>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


>> > > so the right code should be:
>> > > 
>> > > ????????sizeof(**net->ibn_tx_ps);
>> > > and the same for sizeof(**net->ibn_fmr_ps)
>> > That's a mess, isn't there some other way to fix this up to be more
>> > "obvious"?
>> This must have been encountered in the past. How was it handle in those
>> other cases?
>
>I fail to see why it's a mess.  It's just **
>and someone making a mistake.

I have no trouble with **.  If we revert it someone else will come along and
do the same mistake so I think we are stuck with the change to **.

>Removing the "typedef struct" uses from lustre
>would probably make a lot of this clearer though.

That along with a few hundred more patches heading Greg's way :-)
