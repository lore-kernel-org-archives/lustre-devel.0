From: Joe Perches <joe@perches.com>
Date: Tue, 20 Dec 2016 09:29:55 -0800
Subject: [lustre-devel] Designated initializers,
	struct randomization and addressing?
In-Reply-To: <20161217010045.GA140343@beast>
References: <20161217010045.GA140343@beast>
Message-ID: <1482254995.1984.20.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Dan Carpenter <error27@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Emoly Liu <emoly.liu@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, Bruno Faccini <bruno.faccini@intel.com>, Bruce Korb <bruce.korb@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

On Fri, 2016-12-16 at 17:00 -0800, Kees Cook wrote:
> Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers.

About the designated initializer patches,
which by themselves are fine of course,
and the fundamental randomization plugin,
c guarantees that struct member ordering
is as specified.

how is the code to be verified so that
any use of things like offsetof and any
address/indexing is not impacted?
