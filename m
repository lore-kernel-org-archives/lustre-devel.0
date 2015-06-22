From: Greg Kroah-Hartman (gregkh@linuxfoundation.org) <gregkh@linuxfoundation.org>
Date: Mon, 22 Jun 2015 11:03:06 -0700
Subject: [lustre-devel] [HPDD-discuss] [PATCH 01/12] staging: lustre:
 fid: Use !x to check for kzalloc failure
In-Reply-To: <556d2f2088404e09aac1f0a57767cea5@EXCHCS32.ornl.gov>
References: <556d2f2088404e09aac1f0a57767cea5@EXCHCS32.ornl.gov>
Message-ID: <20150622180306.GA20087@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 22, 2015 at 05:27:03PM +0000, Simmons, James A. wrote:
> 
> Is this change a hard requirement? Currently the lustre code standard in our development tree is the opposite policy.

Please follow the kernel coding style rules.
