From: Andreas Dilger <adilger@dilger.ca>
Date: Fri, 1 Jun 2018 14:20:27 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <20180601114151.GA25225@infradead.org>
References: <20180601091133.GA27521@kroah.com>
 <20180601114151.GA25225@infradead.org>
Message-ID: <E5BF8501-35EB-4DDF-ADBE-6016CF31A502@dilger.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel <lustre-devel@lists.lustre.org>, fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, selinux@tycho.nsa.gov

On Jun 1, 2018, at 7:41 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> Thanks,
> 
> all that churn without much visible progress to a mergeable codebase
> was really ennoying.
> 
> I'd recommend if people want to merge lustre they start with a managable
> subset first, e.g. the fs client code with simple IP-only networking.

Adding or removing the IB networking makes basically no difference to the
code size.  This would also make the client much less useful, since a large
number of sites use Lustre with IB networks.

Cheers, Andreas





-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 873 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180601/7f63d49e/attachment.sig>
