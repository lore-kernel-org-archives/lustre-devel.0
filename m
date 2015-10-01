From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Thu, 1 Oct 2015 03:21:04 +0000
Subject: [lustre-devel] lprocfs Helper Issues
In-Reply-To: <560C7F1A.30004@llnl.gov>
References: <974262C966B9F640899A48EB96313E9A2C9DAA@PRDEXMBX-08.the-lab.llnl.gov>,
	<560B4800.6070103@llnl.gov>
	<974262C966B9F640899A48EB96313E9A2CA46B@PRDEXMBX-08.the-lab.llnl.gov>
	<560C7F1A.30004@llnl.gov>
Message-ID: <1A2899D5-160B-4BC3-982D-DE6256F3D94B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Sep 30, 2015, at 8:32 PM, Christopher J. Morrone wrote:

> On 09/30/2015 12:46 PM, Di Natale, Giuseppe wrote:
>> I looked around to see where the helpers are used. It looks to me that they are always used in proc related functions. I agree with the issues you mentioned at the top of the email as well.
> 
> Yes, but I meant to say we need to consider future use.  Largely motivated by the effort to upstream the Lustre client into Linux, the /proc interfaces are slowly going away.  So I was just suggesting that we should check that these functions will still be used by the new debugfs/sysfs/whatever interfaces in the future.  Nothing really needed to consider though; they are generic enough to still be used well into the future.

The thing with the upstream kernel is that effectively procfs was split into two parts. The parts that are 1 value per file are in sysfs, the rest is in ldiskfs and resuses huge chunks
of old code (including the functions mentioned).
This is not to say we cannot replace them, of course.
But upstream they want us to explore other avenues for many of our stuff too, like perf code for performance/usage gathering.

Bye,
    Oleg
