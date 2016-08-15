From: Joe Perches <joe@perches.com>
Date: Mon, 15 Aug 2016 15:46:36 -0700
Subject: [lustre-devel] Building a subdirectory ignores parent
	subdir-ccflags
In-Reply-To: <57B23D16.8060405@suse.com>
References: <cover.1471289489.git.joe@perches.com>
	<5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
	<20160815210420.GA30864@kroah.com>
	<1471295658.4075.117.camel@perches.com>
	<1471296557.4075.127.camel@perches.com> <57B23D16.8060405@suse.com>
Message-ID: <1471301196.4075.133.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Marek <mmarek@suse.com>, linux-kbuild <linux-kbuild@vger.kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Yann E. MORIN" <yann.morin.1998@free.fr>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Tue, 2016-08-16 at 00:07 +0200, Michal Marek wrote:

Hi Michal.

> > Perhaps making a specific directory should also walk up
> > any parent directory Makefiles looking for subdir flags.
> > 
> > Is that unreasonable???Any suggestions?
> I suggest to do make drivers/staging/lustre/. If building the lustre
> subdirectories is going to be a common use case, then you can propagate
> the subdir-ccflags-y assignment down to the individual Makefiles.

I don't have a problem with that.

Others might though for whatever reason.

There are a couple other places in the tree that
also use subdir-ccflags where the results of making
a subdirectory would either fail or have unexpected
results.

Does it matter? ?Not much, but it could be nicer if
it's possible for parent Makefile paths to be ascended.

I'm not much of a Makefile person, but perhaps you have
some clues/tips/suggestions for implementation?
