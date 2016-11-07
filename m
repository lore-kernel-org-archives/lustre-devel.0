From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 7 Nov 2016 12:38:41 +0100
Subject: [lustre-devel] [PATCH] Staging: lustre: llite: refactor
	lov_object_fiemap()
In-Reply-To: <AD95A5E8-3232-4528-83A2-5922FBE23C30@intel.com>
References: <AD95A5E8-3232-4528-83A2-5922FBE23C30@intel.com>
Message-ID: <20161107113841.GA12277@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Nov 07, 2016 at 10:56:19AM +0000, Xu, Bobijam wrote:
>  * Change loff_t to u64 in lov_object_fiemap() since loff_t is a
>   signed value type.
> * Add fiemap_for_stripe() to get file map extent from each stripe
>   device.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Bobi Jam <bobijam.xu@intel.com>

Why are you doing two different things in the same patch and also not
cc:ing the maintainers of the driver you are modifying?

Please break this up and fix the cc: issues.

thanks,

greg k-h
