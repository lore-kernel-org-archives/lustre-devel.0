From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 3 Oct 2015 00:29:52 +0000
Subject: [lustre-devel] lprocfs Helper Issues
In-Reply-To: <560F20CC.3020102@llnl.gov>
References: <974262C966B9F640899A48EB96313E9A2C9DAA@PRDEXMBX-08.the-lab.llnl.gov>,
	<560B4800.6070103@llnl.gov>
	<974262C966B9F640899A48EB96313E9A2CA46B@PRDEXMBX-08.the-lab.llnl.gov>
	<560C7F1A.30004@llnl.gov>
	<1A2899D5-160B-4BC3-982D-DE6256F3D94B@intel.com>
	<560F20CC.3020102@llnl.gov>
Message-ID: <3E6360C9-C6EA-4649-A9CF-F82A4CB0A241@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 2, 2015, at 8:26 PM, Christopher J. Morrone wrote:

> On 09/30/2015 08:21 PM, Drokin, Oleg wrote:
>> 
>> On Sep 30, 2015, at 8:32 PM, Christopher J. Morrone wrote:
>> 
>>> On 09/30/2015 12:46 PM, Di Natale, Giuseppe wrote:
>>>> I looked around to see where the helpers are used. It looks to me that they are always used in proc related functions. I agree with the issues you mentioned at the top of the email as well.
>>> 
>>> Yes, but I meant to say we need to consider future use.  Largely motivated by the effort to upstream the Lustre client into Linux, the /proc interfaces are slowly going away.  So I was just suggesting that we should check that these functions will still be used by the new debugfs/sysfs/whatever interfaces in the future.  Nothing really needed to consider though; they are generic enough to still be used well into the future.
>> 
>> The thing with the upstream kernel is that effectively procfs was split into two parts. The parts that are 1 value per file are in sysfs, the rest is in ldiskfs and resuses huge chunks
>> of old code (including the functions mentioned).
>> This is not to say we cannot replace them, of course.
>> But upstream they want us to explore other avenues for many of our stuff too, like perf code for performance/usage gathering.
> 
> Yes, and ultimately they might be opposed to even doing this much parsing of user strings in kernel space.  I can see an argument for sys files only taking simple integers, and leaving it to lustre libraries and command line tools to all niceties like specifying a number with units.

The universal agreement that I heard so far is "you can do whatever you want in debugfs as long as your code works with debugfs disabled".

> But in the sort term, cleaning up these functions is only a good thing, I think.

Indeed.

Bye,
    Oleg
