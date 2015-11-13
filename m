From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Fri, 13 Nov 2015 18:33:31 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: cl_lock: Remove
 cl_lock_lockdep_init wrapper
In-Reply-To: <CAKHNQQEW9ZcYrdowy5cFkJXqzEyoy+CseJg_3ge0QCC7=5oA3A@mail.gmail.com>
References: <1447237306-46901-1-git-send-email-shivanib134@gmail.com>
	<201511111859.mIw4mICa%fengguang.wu@intel.com>
	<CAKHNQQHLwsfv6OKOci4g4405_vcFgy7GNcUAWX0aDAS+GFU6gw@mail.gmail.com>
	<20151111173100.GA20846@kroah.com>
	<CAKHNQQEW9ZcYrdowy5cFkJXqzEyoy+CseJg_3ge0QCC7=5oA3A@mail.gmail.com>
Message-ID: <20151113130331.GB18741@sudip-pc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Nov 11, 2015 at 11:03:34PM +0530, Shivani Bhardwaj wrote:
> On Wed, Nov 11, 2015 at 11:01 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Wed, Nov 11, 2015 at 10:51:36PM +0530, Shivani Bhardwaj wrote:
> >> On Wed, Nov 11, 2015 at 4:24 PM, kbuild test robot <lkp@intel.com> wrote:
<snip>
> >>
> >> I'm not getting any of these errors at compilation. I've checked
> >> thrice. Could you please tell what am I doing wrong so that I can
> >> avoid introducing errors in future patches?
> >
> > Use the .config provided, odds are you have lockdep enabled.
> 
> Thanks Greg.
> I tried that. Still no errors. Any other suggestion?

while removing the wrapper you missed that cl_lock_lockdep_init() is:

static void cl_lock_lockdep_init(struct cl_lock *lock)
{
	        lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
}

if CONFIG_LOCKDEP is defined.
and if CONFIG_LOCKDEP is not defined then:

static void cl_lock_lockdep_init(struct cl_lock *lock)
{}

your patch is using lockdep_set_class_and_name() in both cases.

regards
sudip
