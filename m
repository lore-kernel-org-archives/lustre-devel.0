From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 14 Mar 2018 12:55:46 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: fix race at
 kiblnd_connect_peer
In-Reply-To: <1520581758-4410-1-git-send-email-doug@cadentcomputing.com>
References: <1520581758-4410-1-git-send-email-doug@cadentcomputing.com>
Message-ID: <20180314115546.GA14792@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <doug@cadentcomputing.com>
Cc: devel@driverdev.osuosl.org, Doug Oucharek <dougso@me.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Alexander Boyko <alexander.boyko@seagate.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Mar 09, 2018 at 02:49:18AM -0500, Doug Oucharek wrote:
> From: Alexander Boyko <alexander.boyko@seagate.com>
> 
> cmid will be destroyed at OFED if kiblnd_cm_callback return error.
> if error happen before the end of kiblnd_connect_peer, it will touch
> destroyed cmid and fail as
> (o2iblnd_cb.c:1315:kiblnd_connect_peer())
>             ASSERTION( cmid->device != ((void *)0) ) failed:
> 
> Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10015
> Reviewed-by: Alexey Lyashkov <c17817@cray.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Signed-off-by: Doug Oucharek <dougso@me.com>

Your email address here does not match the From: line :(

Please fix up and resend...

thanks,

greg k-h
