From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 1 Jun 2018 04:41:51 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <20180601091133.GA27521@kroah.com>
References: <20180601091133.GA27521@kroah.com>
Message-ID: <20180601114151.GA25225@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, selinux@tycho.nsa.gov

Thanks,

all that churn without much visible progress to a mergeable codebase
was really ennoying.

I'd recommend if people want to merge lustre they start with a managable
subset first, e.g. the fs client code with simple IP-only networking.
