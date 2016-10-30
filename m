From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 30 Oct 2016 11:04:05 -0400
Subject: [lustre-devel] [PATCH 12/29] staging: lustre: mdc: manage
 number of modify RPCs in flight
In-Reply-To: <1477606323-30325-13-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
	<1477606323-30325-13-git-send-email-jsimmons@infradead.org>
Message-ID: <20161030150405.GA7100@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Gregoire Pichon <gregoire.pichon@bull.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Oct 27, 2016 at 06:11:46PM -0400, James Simmons wrote:
> From: Gregoire Pichon <gregoire.pichon@bull.net>
> 
> This patch is the main client part of a new feature that supports
> multiple modify metadata RPCs in parallel. Its goal is to improve
> metadata operations performance of a single client, while maintening
> the consistency of MDT reply reconstruction and MDT recovery
> mechanisms.
> 
> It allows to manage the number of modify RPCs in flight within
> the client obd structure and to assign a virtual index (the tag) to
> each modify RPC to help server side cleaning of reply data.
> 
> The mdc component uses this feature to send multiple modify RPCs
> in parallel.

I'm not going to apply this one due to the kbuild warning it causes.

thanks,

greg k-h
