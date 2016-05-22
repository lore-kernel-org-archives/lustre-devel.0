From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 22 May 2016 15:25:38 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: llite:
 kzalloc/copy_to_user to memdup_user
In-Reply-To: <1463953771-16942-1-git-send-email-me@tobin.cc>
References: <1463953771-16942-1-git-send-email-me@tobin.cc>
Message-ID: <20160522222538.GA17573@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tobin C Harding <me-xzjC0nNlxno@public.gmane.org>
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, Abdul Hussain <habdul-Vi+0cqmPEYlBDgjK7y7TUQ@public.gmane.org>, David Airlie <airlied-cv59FeDIM0c@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, patrik.r.jakobsson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Frank Zago <fzago-WVYJKLFxKCc@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Mon, May 23, 2016 at 07:49:29AM +1000, Tobin C Harding wrote:
> kzalloc call followed by copy_to_user can be replaced by call to memdup_user.
> 
> Signed-off-by: Tobin C Harding <me@tobin.cc>

Why did you send this twice?

> ---
>  drivers/gpu/drm/gma500/gma_display.c      |  2 +-
>  drivers/staging/lustre/lustre/llite/dir.c | 22 +++++++---------------
>  2 files changed, 8 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/gpu/drm/gma500/gma_display.c b/drivers/gpu/drm/gma500/gma_display.c
> index 5bf765d..8a1fb25 100644
> --- a/drivers/gpu/drm/gma500/gma_display.c
> +++ b/drivers/gpu/drm/gma500/gma_display.c
> @@ -285,7 +285,7 @@ void gma_crtc_dpms(struct drm_crtc *crtc, int mode)
>  
>  		/* Wait for vblank for the disable to take effect */
>  		gma_wait_for_vblank(dev);
> -
> +l

What?  What does this have to do with lustre?

It's kind of obvious you didn't build this :(

Please be more careful in the future.

greg k-h
