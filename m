From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 2 Mar 2016 15:21:46 -0800
Subject: [lustre-devel] [PATCH] staging/lustre: Unbreak ll_prep_inode
	iget result check
In-Reply-To: <1456925139-1058929-1-git-send-email-green@linuxhacker.ru>
References: <1456925139-1058929-1-git-send-email-green@linuxhacker.ru>
Message-ID: <20160302232146.GA24687@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: green@linuxhacker.ru
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Mar 02, 2016 at 08:25:39AM -0500, green at linuxhacker.ru wrote:
> From: Oleg Drokin <green@linuxhacker.ru>
> 
> commit 020ecc6f3229 ("staging: lustre: llite: Remove IS_ERR tests")
> managed to break one of the converted checks by losing a dereference
> causing the condition to be wrong and hence leading
> to a crash later on in case of actual error.
> IS_ERR_OR_NULL(*inode) got converted into !inode.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> CC: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> ---
> I am not sure where did that patch came from as I cannot see
> it in either my inbox or in any public mailinglists via google.

My fault, it is part of the Outreachy application process, I missed that
bug, sorry about this.

greg k-h
