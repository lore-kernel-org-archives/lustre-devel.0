From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 29 Mar 2017 12:34:05 +0200
Subject: [lustre-devel] [PATCH] staging: lusten: conrpc.c: fix different
 address space sparse warning
In-Reply-To: <20170323190901.GA22066@builder>
References: <20170329021409.24537-1-marcos.souza.org@gmail.com>
	<20170329073114.GA8459@kroah.com> <20170323190901.GA22066@builder>
Message-ID: <20170329103405.GA4087@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcos Paulo de Souza <marcos.souza.org@gmail.com>
Cc: devel@driverdev.osuosl.org, Doug Oucharek <doug.s.oucharek@intel.com>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Thu, Mar 23, 2017 at 04:09:03PM -0300, Marcos Paulo de Souza wrote:
> On Wed, Mar 29, 2017 at 09:31:14AM +0200, Greg KH wrote:
> > On Tue, Mar 28, 2017 at 11:14:06PM -0300, Marcos Paulo de Souza wrote:
> > > head_up parameter is marked with __user attribute, tmp is filled
> > > by a copy_from_user from next, that is also marked as __user, so
> > > tmp.next needs to be "casted" as __user to make sparse happy.
> > 
> > But is it the correct change?
> 
> I don't know, it's my first sparse patch, so I tried to fix this
> warning.
> 
> > 
> > You also have a typo in your subject :(
> 
> Sorry, didn't noticed yesterday :(
> 
> > 
> > > Signed-off-by: Marcos Paulo de Souza <marcos.souza.org@gmail.com>
> > > ---
> > > 
> > >  this is mt first patch addressing an issue of sparse, so let me know
> > >  if I misunderstood the error message
> > > 
> > >  drivers/staging/lustre/lnet/selftest/conrpc.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> > > index c6a683b..fb7ad74 100644
> > > --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> > > +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> > > @@ -487,7 +487,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
> > >  				   sizeof(struct list_head)))
> > >  			return -EFAULT;
> > >  
> > > -		if (tmp.next == head_up)
> > > +		if ((struct list_head __user *)tmp.next == head_up)
> > 
> > Aer you sure this is correct?  __user changes for lustre is not
> > trivial...
> > 
> > How did you test this?
> 
> I didn't tested, it just removed the warning. Is this a false positive?

I don't know, it's up to you to prove to me that you know this change is
correct.  You have to justify your changes, and "because checkpatch.pl
complained" isn't a valid justification for something like this :)

thanks,

greg k-h
