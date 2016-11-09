From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 9 Nov 2016 17:03:54 +0100
Subject: [lustre-devel] [PATCH v3] staging: lustre: mdc: manage number
 of modify RPCs in flight
In-Reply-To: <1478557403-31072-1-git-send-email-jsimmons@infradead.org>
References: <1478557403-31072-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20161109160354.GC9111@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Gregoire Pichon <gregoire.pichon@bull.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Nov 07, 2016 at 05:23:23PM -0500, James Simmons wrote:
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
> 
> Changelog:
> 
> v1) Initial patch with incorrect print out of timestamp in
>     obd_mod_rpc_stats_seq_show.
> 
> v2) Fixed up obd_mod_rpc_stats_seq_show to print out in nanoseconds
> 
> v3) Add this changelog

changelog goes below the --- line, you don't want that in the final
commit, right?

Please fix up and resend.

thanks,

greg k-h
