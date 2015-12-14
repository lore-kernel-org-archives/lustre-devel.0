From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 14 Dec 2015 14:00:03 +0300
Subject: [lustre-devel] [PATCH 5/7] staging: lustre: Less checks in
 mgc_process_recover_log() after error detection
In-Reply-To: <566D7952.7090401@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7952.7090401@users.sourceforge.net>
Message-ID: <20151214110003.GV5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Dec 13, 2015 at 02:57:38PM +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 13 Dec 2015 12:21:17 +0100
> 
> A few checks would be performed by the mgc_process_recover_log() function
> even if it is known already that the passed variable "pages" contained
> a null pointer.
> 
> * Let us return directly if a call of the kcalloc() function failed.
> 
> * Move assignments for the variables "eof" and "req" behind
>   this memory allocation.

Why?  Then in the next patch it moves again.  It's like cup shuffle to
read these patches sometimes.

regards,
dan carpenter
