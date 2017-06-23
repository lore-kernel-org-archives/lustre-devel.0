From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 24 Jun 2017 00:16:31 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: selftest: Change
 the type of variable to bool
In-Reply-To: <20170620090637.GA15837@singhal-Inspiron-5558>
References: <20170620090637.GA15837@singhal-Inspiron-5558>
Message-ID: <20170623161631.GC20104@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Tue, Jun 20, 2017 at 02:36:37PM +0530, simran singhal wrote:
> This patch changes the type of variable done from int to boolean. As it
> is been used as a boolean in the function sfw_test_rpc_done(). It also
> makes the code more readable and bool data type also requires less
> memory in comparison to int data type.

Are you sure it takes less memory?  What is the difference before and
after your patch?  Don't make claims without having a way to back them
up :)

thanks,

greg k-h
