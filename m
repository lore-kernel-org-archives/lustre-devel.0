From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 11 Apr 2016 15:09:11 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: Fix warnings
 reported by 'make C=1'
In-Reply-To: <87bn5fan0a.fsf@hp.cfotr.com>
References: <87bn5fan0a.fsf@hp.cfotr.com>
Message-ID: <20160411220911.GA9944@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Apr 11, 2016 at 11:50:13PM +0300, Aleksey Fedotov wrote:
> >From 08473aa48a1726c09dbab43e99059be9b0e88af2 Mon Sep 17 00:00:00 2001
> From: Aleksei Fedotov <lexa@cfotr.com>
> Date: Mon, 11 Apr 2016 21:13:27 +0300
> Subject: [PATCH] staging: lustre: libcfs: Fix warnings reported by sparse

Why is this here in the body of your patch?

Please use git send-email so it does not show up.

thanks,

greg k-h
