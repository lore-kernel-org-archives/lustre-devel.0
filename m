From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 8 Jun 2015 12:33:59 -0700
Subject: [lustre-devel] [PATCH v4 1/7] staging:lustre: move tcpip
	abstraction
In-Reply-To: <1433361433-24976-2-git-send-email-jsimmons@infradead.org>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
	<1433361433-24976-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20150608193359.GA1001@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 03:57:07PM -0400, James Simmons wrote:
> Rename libcfs/linux/linux-tcpip.c to lnet/lnet/lib-socket.c
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lnet/lnet/Makefile          |    7 +-
>  drivers/staging/lustre/lnet/lnet/lib-socket.c      |  624 ++++++++++++++++++++
>  drivers/staging/lustre/lustre/libcfs/Makefile      |    1 -
>  .../lustre/lustre/libcfs/linux/linux-tcpip.c       |  623 -------------------
>  4 files changed, 628 insertions(+), 627 deletions(-)
>  create mode 100644 drivers/staging/lustre/lnet/lnet/lib-socket.c
>  delete mode 100644 drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c

Please generate patches in -M format, so I can see the rename properly,
as it is, this is too messy for me to review.

Please fix up and resend.

thanks,

greg k-h
