From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 09 Oct 2015 11:38:07 -0700
Subject: [lustre-devel] lprocfs Helper Issues
In-Reply-To: <D2385771.10F34A%andreas.dilger@intel.com>
References: <974262C966B9F640899A48EB96313E9A2C9DAA@PRDEXMBX-08.the-lab.llnl.gov>
	<560B4800.6070103@llnl.gov>
	<974262C966B9F640899A48EB96313E9A2CA46B@PRDEXMBX-08.the-lab.llnl.gov>
	<560C7F1A.30004@llnl.gov> <560F2174.2040003@llnl.gov>
	<FF7D8D24-EC8A-4073-AEA7-DDEC419B2999@intel.com>
	<5612F106.1070601@llnl.gov>
	<D2385771.10F34A%andreas.dilger@intel.com>
Message-ID: <5618098F.5010905@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/05/2015 09:23 PM, Dilger, Andreas wrote:
> On 2015/10/05, 3:52 PM, "Christopher J. Morrone" <morrone2@llnl.gov> wrote:
>
>> I don't recall any proc files that accepted pages.
>
> max_pages_per_rpc is probably the main one.

I think it was unwise to try to accept both a page count and byte count 
in the same option without an explicit syntax to determine which is 
which.  The implementation screws up handling of "512K", for instance, 
and there is no simple way to fix that as designed.

Chris
