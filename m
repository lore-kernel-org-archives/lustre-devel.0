From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 23 Nov 2017 14:51:38 +0300
Subject: [lustre-devel] [PATCH 0/4] staging: lustre: fixed some
 signedness warns from sparse
In-Reply-To: <20171123045926.GD12736@eros>
References: <20171122193831.11801-1-stefano.manni@gmail.com>
 <20171123045926.GD12736@eros>
Message-ID: <20171123115138.5nku6epnct35mmha@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Tobin C. Harding" <me@tobin.cc>
Cc: Stefano Manni <stefano.manni@gmail.com>, devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Thu, Nov 23, 2017 at 03:59:26PM +1100, Tobin C. Harding wrote:
> On Wed, Nov 22, 2017 at 08:38:27PM +0100, Stefano Manni wrote:
> > Fixed some signedness warnings from sparse on lustre.
> > 
> > Stefano Manni (4):
> >   staging: lustre: fixed signedness of some socklnd params
> >   staging: lustre: fixed signedness of llite
> >   staging: lustre: fixed signedness of lov
> >   staging: lustre: fixed signedness of obdclass
> 
> You may like to use imperative mood for your git log brief descriptions
> Stefano.  
> 
> s/fixed/fix/
> 

Someone once chewed me a second butt hole for not using the imperative
mood so I know some people care intensely about this but I think so long
as you can understand the description it's fine.  I will never send a
patch for that maintainer's subsystem again, btw, which is probably
grateful for and now I can poop twice as fast so we're both winners.

Especially in the 0/4 patch which is going to be discarded.  Who cares?

regards,
dan carpenter
