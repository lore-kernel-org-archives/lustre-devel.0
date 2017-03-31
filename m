From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 31 Mar 2017 07:55:16 +0200
Subject: [lustre-devel] [PATCH] Remove sparse warnings in mdc_request.c
In-Reply-To: <1490936959-6337-2-git-send-email-skanda.kashyap@gmail.com>
References: <1592C3AC-DE8B-4A11-8053-02B82A61E1B3@intel.com>
	<1490936959-6337-1-git-send-email-skanda.kashyap@gmail.com>
	<1490936959-6337-2-git-send-email-skanda.kashyap@gmail.com>
Message-ID: <20170331055516.GA4811@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Mar 30, 2017 at 10:09:19PM -0700, skanda.kashyap at gmail.com wrote:
> From: Skanda Guruanand <skanda.kashyap@gmail.com>
> 
> ---
>  drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)


Hi,

This is the friendly patch-bot of Greg Kroah-Hartman.  You have sent him
a patch that has triggered this response.  He used to manually respond
to these common problems, but in order to save his sanity (he kept
writing the same thing over and over, yet to different people), I was
created.  Hopefully you will not take offence and will fix the problem
in your patch and resubmit it so that it can be accepted into the Linux
kernel tree.

You are receiving this message because of the following common error(s)
as indicated below:

- Your patch does not have a Signed-off-by: line.  Please read the
  kernel file, Documentation/SubmittingPatches and resend it after
  adding that line.  Note, the line needs to be in the body of the
  email, before the patch, not at the bottom of the patch or in the
  email signature.

- Your patch did many different things all at once, making it difficult
  to review.  All Linux kernel patches need to only do one thing at a
  time.  If you need to do multiple things (such as clean up all coding
  style issues in a file/driver), do it in a sequence of patches, each
  one doing only one thing.  This will make it easier to review the
  patches to ensure that they are correct, and to help alleviate any
  merge issues that larger patches can cause.

- You did not specify a description of why the patch is needed, or
  possibly, any description at all, in the email body.  Please read the
  section entitled "The canonical patch format" in the kernel file,
  Documentation/SubmittingPatches for what is needed in order to
  properly describe the change.

- You did not write a descriptive Subject: for the patch, allowing Greg,
  and everyone else, to know what this patch is all about.  Please read
  the section entitled "The canonical patch format" in the kernel file,
  Documentation/SubmittingPatches for what a proper Subject: line should
  look like.

If you wish to discuss this problem further, or you have questions about
how to resolve this issue, please feel free to respond to this email and
Greg will reply once he has dug out from the pending patches received
from other developers.

thanks,

greg k-h's patch email bot
