From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 9 Nov 2016 17:05:07 +0100
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: llite: use u64
 instead of loff_t in lov_object_fiemap()
In-Reply-To: <B830560B-ED95-40ED-B612-39827A314B7F@intel.com>
References: <B830560B-ED95-40ED-B612-39827A314B7F@intel.com>
Message-ID: <20161109160507.GD9111@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Nov 08, 2016 at 12:13:59PM +0000, Xu, Bobijam wrote:
> Change loff_t to u64 in lov_object_fiemap() since loff_t is a signed
> value type.
> 
> Otherwise there could be an overflow in
> drivers/staging/lustre/lustre/lov/lov_object.c:1241 lov_object_fiemap()
> warn: signed overflow undefined. 'fm_start + fm_length < fm_start'
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_object.c | 38 +++++++++++++-------------
>  1 file changed, 19 insertions(+), 19 deletions(-)

Why did you not cc: the maintainers of this filesystem with these
patches?
Please resend them both and do so.

thanks,

greg k-h
