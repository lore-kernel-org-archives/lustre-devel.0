From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 20 Dec 2016 21:52:40 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated
	initializers
In-Reply-To: <CAKRnqNJstpWfQdj=QDkhCNFp8KrX-vfjqfbiPjPzPtq8c6Ba4A@mail.gmail.com>
References: <20161217010045.GA140343@beast>
	<alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
	<CAKRnqNLFM_96NK3QbeoF-zC4KTe8oc7Q-eejzPgkE==XUHrwkQ@mail.gmail.com>
	<20161220071034.GL8176@mwanda>
	<C6D48C5819337145905EDC9DB164E69728D44FEC@fmsmsx120.amr.corp.intel.com>
	<CAKRnqNJstpWfQdj=QDkhCNFp8KrX-vfjqfbiPjPzPtq8c6Ba4A@mail.gmail.com>
Message-ID: <20161220185240.GK8244@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bruce Korb <bruce.korb@gmail.com>
Cc: "Hammond, John" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Faccini, Bruno" <bruno.faccini@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, "Liu, Emoly" <emoly.liu@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Dec 20, 2016 at 08:47:51AM -0800, Bruce Korb wrote:
> >
> > "{ NULL }" is valid ISO C, but unfortunately "{}" is not.
> 
> Just make the thing "static const" and don't use an initializer.

That also works, of course.

regards,
dan carpenter
