From: Kees Cook <keescook@chromium.org>
Date: Tue, 20 Dec 2016 11:46:35 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated
	initializers
In-Reply-To: <20161220190750.GO8176@mwanda>
References: <20161217010045.GA140343@beast>
	<alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
	<CAKRnqNLFM_96NK3QbeoF-zC4KTe8oc7Q-eejzPgkE==XUHrwkQ@mail.gmail.com>
	<20161220071034.GL8176@mwanda>
	<C6D48C5819337145905EDC9DB164E69728D44FEC@fmsmsx120.amr.corp.intel.com>
	<20161220190750.GO8176@mwanda>
Message-ID: <CAGXu5jJ5-SJyznhn2U03OxnkucJBKFsVuaWoCevJHK2V3vANjw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "Hammond, John" <john.hammond@intel.com>, Bruce Korb <bruce.korb@gmail.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, "Liu, Emoly" <emoly.liu@intel.com>, "Faccini, Bruno" <bruno.faccini@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Dec 20, 2016 at 11:07 AM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> On Tue, Dec 20, 2016 at 02:57:17PM +0000, Hammond, John wrote:
>> "{ NULL }" is valid ISO C, but unfortunately "{}" is not.
>
> In the kernel we don't care.  We use lots of GCC extensions.

We depend on the compiler to do "incomplete zero-initialization" of
structures that are not mentioned in an initializer. The reason { NULL
} works is because the first field in the structure can take a NULL
value, and then the rest are zero-initialized by the compiler. { } is
the same thing, but doesn't use ordered initialization. If this style
is truly unacceptable to you, then { .somefield = NULL } can work, or
as you point out, if it's being initialized later, the static
initializer can be dropped entirely.

-Kees

-- 
Kees Cook
Nexus Security
