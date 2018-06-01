From: Doug Oucharek <doucharek@cray.com>
Date: Fri, 1 Jun 2018 18:25:24 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <E5BF8501-35EB-4DDF-ADBE-6016CF31A502@dilger.ca>
References: <20180601091133.GA27521@kroah.com>
 <20180601114151.GA25225@infradead.org>
 <E5BF8501-35EB-4DDF-ADBE-6016CF31A502@dilger.ca>
Message-ID: <29ACF5A8-7608-46BB-8191-E3FEB77D0F24@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Dilger <adilger@dilger.ca>
Cc: Christoph Hellwig <hch@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "selinux@tycho.nsa.gov" <selinux@tycho.nsa.gov>, fsdevel <linux-fsdevel@vger.kernel.org>, lustre-devel <lustre-devel@lists.lustre.org>

Would it makes sense to land LNet and LNDs on their own first?  Get the networking house in order first before layering on the file system?

Doug

> On Jun 1, 2018, at 11:20 AM, Andreas Dilger <adilger@dilger.ca> wrote:
> 
> On Jun 1, 2018, at 7:41 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> 
>> Thanks,
>> 
>> all that churn without much visible progress to a mergeable codebase
>> was really ennoying.
>> 
>> I'd recommend if people want to merge lustre they start with a managable
>> subset first, e.g. the fs client code with simple IP-only networking.
> 
> Adding or removing the IB networking makes basically no difference to the
> code size.  This would also make the client much less useful, since a large
> number of sites use Lustre with IB networks.
> 
> Cheers, Andreas
> 
> 
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
