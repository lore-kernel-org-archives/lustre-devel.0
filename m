From: Joe Perches <joe@perches.com>
Date: Tue, 16 Aug 2016 04:01:23 -0700
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: Add include path to
	Makefile
In-Reply-To: <20160816105315.GE28337@kroah.com>
References: <cover.1471289489.git.joe@perches.com>
	<5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
	<20160815210420.GA30864@kroah.com>
	<1471295658.4075.117.camel@perches.com>
	<20160816105315.GE28337@kroah.com>
Message-ID: <1471345283.4075.158.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Tue, 2016-08-16 at 12:53 +0200, Greg Kroah-Hartman wrote:
> On Mon, Aug 15, 2016 at 02:14:18PM -0700, Joe Perches wrote:
> > On Mon, 2016-08-15 at 23:04 +0200, Greg Kroah-Hartman wrote:
> > > On Mon, Aug 15, 2016 at 12:33:23PM -0700, Joe Perches wrote:
> > > > Start to rationalize include paths in source code files.
[]
> Nah, I think it's fine the way it is.??What's wrong with the "../" type
> things in the include directives?

.. path specific includes are unnecessarily file layout sensitive.

There are identically named .h files in separate directories.

The idea was to isolate the uapi type .h files from local ones.

I'll just give this up and let the lustre folks handle it.
