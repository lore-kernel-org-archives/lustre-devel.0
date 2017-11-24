From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 24 Nov 2017 15:49:44 +0300
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: fixed signedness of
 some socklnd params
In-Reply-To: <1511480841.8829.3.camel@gmail.com>
References: <20171122193831.11801-1-stefano.manni@gmail.com>
 <20171122193831.11801-2-stefano.manni@gmail.com>
 <20171123121306.nu66ktiqjedongpp@mwanda>
 <1511480841.8829.3.camel@gmail.com>
Message-ID: <20171124124944.qriokiaedpi4xjzp@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefano Manni <stefano.manni@gmail.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Fri, Nov 24, 2017 at 12:47:21AM +0100, Stefano Manni wrote:
> I've made the module param nsched signed because the
> ksock_tunables.ksnd_nscheds (the real container) is signed too.

Yeah.  I know.  And it's way more involved and controversial to change
ksock_tunables.

> 
> I definitely agree with you that it does not make sense to have a
> negative number of threads.
> In my opinion it's better to fix this inconsistency between the param
> and the container and then try submit another patch to harmonize
> signedness around the code.

No one will ever think about types again if Sparse stops complaining.
It's better to keep the error message instead of silencing it in a less
than ideal way because it means we have to think about types.
Eventually someone will get sick of the warning and write a huger patch
that rewrites a lot of code.

regards,
dan carpenter
