From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 2 Dec 2016 11:42:44 +0100
Subject: [lustre-devel] [PATCH 21/22 v2] staging/lustre/libcfs: Convert
 to hotplug state machine
In-Reply-To: <20161202101825.mcsbw4nr4slymcvl@linutronix.de>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
	<20161126231350.10321-22-bigeasy@linutronix.de>
	<20161202101825.mcsbw4nr4slymcvl@linutronix.de>
Message-ID: <20161202104244.GB8736@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, rt@linutronix.de, tglx@linutronix.de, Anna-Maria Gleixner <anna-maria@linutronix.de>, lustre-devel@lists.lustre.org

On Fri, Dec 02, 2016 at 11:18:25AM +0100, Sebastian Andrzej Siewior wrote:
> From: Anna-Maria Gleixner <anna-maria@linutronix.de>
> 
> Install the callbacks via the state machine.
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: Andreas Dilger <andreas.dilger@intel.com>
> Cc: James Simmons <jsimmons@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: lustre-devel at lists.lustre.org
> Cc: devel at driverdev.osuosl.org
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
> [bigeasy: rebase to linux-next]
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> v1?v2: rebase to linux-next
> 
> Side note: Is there a reason the handle the down state very late at
> CPU_DEAD time and use the counterpart of the online callback (the old
> CPU_DOWN_PREPARE state).

You need a blank line before the cc: lines in your changelog please...

thanks,

greg k-h
