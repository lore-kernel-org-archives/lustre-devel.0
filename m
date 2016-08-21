From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 21 Aug 2016 16:36:55 +0200
Subject: [lustre-devel] [PATCH 12/13] staging/lustre: Remove unused
 cp_error from struct cl_page
In-Reply-To: <1471728870-518753-13-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
	<1471728870-518753-13-git-send-email-green@linuxhacker.ru>
Message-ID: <20160821143655.GA26010@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Aug 20, 2016 at 05:34:29PM -0400, Oleg Drokin wrote:
> cp_error member is not really set anywhere, so kill
> it and the only printing user of it too.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/include/cl_object.h | 2 --
>  drivers/staging/lustre/lustre/obdclass/cl_page.c  | 4 ++--
>  2 files changed, 2 insertions(+), 4 deletions(-)

Doesn't apply :(
