From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 7 Dec 2016 23:46:39 +0000
Subject: [lustre-devel] [PATCH 0/8] Sparse warning fixes in Lustre.
In-Reply-To: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
Message-ID: <20161207234639.GU1555@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Dec 07, 2016 at 05:41:26PM -0500, Oleg Drokin wrote:
> This set of fixes aims at sparse warnings.

Speaking of the stuff sparse catches there: class_process_proc_param().
I've tried to describe what I think of that Fine Piece Of Software
several times, but I had to give up - my command of obscenity is not
up to the task, neither in English nor in Russian.  Please, take it
out.  Preferably - along with the ->ldo_process_config()/->process_config()
thing.
